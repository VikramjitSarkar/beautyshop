import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';

import 'user/nav_bar_screens/appointment/tabs/userReviewScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Get.offAll(() => _determineInitialScreen());
    });
  
  }

  Widget _determineInitialScreen() {
       GlobalsVariables.loadToken();
    if (GlobalsVariables.bookingIdUser != null) {
      return ReviewScreen(
        bookingId: GlobalsVariables.bookingIdUser!,
        vendorId: GlobalsVariables.userVendorIdForBooking ?? "",
      );
    }

    // 2. Check for vendor login
    if (GlobalsVariables.vendorLoginToken != null) {
      return VendorBottomNavBarScreen();
    }

    // 3. Check for regular user login
    if (GlobalsVariables.token != null || GlobalsVariables.userId != null) {
      return CustomerBottomNavBarScreen();
    }

    // 4. Default fallback (should probably be a login screen)
    return CustomerBottomNavBarScreen(); // Or LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset('assets/app icon.png')],
        ),
      ),
    );
  }
}
