import 'dart:convert';
import 'dart:io';
import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserProfileController extends GetxController {
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var name = ''.obs;
  var profession = ''.obs;
  var imageUrl = ''.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var dateOfBirth = ''.obs;
  var locationAddress = ''.obs;
  var userLat = ''.obs;
  var userLong = ''.obs;
  var gender = ''.obs;
  var favoriteVendors = <String>[].obs;

  final String? token = GlobalsVariables.token;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    update();

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/get');
    print('[fetchUserProfile] GET $url');

    try {
      final res = await http.get(url, headers: _buildHeaders());
      print('[fetchUserProfile] status=${res.statusCode}');
      _prettyPrintJson('GET /user/get BODY', res.body);

      if (res.statusCode == 200) {
        final raw = jsonDecode(res.body);
        if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
          final user = raw['data'] as Map<String, dynamic>;
          _printKeys('USER FIELDS', user);
          _updateProfileData(user); // <-- pass the user map directly
          print('user data: $user');
        } else {
          print('[fetchUserProfile] Unexpected payload shape: ${res.body}');
        }
      } else {
        print('[fetchUserProfile] error body: ${res.body}');
        Get.snackbar('Error', 'Failed to load profile: ${res.statusCode}');
      }
    } catch (e) {
      print('[fetchUserProfile] exception: $e');
      Get.snackbar('Error', 'Please check your internet connection');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Pretty-print JSON safely (no debugPrint)
  void _prettyPrintJson(String label, String body) {
    try {
      final obj = jsonDecode(body);
      final pretty = const JsonEncoder.withIndent('  ').convert(obj);
      print('[$label]\n$pretty');
    } catch (_) {
      // Not JSON, just print raw
      print('[$label]\n$body');
    }
  }

  /// Log keys and runtime types of a map
  void _printKeys(String label, Map<String, dynamic> m) {
    print('--- $label ---');
    for (final k in m.keys) {
      final v = m[k];
      print(' • $k  (${v.runtimeType})');
    }
    print('-----------------');
  }


  // user_profile_controller.dart (add inside class)
  Future<bool> setPhoneVerified(String phone) async {
    try {
      final req = http.MultipartRequest(
        'PUT',
        Uri.parse('${GlobalsVariables.baseUrlapp}/user/update'),
      );
      req.headers['Authorization'] = 'Bearer $token';

      // 🔒 Only the fields you actually want to change:
      req.fields['phone'] = phone;
      req.fields['isPhoneVerified'] = 'true';

      final res = await req.send();
      final body = await res.stream.bytesToString();
      print('[setPhoneVerified] status=${res.statusCode} body=$body');

      if (res.statusCode == 200) {
        phoneNumber.value = phone;
        await fetchUserProfile();
        return true;
      }
    } catch (e) {
      print('[setPhoneVerified] error: $e');
    }
    return false;
  }



  Future<void> updateUserProfile({
    required String locationAddress,
    required String userLat,
    required String userLong,
    required String userName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    File? profileImageFile,
  }) async {
    isUpdating.value = true;

    try {
      final url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/update');
      print('[updateUserProfile] PUT $url');

      // Fallbacks so we never send blanks that wipe data
      final safeName   = userName.trim().isEmpty     ? name.value              : userName.trim();
      final safeEmail  = email.trim().isEmpty        ? this.email.value        : email.trim();
      final safePhone  = phoneNumber.trim().isEmpty  ? this.phoneNumber.value  : phoneNumber.trim();
      final safeDob    = dateOfBirth.trim().isEmpty  ? this.dateOfBirth.value  : dateOfBirth.trim();
      final safeGender = gender.trim().isEmpty       ? this.gender.value       : gender.trim().toLowerCase();
      final safeAddr   = locationAddress.trim().isEmpty ? this.locationAddress.value : locationAddress.trim();
      final safeLat    = userLat.isEmpty             ? this.userLat.value      : userLat;
      final safeLong   = userLong.isEmpty            ? this.userLong.value     : userLong;

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['userName']       = safeName;
      request.fields['email']          = safeEmail;
      request.fields['phone']          = safePhone;
      request.fields['gender']         = safeGender;
      request.fields['dateofBirth']    = safeDob;   // your backend uses `dateofBirth`
      request.fields['locationAdress'] = safeAddr;  // note the single 'd' in "Adress"
      request.fields['userLat']        = safeLat;
      request.fields['userLong']       = safeLong;

      if (profileImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('profileImage', profileImageFile.path));
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      print('[updateUserProfile] status=${response.statusCode}');
      print('[updateUserProfile] body=$body');

      if (response.statusCode == 200) {
        // update local cache
        name.value             = safeName;
        this.email.value       = safeEmail;
        this.phoneNumber.value = safePhone;
        this.dateOfBirth.value = safeDob;
        this.locationAddress.value = safeAddr;
        this.userLat.value     = safeLat;
        this.userLong.value    = safeLong;
        this.gender.value      = safeGender;

        try {
          final json = jsonDecode(body);
          final data = json is Map && json['data'] is Map ? json['data'] : json;
          final img = (data['profileImage'] ?? data['imageUrl'] ?? '').toString();
          if (img.isNotEmpty) imageUrl.value = img;
        } catch (_) {}

        Get.snackbar('Success', 'Profile updated successfully!');
      } else {
        Get.snackbar('Error', 'Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('[updateUserProfile] error=$e');
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    } finally {
      isUpdating.value = false;
    }
  }



  // Helper method to update profile data from API response
  void _updateProfileData(Map<String, dynamic> data) {
    name.value = data['userName'] ?? '';
    profession.value = data['profession'] ?? '';
    email.value = data['email'] ?? '';
    phoneNumber.value = data['phone'] ?? '';
    dateOfBirth.value = (data['dateofBirth'] ?? data['dateOfBirth'] ?? '').toString();
    gender.value      = (data['gender'] ?? '').toString().trim().toLowerCase();
    locationAddress.value = data['locationAdress'] ?? '';
    userLat.value = data['userLat']?.toString() ?? '';
    userLong.value = data['userLong']?.toString() ?? '';
    imageUrl.value = data['profileImage'] ?? '';

    if (data['favoriteVendors'] != null) {
      favoriteVendors.assignAll(List<String>.from(data['favoriteVendors']));
    }
  }

  // Helper method to build headers
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }



  // === DEBUG HELPERS ===
  static const bool _debugApi = true;
  //
  // void _prettyPrintJson(String label, String body) {
  //   if (!_debugApi) return;
  //   try {
  //     final encoder = const JsonEncoder.withIndent('  ');
  //     final decoded = jsonDecode(body);
  //     print('[$label]\n${encoder.convert(decoded)}');
  //   } catch (_) {
  //     print('[$label RAW]\n$body');
  //   }
  // }
  //
  // void _printKeys(String title, Map<String, dynamic> map, {String prefix = ''}) {
  //   if (!_debugApi) return;
  //   print('--- $title ---');
  //   map.forEach((k, v) {
  //     final typeName = v == null ? 'null' : v.runtimeType.toString();
  //     print(' • ${prefix.isEmpty ? '' : '$prefix.'}$k  ($typeName)');
  //     if (v is Map<String, dynamic>) {
  //       _printKeys(title, v, prefix: prefix.isEmpty ? k : '$prefix.$k');
  //     }
  //   });
  //   print('-----------------');
  // }

}
