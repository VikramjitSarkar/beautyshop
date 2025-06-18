import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
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

  Future<void> registerUser({
    required String userName,
    required String email,
    required String password,
    required String phone,
    String? location,
  }) async {
    isLoading.value = true;
    final fcmToken = await _getFCMToken();
    if (fcmToken == null) {
      isLoading.value = false;
      Get.snackbar('Error', 'Notification services not available');
      return;
    }

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userName": userName,
          "email": email,
          "password": password,
          "phone": phone,
          "location": location,
          'fcmToken': fcmToken,
        }),
      );

      isLoading.value = false;
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        print(token);

        final userId = data['data']['_id'];
        print(userId);
        if (token != null) {
          await GlobalsVariables.saveToken(
            token,
          ); // ✅ Save in Globals + SharedPref
        }
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
        await GlobalsVariables.loadToken();
        Get.snackbar("Success", "Registered successfully!");
        Get.to(() => SkipPhoneNumberVerificationScreen());
      } else {
        final body = response.body.trim();

        if (body.isNotEmpty && body.startsWith('{')) {
          final data = jsonDecode(body);
          Get.snackbar("Error", data['message'] ?? 'Registration failed');
        } else {
          // Handle plain-text or empty error body
          Get.snackbar(
            "Error",
            'Registration failed. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    }
  }
}
