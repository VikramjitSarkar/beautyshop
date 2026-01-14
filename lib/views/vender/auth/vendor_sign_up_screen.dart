// 📁 vendor_sign_up_screen.dart
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/services/google_auth_service.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../controllers/vendors/auth/verdor_register_controller.dart';
import 'beautician_profile_creation_screen.dart';

class VendorSignUpScreen extends StatefulWidget {
  const VendorSignUpScreen({super.key});

  @override
  State<VendorSignUpScreen> createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final VendorRegisterController vendorController = Get.put(
    VendorRegisterController(),
  );
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false; // <-- add this line at the top inside state
  bool _isGoogleLoading = false;

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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Image.asset('assets/app icon 2.png')),
                      Text(
                          'Become a Beauty Expert on TheBeautyShop!\nList your services, showcase your work, and grow your client base with our smart, location-based platform. Flexible plans, instant bookings, and full control at your fingertips.',
                          style: kSubheadingStyle
                      ),
                      SizedBox(height: 10,),

                      // Name Field (optional if not needed)
                      CustomTextField(
                        hintText: "Name",
                        controller: nameController,
                        inputType: TextInputType.text,
                        prefixIcon: const Icon(Icons.person, size: 28),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Email Field
                      CustomTextField(
                        hintText: "Email",
                        controller: emailController,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Image.asset('assets/email.png'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }

                          // Convert to lowercase for validation
                          final email = value.trim().toLowerCase();

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
                          );
                          if (!emailRegex.hasMatch(email)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Password Field
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
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Button
                      CustomButton(
                        isEnabled: true,
                        title: "Sign up",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            vendorController.setBasicInfo(
                              userName: nameController.text.trim(),
                              userEmail: emailController.text.trim(),
                              userPassword: passwordController.text.trim(),
                            );
                            Get.to(() => BeauticianProfileCreationScreen());
                          }
                        },
                      ),
                      const SizedBox(height: 30),

                      // Or Divider
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
                      const SizedBox(height: 25),

                      _isGoogleLoading
                          ? const Center(child: CircularProgressIndicator())
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
                      const SizedBox(height: 25),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: kSubheadingStyle,
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Text(
                              'Sign in',
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
