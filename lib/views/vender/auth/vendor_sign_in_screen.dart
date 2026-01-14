import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/services/google_auth_service.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'vendor_sign_up_screen.dart';

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
  bool _isGoogleLoading = false;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle(type: 'vendor');

      if (result != null && result['status'] == 'success') {
        final token = result['token'];
        final vendorData = result['user'] ?? result['data'];
        final vendorId = vendorData?['_id'];

        if (token != null) {
          await GlobalsVariables.saveVendorLoginToken(token);
        }
        if (vendorId != null) {
          await GlobalsVariables.saveVendorId(vendorId);
        }
        await GlobalsVariables.loadToken();

        await Get.offAll(() => VendorBottomNavBarScreen());

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
