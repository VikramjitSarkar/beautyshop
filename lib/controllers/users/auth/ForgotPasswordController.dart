// controllers/forgot_password_controller.dart
import 'dart:convert';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../constants/globals.dart';


class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  var isLoading = false.obs;

  void forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('${GlobalsVariables.baseUrlapp}/user/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          data['message'] ?? "Reset link sent.",
          backgroundColor: kPrimaryColor,
          colorText: Colors.black,
        );
        Get.to(() => ResetPasswordScreen());
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Your email is not registered.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print("Forgot Password Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
