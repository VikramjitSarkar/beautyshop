import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/users/auth/register_controller.dart'
    show AuthController;
import '../../../services/google_auth_service.dart';
import '../../../controllers/users/home/home_controller.dart';
import '../../../controllers/users/profile/profile_controller.dart';
import '../../user/custom_nav_bar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _passwordVisible = false;
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isDesktop =
            sizingInfo.deviceScreenType == DeviceScreenType.desktop;

        return Scaffold(
          backgroundColor: Colors.white,
          // appBar:
          //     isDesktop
          //         ? null
          //         : PreferredSize(
          //       preferredSize: Size.fromHeight(55),
          //       child: Padding(
          //         padding: EdgeInsets.symmetric(horizontal: padding),
          //         child: AppBar(
          //           surfaceTintColor: Colors.transparent,
          //           backgroundColor: Colors.white,
          //           leading: Row(
          //             children: [
          //               GestureDetector(
          //                 onTap: () => Get.back(),
          //                 child: SvgPicture.asset('assets/back icon.svg', height: 50,),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                width:
                    isDesktop
                        ? MediaQuery.of(context).size.width * 0.5
                        : double.infinity,
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      GestureDetector(
                        onTap: () => Get.back(),
                        child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                      ),
                      Center(
                        child: Image.asset(
                          'assets/app icon 2.png',
                        ),
                      ),
                      Text(
                        'Join TheBeautyShop Community!\nCreate your free account and start exploring beauty services that come to you. Whether it\'s makeup, hair, nails, or skincare, the perfect specialist is just a tap away.',
                        style: kSubheadingStyle,
                      ),
                      const SizedBox(height: 20),

                      // Name
                      CustomTextField(
                        hintText: "Name",
                        controller: nameController,
                        inputType: TextInputType.text,
                        prefixIcon: Image.asset('assets/men.png'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Email
                      CustomTextField(
                        hintText: "Email",
                        controller: emailController,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Image.asset('assets/email.png'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!GetUtils.isEmail(value.trim()) || value.trim().contains(RegExp(r'[A-Z]'))) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Password
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

                      const SizedBox(height: 8),

                      // Phone
                      const SizedBox(height: 8),

                      // Location (Optional)
                      // CustomTextField(
                      //   hintText: "Location (Optional)",
                      //   controller: locationController,
                      //   inputType: TextInputType.text,
                      //   prefixIcon: Icon(Icons.location_on),
                      // ),
                      const SizedBox(height: 20),

                      // Sign up button
                      Obx(
                        () => CustomButton(
                          isEnabled: !authController.isLoading.value,
                          title:
                              authController.isLoading.value
                                  ? "Signing up..."
                                  : "Sign up",
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authController.registerUser(
                                userName: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                phone: phoneController.text.trim(),
                                location:
                                    locationController.text.trim().isEmpty
                                        ? null
                                        : locationController.text.trim(),
                              );

                              await GlobalsVariables.loadToken();
                            } else {
                              Get.snackbar(
                                'Validation',
                                'Please fix errors to continue',
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Image.asset('assets/line.png')),
                          const SizedBox(width: 5),
                          Text('or', style: kSubheadingStyle),
                          const SizedBox(width: 5),
                          Expanded(child: Image.asset('assets/line.png')),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Google Sign-In Button
                      _isGoogleLoading
                          ? Center(child: CircularProgressIndicator())
                          : GestureDetector(
                              onTap: _handleGoogleSignIn,
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/google.png',
                                      height: 24,
                                      width: 24,                                    color: Colors.black,                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: kSubheadingStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 30),

                      // Sign in redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: kSubheadingStyle,
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () => Get.to(() => SignInScreen()),
                            child: Text(
                              'Sign in',
                              style: kHeadingStyle.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle();
      
      if (result != null && result['status'] == 'success') {
        final userData = result['data'];
        final token = result['token'];
        
        // Save token
        await GlobalsVariables.saveToken(token);
        await GlobalsVariables.loadToken();
        
        // Initialize controllers with the logged-in user data
        Get.put(HomeController());
        Get.put(UserProfileController());
        
        // Navigate to home screen
        await Get.offAll(() => CustomerBottomNavBarScreen());
        
        Get.snackbar(
          'Success',
          'Account created with Google successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to sign up with Google',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign In failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }
}
