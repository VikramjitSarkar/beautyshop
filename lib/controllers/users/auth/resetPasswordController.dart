import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/views/user/auth_screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class ResetPasswordController extends GetxController {
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();
  var isLoading = false.obs;

  void resetPassword() async {
    final token = tokenController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (token.isEmpty) {
      Get.snackbar("Token Missing", "Please enter the reset token from your email.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar("Weak Password", "Password must be at least 6 characters.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse("${GlobalsVariables.baseUrlapp}/user/auth/password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"token": token, "newPassword": newPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message'] ?? "Password updated.",
            backgroundColor: kPrimaryColor, colorText: Colors.white);
        Get.offAll(() => SignInScreen());
      } else {
        Get.snackbar("Error", data['message'] ?? "Reset failed.",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      print("Reset password error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tokenController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
