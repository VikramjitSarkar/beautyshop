import 'package:beautician_app/controllers/users/auth/ForgotPasswordController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:beautician_app/utils/libs.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ForgotPasswordController());

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
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
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
