import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/auth/vendor_sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class VendorResetPasswordController extends GetxController {
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();
  final isLoading = false.obs;

  void resetPassword() async {
    final token = tokenController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (token.isEmpty) {
      _showError("Token Missing", "Please enter the reset token from your email.");
      return;
    }

    if (newPassword.length < 6) {
      _showError("Weak Password", "Password must be at least 6 characters.");
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
        Get.snackbar(
          "Success",
          data['message'] ?? "Password updated successfully.",
          backgroundColor: kPrimaryColor,
          colorText: Colors.white,
        );
        Get.offAll(() =>  VendorSignInScreen());
      } else {
        _showError("Error", data['message'] ?? "Reset failed.");
      }
    } catch (e) {
      _showError("Error", "Something went wrong.");
      print("Reset password error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(title, message,
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  @override
  void onClose() {
    tokenController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
