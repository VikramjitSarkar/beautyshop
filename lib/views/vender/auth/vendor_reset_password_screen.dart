
import 'package:beautician_app/utils/libs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/vendors/auth/VendorResetPasswordController .dart';

class VendorResetPasswordScreen extends StatefulWidget {
  const VendorResetPasswordScreen({super.key});

  @override
  State<VendorResetPasswordScreen> createState() =>
      _VendorResetPasswordScreenState();
}

class _VendorResetPasswordScreenState extends State<VendorResetPasswordScreen> {
  final VendorResetPasswordController controller =
      Get.put(VendorResetPasswordController());

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset Password', style: kHeadingStyle),
              const SizedBox(height: 10),
              Text(
                'Enter the token from your email and your new password.',
                style: kSubheadingStyle,
              ),
              const SizedBox(height: 25),
              CustomTextField(
                hintText: "Reset Token",
                controller: controller.tokenController,
                inputType: TextInputType.text,
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: "New Password",
                controller: controller.newPasswordController,
                inputType: TextInputType.visiblePassword,
                prefixIcon: Image.asset('assets/password.png'),
              ),
              const SizedBox(height: 25),
              Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      isEnabled: true,
                      title: "Continue",
                      onPressed: controller.resetPassword,
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
