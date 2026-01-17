import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/refralScreen.dart';
import 'package:beautician_app/views/vender/auth/payment_method_selection_screen.dart';
import 'package:beautician_app/views/user/custom_nav_bar.dart';
import 'package:http/http.dart' as http;

import 'package:responsive_builder/responsive_builder.dart';

import '../../../../onboarding/user_vender_screen.dart';
import 'cancel_subscription_planScreen.dart';
import 'vendor_profile_screen.dart';

class VendorSettings extends StatelessWidget {
  const VendorSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: AppBar(
                backgroundColor: Colors.white,
                leading: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                ListTile(
                  title: Text("Switch to User"),
                  leading: Icon(Icons.swap_horiz),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  onTap: () {
                    Get.offAll(() => CustomerBottomNavBarScreen());
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Referral Code"),
                  leading: Icon(Icons.real_estate_agent),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  onTap: () {
                    Get.to(() => ReferralCodeScreen());
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Profile Settings"),
                  leading: Icon(Icons.person_2_outlined),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  onTap: () {
                    Get.to(
                      () => VendorDetailScreen(
                        vendorId: GlobalsVariables.vendorId!,
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Listing Plans"),
                  leading: Icon(Icons.person_2_outlined),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  onTap: () {
                    Get.to(() => CancelShowPlanForMonthlyOrYearScreen());
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Payment Methods"),
                  leading: Icon(Icons.payment),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  onTap: () {
                    Get.to(() => const PaymentMethodSelectionScreen());
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Logout"),
                  leading: Icon(Icons.logout),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  onTap: () async {
                    await GlobalsVariables.clearAllTokens();
                    Get.delete<DashBoardController>();
                    Get.offAll(() => SplashScreen());
                  },
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text("Delete Account", style: TextStyle(color: Colors.red)),
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  onTap: () async {
                    final confirm = await Get.dialog<bool>(
                      AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 28),
                            SizedBox(width: 12),
                            Text('Delete Account'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Are you sure you want to delete your account?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                '⚠️ All your data will be permanently lost and cannot be recovered by any means.',
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Delete', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        // Show loading
                        Get.dialog(
                          Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        final response = await http.delete(
                          Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/delete'),
                          headers: {
                            'Authorization': 'Bearer ${GlobalsVariables.vendorLoginToken}',
                            'Accept': 'application/json',
                          },
                        );

                        Get.back(); // Close loading dialog

                        if (response.statusCode == 200) {
                          await GlobalsVariables.clearAllTokens();
                          Get.delete<DashBoardController>();
                          Get.offAll(() => SplashScreen());
                          Get.snackbar(
                            'Account Deleted',
                            'Your account has been permanently deleted',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to delete account. Please try again.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.back(); // Close loading dialog
                        Get.snackbar(
                          'Error',
                          'Something went wrong: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
