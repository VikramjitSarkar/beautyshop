import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../../utils/libs.dart';

class LoginController extends GetxController {
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

  Future<void> loginUser({
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

    print('Fmc Token : $fcmToken');
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          'fcmToken': fcmToken,
        }),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['data']['_id'];
        print(token);
        print(userId);

        // Wait for both save operations to complete
        await Future.wait([
          GlobalsVariables.saveToken(token),
          GlobalsVariables.saveUserId(userId),
        ]);
        await GlobalsVariables.loadToken();
        // ✅ Initialize HomeController
        if (Get.isRegistered<HomeController>()) {
          Get.delete<HomeController>();
        }
        if (Get.isRegistered<UserProfileController>()) {
          Get.delete<UserProfileController>();
        }
        Get.put(HomeController());
        Get.put(UserProfileController());
        // ✅ Navigate to home
        Get.offAll(() => CustomNavBar());
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
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    }
  }
}
