import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/map/map_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/profile_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;

  final List<String> _icons = [
    'assets/home.png',
    'assets/discover.png',
    'assets/booking.png',
    'assets/message.png',
    'assets/more.png',
  ];

  final List<String> _titles = [
    "Home",
    "Discover",
    "Booking",
    "Message",
    "Profile",
  ];

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(),
    YourAppointmentScreen(),
    MessageScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Get.put(HomeController());
      }
    });
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
                    width: 100,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_icons.length, (index) {
                        bool isSelected = index == _selectedIndex;
                        return GestureDetector(
                          onTap: () => _onItemTapped(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => UserVendorScreen());
                        },
                        child: Text(
                          'Please click to login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                    : _pages[_selectedIndex],
            bottomNavigationBar: Container(
              height: 72,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_icons.length, (index) {
                  bool isSelected = index == _selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Image.asset(
                        _icons[index],
                        width: 24,
                        height: 24,
                        color: isSelected ? Colors.black : kGreyColor,
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
