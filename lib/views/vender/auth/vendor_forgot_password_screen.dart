import 'package:beautician_app/utils/libs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/vendors/auth/vendor_forgot_password_controller.dart';

class VendorForgotPasswordScreen extends StatefulWidget {
  const VendorForgotPasswordScreen({super.key});

  @override
  State<VendorForgotPasswordScreen> createState() =>
      _VendorForgotPasswordScreenState();
}

class _VendorForgotPasswordScreenState
    extends State<VendorForgotPasswordScreen> {
  final VendorForgotPasswordController controller = Get.put(
    VendorForgotPasswordController(),
  );

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
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forgot password', style: kHeadingStyle),
            const SizedBox(height: 10),
            Text(
              'Please enter your email address to reset your password instruction',
              style: kSubheadingStyle,
            ),
            const SizedBox(height: 25),
            CustomTextField(
              hintText: "Email",
              controller: controller.emailController,
              inputType: TextInputType.emailAddress,
              prefixIcon: Image.asset('assets/email.png'),
            ),
            const SizedBox(height: 25),
            Obx(
              () =>
                  controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                        isEnabled: true,
                        title: "Continue",
                        onPressed: controller.forgotPassword,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
