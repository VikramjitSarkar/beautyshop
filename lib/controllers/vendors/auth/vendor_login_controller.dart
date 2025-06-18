import 'dart:convert';
import 'package:beautician_app/utils/libs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';

import '../../../constants/globals.dart';

class VendorLoginController extends GetxController {
  var isLoading = false.obs;
  Future<String?> _getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        Get.snackbar('Warning', 'Could not get FCM token');
        return null;
      }
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> loginVendor({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    final fcmToken = await _getFCMToken();
    if (fcmToken == null) {
      isLoading.value = false;
      Get.snackbar('Error', 'Notification services not available');
      return;
    }

    print('FCM Token: $fcmToken');
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
        }),
      );

      isLoading.value = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login response: ${data['status']}');
        // if (data['status'] == 'blocked') {
        //   Get.snackbar(
        //     'Error',
        //     'Your account is blocked. Please contact support.',
        //   );
        //   return;
        // }
        print(data['data']['_id']);
        final token = data['token'];
        final vendorId = data['data']['_id'];

        if (token != null) {
          // 1. save login token
          await GlobalsVariables.saveVendorLoginToken(token);
          print(
            '▶︎ vendorLoginToken saved: ${GlobalsVariables.vendorLoginToken}',
          );

          // 2. save vendor ID
          await GlobalsVariables.saveVendorId(vendorId);
          print('▶︎ vendorId saved: ${GlobalsVariables.vendorId ?? ''}');

          // 3. now navigate
          Get.snackbar('Success', 'Login successful!');
          Get.offAll(() => BottomNavBarScreen());
        } else {
          Get.snackbar('Error', 'Token not found in response');
        }
      } else {
        final body = response.body.trim();
        if (body.isNotEmpty && body.startsWith('{')) {
          final data = jsonDecode(body);
          Get.snackbar("Error", data['message'] ?? 'Login failed');
        } else {
          Get.snackbar("Error", 'Login failed. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }
}
