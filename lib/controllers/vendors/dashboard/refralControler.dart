import 'package:beautician_app/constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ReferralCodeController extends GetxController {
  final TextEditingController referralCodeController = TextEditingController();
  final isLoading = false.obs;

  Future<void> submitReferralCode() async {
    final referralCode = referralCodeController.text.trim();
    final vendorId = GlobalsVariables.vendorId;

    if (referralCode.isEmpty) {
      Get.snackbar('Error', 'Please enter a referral code',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (vendorId == null) {
      Get.snackbar('Error', 'Vendor ID not found',);
      return;
    }

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/referral/redeem');

    final body = {
      'vendorId': vendorId,
      'referralCode': referralCode,
    };

    try {
      isLoading.value = true;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final responseBody = json.decode(response.body);
      final message = responseBody['message'] ?? 'Unknown error';

      Get.snackbar(
        responseBody['status'] == 'error' ? 'Error' : 'Success',
        message,
      );
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong',);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    referralCodeController.dispose();
    super.onClose();
  }
}
