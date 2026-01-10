import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class DashBoardController extends GetxController {
  // loading state
  final isLoading = true.obs;
  var bannerImage = ''.obs;

  // profile fields
  final vendorName = ''.obs;
  final profileImage = ''.obs;
  final listing = ''.obs;
  final shopeName = ''.obs;
  final shopeDes = ''.obs;
  final rating = ''.obs;
  final vendorId = ''.obs;
  // openingTime fields (no model)
  RxString weekdaysFrom = ''.obs;
  RxString weekdaysTo = ''.obs;
  RxString weekendsFrom = ''.obs;
  RxString weekendsTo = ''.obs;
  RxString vendorLong = ''.obs;
  RxString vendorLate = ''.obs;
  RxString locationAddress = ''.obs;

  // gallery list of image URLs
  final gallery = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVendor();
  }

  Future<void> fetchVendor() async {
    isLoading(true);
    try {
      final token = GlobalsVariables.vendorLoginToken;
      final resp = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          final data = body['data'] as Map<String, dynamic>;
          print(data);
          // opening times (directly from JSON)
          final ot = data['openingTime'] as Map<String, dynamic>?;
          print('ot  $ot');
          if (ot != null) {
            final wk = ot['weekdays'] as Map<String, dynamic>?;
            final we = ot['weekends'] as Map<String, dynamic>?;
            weekdaysFrom.value = wk?['from'] ?? '';
            weekdaysTo.value = wk?['to'] ?? '';
            weekendsFrom.value = we?['from'] ?? '';
            weekendsTo.value = we?['to'] ?? '';
          }
          final rawGallery = data['gallery'] as List<dynamic>?;
          gallery.value = rawGallery?.map((e) => e.toString()).toList() ?? [];
          // basic fields
          vendorName.value = data['userName'] ?? '';
          profileImage.value = data['profileImage'] ?? '';
          shopeName.value = data['shopName'] ?? '';
          shopeDes.value = data['description'] ?? '';
          listing.value = data['listingPlan'];
          bannerImage.value = data['shopBanner'];
          
          print('🔧 BEFORE SETTING - vendorLat from data: ${data['vendorLat']} (${data['vendorLat'].runtimeType})');
          print('🔧 BEFORE SETTING - vendorLong from data: ${data['vendorLong']} (${data['vendorLong'].runtimeType})');
          
          vendorLate.value = data['vendorLat']?.toString() ?? '';
          vendorLong.value = data['vendorLong']?.toString() ?? '';
          locationAddress.value = data['locationAddress'] ?? '';
          vendorId.value = data['_id'];
          
          print('✅ AFTER SETTING - vendorLate.value: "${vendorLate.value}"');
          print('✅ AFTER SETTING - vendorLong.value: "${vendorLong.value}"');
          print('✅ AFTER SETTING - locationAddress.value: "${locationAddress.value}"');
          // gallery

          print(ot);
          print('WEEKDAYS: ${weekdaysFrom.value} - ${weekdaysTo.value}');
          print('WEEKENDS: ${weekendsFrom.value} - ${weekendsTo.value}');
        } else {
          // Get.snackbar('Error', body['message'] ?? 'Unknown error');
        }
      } else {
        // Get.snackbar('Error', 'Server error: ${resp.statusCode}');
      }
    } catch (e) {
      // Get.snackbar('Error', 'Could not fetch profile:\n$e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateVendorVerificationImage({
    required String token,
    required File verificationImage,
  }) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/vendor/update',
    ); // replace with real baseurl

    final request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token';

    // Attach the verificationImage
    request.files.add(
      await http.MultipartFile.fromPath('shopBanner', verificationImage.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      await fetchVendor();
      Get.snackbar('Success', 'Image Uploaded Successfuly');

      print('✅ Vendor updated successfully: $respStr');
    } else {
      print('❌ Failed to update vendor: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVendorReviews(String vendorId) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/review/vendor/$vendorId',
    ); // replace with real baseurl
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['status'] == 'success' && jsonBody['data'] is List) {
          final List<dynamic> data = jsonBody['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception('Unexpected API response structure');
        }
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}
