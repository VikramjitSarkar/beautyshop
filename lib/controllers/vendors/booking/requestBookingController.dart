import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RequestBookingController extends GetxController {
  var isLoading = false.obs;
  var bookings = [].obs;

  Future<void> fetchRequests() async {
    final url = Uri.parse(
        '${GlobalsVariables.baseUrlapp}/booking/vendor/${GlobalsVariables.vendorId}?status=pending');
    try {
      isLoading.value = true;
      final response = await http.get(url);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bookings.value = data['data'] ?? [];
        print('Request Bookings : $bookings');
      } else {
        Get.snackbar("Error", "Failed: ${response.statusCode}");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Exception", e.toString());
    }
  }
}
