import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/auth_screens/phone_input_screen.dart';

class SkipPhoneNumberVerificationScreen extends StatefulWidget {
  @override
  _SkipPhoneNumberVerificationScreenState createState() =>
      _SkipPhoneNumberVerificationScreenState();
}

class _SkipPhoneNumberVerificationScreenState
    extends State<SkipPhoneNumberVerificationScreen> {
  bool isPhoneValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 10),
            GestureDetector(
              onTap: () => Get.back(),
              child: SvgPicture.asset('assets/back icon.svg'),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              // Handle skip action
              print('Skipped phone verification');
              Get.to(() => CustomNavBar());
            },
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: kBlackColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Verify your phone number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Verify your phone number for security and convenient communication with beauticians.',
              style: TextStyle(fontSize: 14, color: Color(0xFF989999)),
            ),
            const SizedBox(height: 32),

            // Custom Button
            CustomButton(
              onPressed: () {
                Get.to(() => PhoneNumberInputScreen());
              },
              title: "Verify",
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
