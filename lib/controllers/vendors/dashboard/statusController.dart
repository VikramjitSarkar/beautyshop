import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class StatusController extends GetxController {
  RxBool isOnline = false.obs;

  Future<void> toggleStatus() async {
    isOnline.value = !isOnline.value;
    await updateStatus(isOnline.value);
  }

  Future<void> updateStatus(bool status) async {
    final token = GlobalsVariables.vendorLoginToken;
    if (token == null) {
      Get.snackbar("Error", "Vendor token not found");
      return;
    }

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/update');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status ? 'online' : 'offline'}),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Status updated successfully");
        
        // Send notification to all users about status change
        await _notifyUsersAboutStatusChange(status);
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['message'] ?? 'Status update failed');
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
  
  /// Notify backend to send FCM notification to users
  Future<void> _notifyUsersAboutStatusChange(bool isOnline) async {
    try {
      final token = GlobalsVariables.vendorLoginToken;
      final vendorId = GlobalsVariables.vendorId;
      
      if (token == null || vendorId == null) return;
      
      final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/notifyStatusChange');
      
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vendorId': vendorId,
          'status': isOnline ? 'online' : 'offline',
        }),
      );
      
      print('[StatusController] Status change notification sent');
    } catch (e) {
      print('[StatusController] Error sending status notification: $e');
    }
  }
}
