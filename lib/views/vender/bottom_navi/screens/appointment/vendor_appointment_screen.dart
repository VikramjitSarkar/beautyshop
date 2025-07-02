import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/past_tab_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/request_tab_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/upcoming_tab_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';

class VendorAppointmentScreen extends StatefulWidget {
  const VendorAppointmentScreen({super.key});

  @override
  State<VendorAppointmentScreen> createState() =>
      _VendorAppointmentScreenState();
}

class _VendorAppointmentScreenState extends State<VendorAppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                title: Text(
                  'Your appointments',
                  style: kHeadingStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
            
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    height: 54,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: kGreyColor2)),
                    child: TabBar(
                      padding: EdgeInsets.all(5),
                      labelColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: kGreyColor,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      tabs: [
                        Tab(text: "Request"),
                        Tab(text: "Upcoming"),
                        Tab(text: "Past"),
                      ],
                    ),
                  ),
                ),
              ),
              body: TabBarView(children: [
                RequestTabScreen(),
                VendorUpcomingTabScreen(),
                VendorPastTabScreen(),
              ])),
        );
      },
    );
  }
}
