import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/auth_screens/forgot_password_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/users/auth/login_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = Get.put(LoginController());
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isDesktop =
            sizingInformation.deviceScreenType == DeviceScreenType.desktop;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
              isDesktop
                  ? null
                  : AppBar(
                    backgroundColor: Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: SvgPicture.asset('assets/back icon.svg'),
                      ),
                    ),
                  ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                width:
                    isDesktop
                        ? MediaQuery.of(context).size.width * 0.5
                        : double.infinity,
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      AppBar(
                        backgroundColor: Colors.white,
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: SvgPicture.asset('assets/back icon.svg'),
                          ),
                        ),
                      ),
                    Image.asset('assets/app icon 2.png'),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
                      style: kSubheadingStyle,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      hintText: "Email",
                      controller: emailController,
                      inputType: TextInputType.text,
                      prefixIcon: Image.asset('assets/email.png'),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Password",
                      controller: passwordController,
                      inputType: TextInputType.visiblePassword,
                      prefixIcon: Image.asset('assets/password.png'),
                      obscureText: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        if (value.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Get.to(() => ForgotPasswordScreen());
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
                        isEnabled: !loginController.isLoading.value,
                        title:
                            loginController.isLoading.value
                                ? "Signing in..."
                                : "Sign in",
                        onPressed: () {
                          loginController.loginUser(
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
                        Text("Don't have an account?", style: kSubheadingStyle),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () async {
                            await Get.to(() => SignupScreen());
                            await GlobalsVariables.loadToken();
                          },
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
