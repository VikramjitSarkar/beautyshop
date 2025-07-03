
import 'package:beautician_app/services/auths_service.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';


class PhoneVerificationScreen extends StatefulWidget {
  final String phone;

  const PhoneVerificationScreen({super.key, required this.phone});

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isCompleted = false;
  bool isVerifying = false;

  Future<void> _verifyCode() async {
    final code = _pinController.text.trim();

    setState(() => isVerifying = true);

    final isVerified = await _authService.verifyOtp(widget.phone, code);

    setState(() => isVerifying = false);

    if (isVerified) {
      Get.offAll(() => CustomerBottomNavBarScreen()); // Navigate to home/main
    } else {
      Get.snackbar('Error', 'Invalid or expired OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: AppBar(
            leading: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                ),
              ],
            ),
            // centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify code', style: kHeadingStyle),
            const SizedBox(height: 10),
            Text(
              'Please enter the 4-digit security code we just sent you at ${widget.phone}',
              style: kSubheadingStyle,
            ),
            const SizedBox(height: 24),

            // PIN input field
            Center(
              child: Pinput(
                length: 4,
                controller: _pinController,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: const Color(0xFFC0C0C0)),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? kPrimaryColor : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onCompleted: (pin) {
                  setState(() => isCompleted = true);
                },
                onChanged: (value) {
                  if (value.length < 4) {
                    setState(() => isCompleted = false);
                  }
                },
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t receive code?', style: kSubheadingStyle),
                Text(' Resend code', style: kHeadingStyle.copyWith(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),

            // Submit button
            GestureDetector(
              onTap: isCompleted && !isVerifying ? _verifyCode : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isCompleted ? kPrimaryColor : const Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCompleted ? kBlackColor : kGreyColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
