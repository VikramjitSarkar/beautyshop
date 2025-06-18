import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VendorReviewController extends GetxController {
  var isLoading = false.obs;
  var reviews = [].obs;

  /// Replace this with your actual base URL

  /// Fetch vendor reviews by vendor ID
  Future<void> fetchVendorReviews(String vendorId) async {
    final String url = '${GlobalsVariables.baseUrlapp}/review/vendor/$vendorId';

    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(url));
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        reviews.value = data['data'] ?? [];
      } else {
        Get.snackbar("Error", "Failed to load reviews");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Exception", e.toString());
    }
  }
}
