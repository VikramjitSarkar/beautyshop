import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserNotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var vendorNotifications = <Map<String, dynamic>>[].obs;
  Future<void> fetchNotifications(String userId) async {
    isLoading.value = true;
    error.value = '';
    final url = '${GlobalsVariables.baseUrlapp}/notification/forUser/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          notifications.value = List<Map<String, dynamic>>.from(
            jsonData['data'],
          );
        } else {
          error.value = 'Failed to fetch notifications';
        }
      } else {
        error.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }



   Future<void> fetchVendorNotifications(String vendorId) async {
    isLoading.value = true;
    error.value = '';
    final url = 'http://89.116.39.230:4000/notification/forVendor/$vendorId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          vendorNotifications.value = List<Map<String, dynamic>>.from(
            jsonData['data'],
          );
        } else {
          error.value = 'Failed to fetch notifications';
        }
      } else {
        error.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      error.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
