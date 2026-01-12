import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class PendingBookingController extends GetxController {
  var isLoading = false.obs;
  var bookings = [].obs;
  var activeBooking = [].obs;

  Future<void> fetchBooking({required String vendorId}) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/booking/vendor/$vendorId?status=pending',
    );
    try {
      isLoading.value = true;
      final response = await http.get(url);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bookings.value = data['data'] ?? [];
      } else {
        Get.snackbar("", "Failed to load booking");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Exception", 'Please check your internet connection');
    }
  }

  Future<void> fetchActiveBooking({required String vendorId}) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/booking/vendor/$vendorId?status=accept',
    );
    try {
      isLoading.value = true;
      final response = await http.get(url);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        activeBooking.value = data['data'] ?? [];
        print('📋 Upcoming Bookings Count: ${activeBooking.length}');
        if (activeBooking.isNotEmpty) {
          print('📋 First Upcoming Booking: ${activeBooking[0]}');
        }
      } else {
        Get.snackbar("", "Failed to load Booking");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("", 'Please check your internet Connection');
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/booking/accept/$bookingId',
    );
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Booking accepted.");
        fetchBooking(vendorId: GlobalsVariables.vendorId!); // refresh
      } else {
        Get.snackbar("Error", "Failed to accept Booking");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    }
  }

  rejectBooking(String bookingId) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/booking/reject/$bookingId',
    );
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Booking rejected.");
        fetchBooking(vendorId: GlobalsVariables.vendorId!); // refresh
      } else {
        Get.snackbar("Error", "Failed to reject booking");
      }
    } catch (e) {
      Get.snackbar("Exception", 'Please Check your internet Connection');
    }
  }

  // Reschudel APi

  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
  }) async {
    final String baseUrl =
        GlobalsVariables.baseUrlapp; // Replace with your actual base URL
    final Uri url = Uri.parse('$baseUrl/booking/reschedule/$bookingId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN', // Uncomment if needed
        },
        body: jsonEncode({
          'newDate': newDate.toUtc().toIso8601String(), // ISO format required
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        print('Reschedule success: $body');
        // Get.snackbar('Rechedule', 'Booking Reschedule Scuccessfully');p
        return true;
      } else {
        print('Reschedule failed');
        return false;
      }
    } catch (e) {
      print('Please Check you internet Connection');
      return false;
    }
  }
}
