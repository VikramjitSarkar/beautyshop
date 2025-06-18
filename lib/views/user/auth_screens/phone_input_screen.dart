import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/services/auths_service.dart';
import 'phone_verification_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberInputScreen extends StatefulWidget {
  @override
  State<PhoneNumberInputScreen> createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSending = false;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || !phone.startsWith('+')) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number with country code.',
      );
      return;
    }

    setState(() => _isSending = true);

    final success = await _authService.sendOtp(phone);
    setState(() => _isSending = false);

    if (success) {
      Get.to(() => PhoneVerificationScreen(phone: phone));
    } else {
      Get.snackbar('Error', 'Failed to send OTP. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Get.back(),
              child: SvgPicture.asset('assets/back icon.svg'),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/app icon 2.png'),
              const SizedBox(height: 10),
              Text('Verify your phone number', style: kHeadingStyle),
              const SizedBox(height: 8),
              Text(
                'We’ll send a 4-digit verification code to your phone.',
                style: kSubheadingStyle,
              ),
              const SizedBox(height: 24),

              // Styled Phone Field
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                initialCountryCode: 'IN', // Default to Pakistan
                onChanged: (phone) {
                  _phoneController.text =
                      phone.completeNumber; // full phone with + code
                },
              ),

              const SizedBox(height: 24),

              // Send OTP button
              CustomButton(
                title: _isSending ? "Sending..." : "Send OTP",
                isEnabled: !_isSending,
                onPressed: _isSending ? null : _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
