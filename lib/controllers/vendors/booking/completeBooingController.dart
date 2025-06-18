import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

class CompleteBookingController extends GetxController {
  Future<bool> completeBooking(
    String bookingId,
  ) async {
   
    final Uri url = Uri.parse('${GlobalsVariables.baseUrlapp}/booking/update/$bookingId');
    final token = GlobalsVariables.token;
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // if your API needs token
        },
        body: jsonEncode({
          'status': 'past',
        }),
      );

      if (response.statusCode == 200) {
        print('Booking completed successfully.');
        return true;
      } else {
        print('Failed to complete booking: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error completing booking: $e');
      return false;
    }
  }
}
