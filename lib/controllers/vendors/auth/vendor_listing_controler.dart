// 📁 vendor_listing_controller.dart
import 'dart:convert';

import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/views/vender/auth/add_service_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../constants/globals.dart';

class VendorListingController extends GetxController {
  var isLoading = false.obs;

  Future<void> redeemReferralCode(String referralCode) async {
    final vendorId = GlobalsVariables.vendorId;

    if (vendorId == null) {
      Get.snackbar('Error', 'Vendor ID not found');
      return;
    }

    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/referral/redeem');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vendorId': vendorId,
          'referralCode': referralCode,
        }),
      );

      isLoading.value = false;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', data['message'] ?? 'Referral code redeemed successfully! You got 3 months free subscription.');
        
        // Update DashboardController listing value to paid
        final dashCtrl = Get.put(DashBoardController());
        dashCtrl.listing.value = 'paid';
        
        // Navigate to AddServiceScreen after successful redemption
        Get.to(() => AddServiceScreen());
      } else {
        Get.snackbar('Error', data['message'] ?? 'Referral code redemption failed');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', e.toString());
    }
  }

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
        
        // Update DashboardController listing value immediately
        final dashCtrl = Get.put(DashBoardController());
        dashCtrl.listing.value = plan;
        
        if (isService) {
          // Only navigate to AddServiceScreen for free users
          Get.to(() => AddServiceScreen());
        }
        // For paid users, navigation is handled by StripeController after payment
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
