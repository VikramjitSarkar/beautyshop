import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/views/user/nav_bar_screens/home/salon_services_card2.dart';
import 'package:beautician_app/views/widgets/salon_about_card.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

class SaloonDetailPageScreen extends StatefulWidget {
  final String vendorId;
  final String phoneNumber;
  final String title;
  final List<dynamic> galleryImage;
  final String shopeName;
  final String desc;
  final String userName;
  final String imageUrl;
  final String status;
  final String locaion;
  final String longitude;
  final String latitude;
  final double rating;
  final Map<String, dynamic> openingTime;

  const SaloonDetailPageScreen({
    super.key,
    required this.phoneNumber,
    required this.rating,
    required this.galleryImage,
    required this.longitude,
    required this.latitude,
    required this.vendorId,
    required this.desc,
    required this.imageUrl,
    required this.locaion,
    required this.openingTime,
    required this.shopeName,
    required this.status,
    required this.title,
    required this.userName,
  });

  @override
  State<SaloonDetailPageScreen> createState() => _SaloonDetailPageScreenState();
}

class _SaloonDetailPageScreenState extends State<SaloonDetailPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Gallery : ${widget.galleryImage}");

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isDesktop =
            sizingInfo.deviceScreenType == DeviceScreenType.desktop;

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 380,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: SaloonDetailPageAppBar(
                        rating: widget.rating,
                        vendorLat: widget.latitude,
                        vendorLong: widget.longitude,
                        vendorId: widget.vendorId,
                        desc: widget.desc,
                        imageUrl: widget.imageUrl,
                        locaion: widget.locaion,
                        openingTime: widget.openingTime,
                        shopeName: widget.shopeName,
                        status: widget.status,
                        title: widget.title,
                        userName: widget.userName,
                      ),
                    ),
                  ),
                ],
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                children: [
                  /// ✅ TabBar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: kPrimaryColor,
                    tabAlignment: TabAlignment.start,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: "About"),
                      Tab(text: "Services"),
                      Tab(text: "Gallery"),
                      Tab(text: "Reviews"),
                    ],
                  ),

                  /// ✅ TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        buildScrollView(
                          SalonAboutCard(phonenumber: widget.phoneNumber,
                            des: widget.desc,
                            location: widget.locaion,
                            openingTime: widget.openingTime,
                            title: widget.title,
                            vendorId: widget.vendorId,
                          ),
                        ),
                        buildScrollView(
                          isDesktop
                              ? SalonServicesCard2(vedorId: widget.vendorId)
                              : SalonServicesCard(vedorId: widget.vendorId, status: widget.status,),
                        ),
                        buildScrollView(
                          SalonGalleryCard(galleryMedia: widget.galleryImage),
                        ),
                        SalonReviewCard(vendorId: widget.vendorId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildScrollView(Widget child) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: child,
    );
  }
}
