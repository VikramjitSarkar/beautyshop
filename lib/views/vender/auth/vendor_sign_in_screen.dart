import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../controllers/vendors/auth/vendor_login_controller.dart'
    show VendorLoginController;
import 'vendor_forgot_password_screen.dart';

class VendorSignInScreen extends StatefulWidget {
  VendorSignInScreen({super.key});
  final VendorLoginController loginController = Get.put(
    VendorLoginController(),
  );
  @override
  State<VendorSignInScreen> createState() => _VendorSignInScreenState();
}

class _VendorSignInScreenState extends State<VendorSignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String title = '';
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
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
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/app icon 2.png'),
                    Text(
                      'Welcome Back, Beauty Specialist!\nLog in to manage your bookings, update your services, and connect with new clients instantly. Keep growing your beauty business on the go.',
                        style: kSubheadingStyle
                    ),
                    SizedBox(height: 10,),
                    CustomTextField(
                      hintText: "Email",
                      controller: emailController,
                      inputType: TextInputType.text,
                      prefixIcon: Image.asset('assets/email.png'),
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Password",
                      controller: passwordController,
                      inputType: TextInputType.text,
                      prefixIcon: Image.asset('assets/password.png'),
                      obscureText: !isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => VendorForgotPasswordScreen());
                          },
                          child: Text(
                            'Forgot your password?',
                            style: kSubheadingStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Obx(
                      () => CustomButton(
                        isLoading: widget.loginController.isLoading.value,
                        isEnabled: !widget.loginController.isLoading.value,
                        title: "Sign in",
                        onPressed: () {
                          widget.loginController.loginVendor(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Image.asset('assets/line.png')),
                        SizedBox(width: 5),
                        Text('or', style: kSubheadingStyle),
                        SizedBox(width: 5),
                        Expanded(child: Image.asset('assets/line.png')),
                      ],
                    ),
                    SizedBox(height: 30),
                    ActionButton(
                      title: "Continue with Google",
                      onPressed: () {},
                      icon: 'google',
                    ),
                    SizedBox(height: 10),
                    ActionButton(
                      title: "Continue with Apple",
                      onPressed: () {},
                      icon: 'apple',
                    ),
                    SizedBox(height: 57),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: kSubheadingStyle,
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Get.to(() => VendorSignUpScreen()),
                          child: Text(
                            'Sign up',
                            style: kHeadingStyle.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
