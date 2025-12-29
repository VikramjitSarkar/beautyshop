import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/map/map_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/profile_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

import 'nav_bar_screens/profile/screens/about_us_screen.dart';

class CustomerBottomNavBarScreen extends StatefulWidget {
  const CustomerBottomNavBarScreen({super.key});

  @override
  _CustomerBottomNavBarScreenState createState() => _CustomerBottomNavBarScreenState();
}

class _CustomerBottomNavBarScreenState extends State<CustomerBottomNavBarScreen> {
  int _selectedIndex = 0;

  final List<String> _icons = [
    'assets/home.png',
    'assets/discover.png',
    'assets/booking.png',
    'assets/message.png',
  ];

  final List<String> _titles = [
    "Home",
    "Discover",
    "Booking",
    "Message",
  ];

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(),
    YourAppointmentScreen(),
    MessageScreen(),

  ];

  void _onItemTapped(int index) {
    final previousIndex = _selectedIndex;
    setState(() {
      _selectedIndex = index;
    });
    
    // If switching to home tab from another tab, refresh location
    if (_selectedIndex == 0 && previousIndex != 0) {
      print('Switching to home tab - refreshing location data');
      try {
        final homeController = Get.find<HomeController>();
        homeController.refreshLocationData();
      } catch (e) {
        print('Error finding HomeController: $e');
        final homeController = Get.put(HomeController());
        homeController.refreshLocationData();
      }
    }
  }

  Future<bool> _onWillPop() async {
    // If not on home screen, navigate to home
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Prevent default back behavior
    }
    // If already on home screen, allow default back behavior
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            // desktop bottomNavi bar
            return Scaffold(
              body: Row(
                children: [
                  // Sidebar for Desktop
                  Container(
                    width: 60,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_icons.length, (index) {
                        bool isSelected = index == _selectedIndex;
                        return GestureDetector(
                          onTap: () => _onItemTapped(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              children: [
                                Center(
                                  child: Image.asset(
                                    _icons[index],
                                    width: 24,
                                    height: 24,
                                    color:
                                        isSelected ? Colors.black : kGreyColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _titles[index],
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.black : kGreyColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Main Content Area
                  Expanded(child: _pages[_selectedIndex]),
                ],
              ),
            );
          }

          // Mobile bottomNavi bar
          return Scaffold(
            backgroundColor: Colors.white,

            body:
                (_selectedIndex == 4 && GlobalsVariables.token == null)
                    ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/app icon 2.png'),
                            GestureDetector(
                              onTap: ()=> Get.to(()=> UserVendorScreen()),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),

                                ),
                                child: Text(
                                  "LOGIN/SIGNUP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800
                                  ),

                                ),
                              ),
                            ),
                            SizedBox(height: 10,),

                            _buildSettingsTile(
                              'FAQs',
                              'assets/FAQs.png',
                                  () => Get.to(() => const FaqScreen()),
                            ),
                            _buildSettingsTile('About Us', 'assets/About Us.png', () {
                              Get.to(() => AboutUsScreens());
                            }),
                                          ],
                                        ),
                      ),
                    )
                    : _pages[_selectedIndex],
              bottomNavigationBar: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF4F4F4), Color(0xFFEDEDED)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Color(0xFFE6E6E6), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_icons.length, (index) {
                    final isSelected = index == _selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _onItemTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          height: 56,
                          width: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFFB7FF79) : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isSelected ? 0.10 : 0.06),
                                blurRadius: isSelected ? 14 : 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              _icons[index],
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),



          );
        },
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

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}
