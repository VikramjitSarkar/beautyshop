import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/auth/show_plan_for_monthly_or_year_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PaymentMethodController extends GetxController {
  var selectedMethods = <String>[].obs;
  var isLoading = false.obs;

  void toggleMethod(String method) {
    if (selectedMethods.contains(method)) {
      selectedMethods.remove(method);
    } else {
      selectedMethods.add(method);
    }
  }

  Future<void> submitPaymentMethods() async {
    if (selectedMethods.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/updatePaymentMethods');

    final token = GlobalsVariables.vendorLoginToken;
    if (token == null) {
      Get.snackbar('Error', 'Vendor token not found');
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'paymentMethods': selectedMethods.toList(),
        }),
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Payment methods saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kPrimaryColor,
          colorText: Colors.black,
        );
        Get.off(() => FreeAndPaidListingServicesScreen());
      } else {
        // Check if response is JSON or HTML
        String errorMessage = 'Failed to save payment methods';
        try {
          if (response.body.trim().startsWith('{') || response.body.trim().startsWith('[')) {
            final body = jsonDecode(response.body);
            errorMessage = body['message'] ?? errorMessage;
          } else {
            errorMessage = 'Server error (${response.statusCode}): Endpoint not found or returned HTML';
          }
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Exception',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadPaymentMethods() async {
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/get');

    final token = GlobalsVariables.vendorLoginToken;
    if (token == null) return;

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final methods = body['data']['paymentMethods'] as List<dynamic>?;
        if (methods != null) {
          selectedMethods.value = methods.cast<String>();
        }
      }
    } catch (e) {
      print('Error loading payment methods: $e');
    }
  }
}
