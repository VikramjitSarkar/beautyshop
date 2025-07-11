import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/refralScreen.dart';

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
              ],
            ),
          ),
        );
      },
    );
  }
}
