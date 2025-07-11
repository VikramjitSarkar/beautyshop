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
    update(); // Notify listeners immediately

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/get');

    print("fetching user");
    try {
      final response = await http.get(url, headers: _buildHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _updateProfileData(data['data']); // Use the helper method
        update();
        print("user data: $data");
        // Get.snackbar('Success', 'Profile loaded successfully!');
      } else {
        // Get.snackbar('Error', 'Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Please check your internet connection');
    } finally {
      isLoading.value = false;
      update(); // Notify listeners when done
    }
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
      // Create multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${GlobalsVariables.baseUrlapp}/user/update'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['locationAdress'] = locationAddress;
      request.fields['userLat'] = userLat;
      request.fields['userLong'] = userLong;
      request.fields['userName'] = userName;
      request.fields['email'] = email;
      request.fields['phone'] = phoneNumber;
      request.fields['dateofBirth'] = dateOfBirth;
      request.fields['gender'] = gender;

      // Add image file if provided
      if (profileImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage', // Must match exactly what API expects
            profileImageFile.path,
          ),
        );
      }

      // Send request
      var response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        // Update local state
        name.value = userName;
        this.email.value = email;
        this.phoneNumber.value = phoneNumber;
        this.dateOfBirth.value = dateOfBirth;
        this.locationAddress.value = locationAddress;
        this.userLat.value = userLat;
        this.userLong.value = userLong;
        this.gender.value = gender;

        if (profileImageFile != null) {
          imageUrl.value = jsonResponse['profileImage'] ?? '';
        }

        Get.snackbar('Success', 'Profile updated successfully!');
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile: ${response.statusCode}',
        );
      }
    } catch (e) {
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
    dateOfBirth.value = data['dateofBirth'] ?? '';
    locationAddress.value = data['locationAdress'] ?? '';
    userLat.value = data['userLat']?.toString() ?? '';
    userLong.value = data['userLong']?.toString() ?? '';
    gender.value = data['gender'] ?? '';
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
}
