import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditAboutUsController extends GetxController {
  final descriptionController = TextEditingController();
  final additionalInfoController = TextEditingController();
  final RxBool isLoading = false.obs;
  DashBoardController dashBoardController = Get.find<DashBoardController>();
  final RxList<Map<String, dynamic>> openingHours = RxList([
    {'day': 'Monday - Friday', 'open': '8:30 AM', 'close': '9:30 PM'},
    {'day': 'Saturday - Sunday', 'open': '9:00 AM', 'close': '1:00 PM'},
  ]);

  void updateOpenCloseTime(int index, String newTime, bool isOpenTime) {
    if (index < openingHours.length) {
      final updated = Map<String, dynamic>.from(openingHours[index]);
      if (isOpenTime) {
        updated['open'] = newTime;
      } else {
        updated['close'] = newTime;
      }
      openingHours[index] = updated;
    }
  }

  Future<String?> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
    );

    if (picked != null) {
      return DateFormat(
        'h:mm a',
      ).format(DateTime(2023, 1, 1, picked.hour, picked.minute));
    }
    return null;
  }

  Future<void> updateOpenningime() async {
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/update');
    final token = GlobalsVariables.vendorLoginToken;

    if (token == null) {
      Get.snackbar('Error', 'Token not available');
      return;
    }

    isLoading.value = true;

    final body = jsonEncode({
      'description': descriptionController.text.trim(),
      'openingTime': {
        'weekdays': {
          'from': openingHours[0]['open'],
          'to': openingHours[0]['close'],
        },
        'weekends': {
          'from': openingHours[1]['open'],
          'to': openingHours[1]['close'],
        },
      },
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        // ✅ Show snackbar BEFORE navigating back
        Get.snackbar(
          'Success',
          'Time updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        await dashBoardController.fetchVendor();
        Get.back();
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Failed to update';
        Get.snackbar('Error', message);
      }
    } catch (e) {
      isLoading.value = false;
      print(e.toString());
      Get.snackbar('Exception', e.toString());
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    additionalInfoController.dispose();
    super.onClose();
  }
}
