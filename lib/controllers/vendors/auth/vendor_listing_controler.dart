// 📁 vendor_listing_controller.dart
import 'dart:convert';

import 'package:beautician_app/views/vender/auth/add_service_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../constants/globals.dart';

class VendorListingController extends GetxController {
  var isLoading = false.obs;

  Future<void> updateListingPlan(String plan, bool isService) async {
    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/update');

    final token = GlobalsVariables.vendorLoginToken;
    if (token == null) {
      isLoading.value = false;
      Get.snackbar('Error', 'Vendor token not found');
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
          'listingPlan': plan,
        }),
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Listing plan updated to "$plan"');
        if(isService){
          Get.to(() => AddServiceScreen());
        }else{

        }
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Update failed');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', e.toString());
    }
  }
}
