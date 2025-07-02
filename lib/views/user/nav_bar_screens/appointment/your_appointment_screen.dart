import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/pastUserBookingController.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/pending_booking.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/qr_view_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

class YourAppointmentScreen extends StatefulWidget {
  const YourAppointmentScreen({super.key});

  @override
  State<YourAppointmentScreen> createState() => _YourAppointmentScreenState();
}

class _YourAppointmentScreenState extends State<YourAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() async {
    if (_tabController.indexIsChanging) return;

    // Index 2 is "Past"
    if (_tabController.index == 2) {
      await GlobalsVariables.loadToken();
      PastBookingController().fetchPastBookings();
      print("Token loaded on Past tab open");
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isDesktop =
            sizingInformation.deviceScreenType == DeviceScreenType.desktop;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: _buildAppBarTitle(),
              actions: isDesktop ? [] : [],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: _buildTabBar(),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                UserpendingBookingscreen(),
                UpcomingTabScreen(),
                const PastTabScreen(), // token loads before this
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kGreyColor2),
      ),
      child: TabBar(
        controller: _tabController,
        padding: const EdgeInsets.all(5),
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: kGreyColor,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        tabs: const [
          Tab(text: "Pending"),
          Tab(text: "Upcoming"),
          Tab(text: "Past"),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Text(
      'Your appointments',
      style: kHeadingStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}
