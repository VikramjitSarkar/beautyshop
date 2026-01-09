import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/vendor_appointment_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/dashboard_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/message/vendor_msg_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

class VendorBottomNavBarScreen extends StatefulWidget {
  const VendorBottomNavBarScreen({super.key});

  @override
  _VendorBottomNavBarScreenState createState() => _VendorBottomNavBarScreenState();
}

class _VendorBottomNavBarScreenState extends State<VendorBottomNavBarScreen> {
  int _selectedIndex = 0;

  final List<String> _icons = [
    'assets/home.png',
    'assets/booking.png',
    'assets/message.png',
  ];

  final List<String> _titles = ["Dashboard", "Appointments", "Messaging"];

  final List<Widget> _pages = [
    DashboardScreen(),
    VendorAppointmentScreen(),
    VendorMsgScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return WillPopScope(
          onWillPop: () async {
            if (_selectedIndex != 0) {
              setState(() {
                _selectedIndex = 0;
              });
              return false; // prevent exiting the app
            }
            return true; // allow default back behavior
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: _pages[_selectedIndex],
            bottomNavigationBar: SafeArea(
              child: Container(
                height: 72,
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            ),
          ),
        );
      },
    );
  }
}
