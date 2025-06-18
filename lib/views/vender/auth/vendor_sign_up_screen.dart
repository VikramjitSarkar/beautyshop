// 📁 vendor_sign_up_screen.dart
import 'package:beautician_app/utils/libs.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../controllers/vendors/auth/verdor_register_controller.dart';

class VendorSignUpScreen extends StatefulWidget {
  const VendorSignUpScreen({super.key});

  @override
  State<VendorSignUpScreen> createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final VendorRegisterController vendorController = Get.put(
    VendorRegisterController(),
  );

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false; // <-- add this line at the top inside state

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: SvgPicture.asset('assets/back icon.svg'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Image.asset('assets/app icon 2.png'),
                      const SizedBox(height: 8),

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
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
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
                      const SizedBox(height: 30),

                      // Google / Apple Buttons
                      ActionButton(
                        title: "Continue with Google",
                        onPressed: () {},
                        icon: 'google',
                      ),
                      const SizedBox(height: 10),
                      ActionButton(
                        title: "Continue with Apple",
                        onPressed: () {},
                        icon: 'apple',
                      ),

                      const SizedBox(height: 57),

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
}
