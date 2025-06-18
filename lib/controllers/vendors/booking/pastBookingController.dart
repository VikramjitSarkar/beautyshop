import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VendorPastBookingController extends GetxController {
  var isLoading = false.obs;
  var upcomingBookings = [].obs;
  var pastBookings = [].obs;
  var errorMessage = ''.obs;



  // Fetch bookings with status filter
  Future<void> fetchBookings(
      {required String vendorId, required String status // 'pending' or 'past'
      }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = Uri.parse('${GlobalsVariables.baseUrlapp}/booking/vendor/$vendorId?status=$status');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (status == 'pending') {
            upcomingBookings.value = List.from(data['data'] ?? []);
          } else {
            pastBookings.value = List.from(data['data'] ?? []);
          }

          if (data['data'].isEmpty) {
            errorMessage.value = 'No  bookings found';
          }
        } else {
          errorMessage.value =
            'Please Login';
        }
      } else {
        // errorMessage.value = 'Server error';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Network error: Please check your internet Connection}';
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = Uri.parse('${GlobalsVariables.baseUrlapp}/booking/delete/$bookingId');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Remove the deleted booking from the list
          pastBookings.removeWhere((booking) => booking['_id'] == bookingId);
          Get.snackbar(
            "Success",
            "Booking deleted successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          errorMessage.value = data['message'] ?? 'Failed to delete booking';
          Get.snackbar(
            "Error",
            errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        Get.snackbar(
          "Error",
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  /// Reschedule Api Method




 

}
