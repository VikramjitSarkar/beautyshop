import 'dart:convert';
import 'dart:math';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:http/http.dart' as http;

class UserReviewController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var reviews = [].obs;

  final String baseUrl = ""; // your actual base URL
  final token = GlobalsVariables.token; // retrieve securely

  Future<void> fetchUserReviews(String vendorId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/review/vendor/$vendorId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        reviews.value = result['data'];
        print(reviews);
      } else {
        errorMessage.value = 'Already Submitted Comment';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createReview(String vendorId, int rating, String comment) async {
    final token = GlobalsVariables.token;
    try {
      final response = await http.post(
        Uri.parse('${GlobalsVariables.baseUrlapp}/review/create'),
        headers: {
          'Authorization': 'Bearer $token', // Use secure token storage
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "vendor": vendorId,
          "rating": rating,
          "comment": comment,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar("Success", "Review submitted successfully");
        fetchUserReviews(vendorId); // Refresh reviews
        Get.off(() => CustomNavBar());
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        Get.snackbar(
          "Error",
          errorData['message'] ?? "Failed to submit review",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}
