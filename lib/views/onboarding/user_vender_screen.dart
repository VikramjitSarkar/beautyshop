import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../utils/libs.dart';
import '../vender/auth/vendor_sign_in_screen.dart';

class UserVendorScreen extends StatelessWidget {
  
   UserVendorScreen({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/Ellipse 2.png'),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset('assets/Ellipse 3.png'),
            ),
            Center(
              child: SingleChildScrollView(
                // 👈 FIXED: prevents overflow
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserTypeCard(
                      title: "Join as User",
                      subTitle: "Find and Book Services",
                      image: "user",
                      onTap: () => Get.to(() => SignInScreen()),
                    ),
                    UserTypeCard(
                      title: "Join as Expert",
                      subTitle: "Manage your Business",
                      image: "beautician",
                      onTap: () => Get.to(() => VendorSignInScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserTypeCard extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  final VoidCallback onTap;
  const UserTypeCard({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/$image.jpg"), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(20),
                color: kPrimaryColor),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            subTitle,
            style: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.w600,
                color: kGreyColor),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                  color: kBlackColor, borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Get Started',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
