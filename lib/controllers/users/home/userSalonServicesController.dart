// lib/controllers/vendors/dashboard/user_salon_services_controller.dart

import 'dart:convert';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class UserSalonServicesController extends GetxController {
  final isLoading = false.obs;

  /// servicesList should be populated from your real data source.
  /// For now assume it's a list of maps each containing '_id' and other fields.
  final servicesList = <Map<String, dynamic>>[];

  /// Call this to create a booking.
  /// [vendorId]        – the salon/vendor’s _id
  /// [serviceIds]      – list of service _ids the user selected
  /// [bookingDate]     – optional string, e.g. "Sun 21 2025, 20:30pm"
  Future<void> createBooking({
    required String vendorId,
    required List<String> serviceIds,
    String? bookingDate,
  }) async {
    isLoading(true);
    try {
      final token = GlobalsVariables.token; // your logged‑in user token
      final url = '${GlobalsVariables.baseUrlapp}/booking/create';

      final resp = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'vendor': vendorId,
          'services': serviceIds,
          if (bookingDate != null) 'bookingDate': bookingDate,
        }),
      );

      debugPrint('createBooking → ${resp.statusCode}: ${resp.body}');
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        Get.snackbar('Success', 'Booking created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create booking');
      }
    } catch (e) {
      Get.snackbar('Exception', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
