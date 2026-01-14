import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/auth_screens/forgot_password_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/users/auth/login_controller.dart';
import '../../../services/google_auth_service.dart';
import '../../../controllers/users/home/home_controller.dart';
import '../../../controllers/users/profile/profile_controller.dart';
import '../../user/custom_nav_bar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = Get.put(LoginController());
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _passwordVisible = false;
  bool _isGoogleLoading = false;

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
                  : PreferredSize(
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
                    Center(child: Image.asset('assets/app icon 2.png')),
                    Text(
                      'Welcome Back to TheBeautyShop!\nDiscover top beauty specialists near you. Log in to book your favorite services, chat with experts, and manage your appointments effortlessly.',
                      style: kSubheadingStyle
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
                                    width: 24,                                  color: Colors.black,                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: kSubheadingStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(height: 30),
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
          'Signed in with Google successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to sign in with Google',
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
