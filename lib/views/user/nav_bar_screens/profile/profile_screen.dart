import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/auth_screens/phone_input_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/screens/change_password_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/screens/payment_method_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/about_us_screen.dart';
import 'package:get/get.dart';
import '../../../../controllers/users/profile/profile_controller.dart';
import '../../../onboarding/user_vender_screen.dart';
import 'screens/about_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileController profileController = Get.put(
    UserProfileController(),
  );

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await profileController.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 270,
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: CustomClipPath(),
                        child: Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/image5.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image:
                                      profileController
                                              .imageUrl
                                              .value
                                              .isNotEmpty
                                          ? NetworkImage(
                                            profileController.imageUrl.value,
                                          )
                                          : const AssetImage(
                                                'assets/placeholder.png',
                                              )
                                              as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => EditProfileScreen());
                                    // Refresh data when returning from edit screen
                                    await profileController.fetchUserProfile();
                                  },
                                  child: Image.asset(
                                    'assets/edit.png',
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profileController.name.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileController.profession.value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: padding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            InkWell(
                              onTap: () => Get.to(() => NotificationsScreen()),
                              child: Image.asset(
                                'assets/bell_notification.png',
                                height: 44,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    children: [
                      // _buildSettingsTile(
                      //   'Payment Methods',
                      //   'assets/Payment Methods.png',
                      //   () => Get.to(() => const PaymentMethodScreen()),
                      // ),
                      const SizedBox(height: 5),
                      _buildSettingsTile(
                        'Favorite',
                        'assets/Favorite.png',
                        () => Get.to(() => const FavoriteScreen()),
                      ),
                      const SizedBox(height: 5),
                      _buildSettingsTile(
                        'Change Password',
                        'assets/Change Password.png',
                        () => Get.to(() => const ChangePasswordScreen()),
                      ),
                      profileController.phoneNumber.value.isNotEmpty
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone),
                                  Text('Verified Phone'),
                                ],
                              ),
                              Icon(Icons.verified),
                            ],
                          )
                          : _buildSettingsTile(
                            'Add Phone Number',
                            'assets/phone_outline.png',
                            () => Get.to(() => PhoneNumberInputScreen()),
                          ),
                      const SizedBox(height: 5),
                      // _buildSettingsTile(
                      //   'Invite Friends',
                      //   'assets/Invites Friends.png',
                      //   () => Get.to(() => InviteFriendsScreen()),
                      // ),
                      // const SizedBox(height: 5),
                      _buildSettingsTile(
                        'FAQs',
                        'assets/FAQs.png',
                        () => Get.to(() => const FaqScreen()),
                      ),
                      const SizedBox(height: 5),
                      _buildSettingsTile('About Us', 'assets/About Us.png', () {
                        Get.to(() => AboutUsScreens());
                      }),
                      const SizedBox(height: 5),
                      _buildSettingsTile(
                        'Log out',
                        'assets/Log out.png',
                        () async {
                          await GlobalsVariables.clearAllTokens();
                          Get.offAll(() => UserVendorScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String iconPath, VoidCallback onTap) {
    return ListTile(
      leading: Image.asset(iconPath, height: 24),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
