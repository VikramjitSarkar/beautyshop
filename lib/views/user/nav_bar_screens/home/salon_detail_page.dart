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
  final String shopName;
  final String desc;
  final String userName;
  final String imageUrl;
  final String status;
  final String location;
  final String longitude;
  final String latitude;
  final double rating;
  final Map<String, dynamic> openingTime;
  final bool hasPhysicalShop;
  final bool homeServiceAvailable;
  final List<dynamic>? paymentMethods;

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
    required this.location,
    required this.openingTime,
    required this.shopName,
    required this.status,
    required this.title,
    required this.userName,
    required this.hasPhysicalShop,
    required this.homeServiceAvailable,
    this.paymentMethods,
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
        final hasSalon = widget.hasPhysicalShop == true;
        final hasHome = widget.homeServiceAvailable == true;
        final serviceTag = hasSalon && hasHome
            ? 'Home Visit & Salon Visit'
            : hasHome
                ? 'Home Service'
                : hasSalon
                    ? 'Salon Visit'
                    : null;

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    surfaceTintColor: Colors.transparent,
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
                        locaion: widget.location,
                        openingTime: widget.openingTime,
                        shopeName: widget.shopName,
                        status: widget.status,
                        title: widget.title,
                        userName: widget.userName,
                      ),
                    ),
                  ),
                ],
            body: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (serviceTag != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kPrimaryColor, width: 1),
                          boxShadow: kCardShadow,
                        ),
                        child: Text(
                          serviceTag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (widget.paymentMethods != null && widget.paymentMethods!.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Accepted Payment Methods:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.paymentMethods!.map((method) {
                              IconData icon;
                              String displayName;
                              
                              switch (method.toString().toLowerCase()) {
                                case 'paypal':
                                  icon = Icons.payment;
                                  displayName = 'PayPal';
                                  break;
                                case 'stripe':
                                  icon = Icons.credit_card;
                                  displayName = 'Stripe';
                                  break;
                                case 'razorpay':
                                  icon = Icons.account_balance_wallet;
                                  displayName = 'Razorpay';
                                  break;
                                case 'cash':
                                  icon = Icons.money;
                                  displayName = 'Cash';
                                  break;
                                case 'card':
                                  icon = Icons.credit_card_outlined;
                                  displayName = 'Card';
                                  break;
                                case 'bank_transfer':
                                  icon = Icons.account_balance;
                                  displayName = 'Bank Transfer';
                                  break;
                                default:
                                  icon = Icons.payment;
                                  displayName = method.toString();
                              }
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, size: 16, color: Colors.black87),
                                    const SizedBox(width: 6),
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                          SingleChildScrollView(
                            child: SalonAboutCard(phonenumber: widget.phoneNumber,
                              des: widget.desc,
                              location: widget.location,
                              openingTime: widget.openingTime,
                              title: widget.title,
                              vendorId: widget.vendorId,
                            ),
                          ),
                        ),
                        buildScrollView(
                          isDesktop
                              ? SalonServicesCard2(vedorId: widget.vendorId, shopName: widget.shopName, shopAddress: widget.location, hasPhysicalShop: widget.hasPhysicalShop, homeServiceAvailable: widget.homeServiceAvailable,)
                              : SalonServicesCard(vendorId: widget.vendorId, status: widget.status,shopName: widget.shopName, shopAddress: widget.location, hasPhysicalShop: widget.hasPhysicalShop, homeServiceAvailable: widget.homeServiceAvailable,),
                        ),
                        buildScrollView(
                          SingleChildScrollView(child: SalonGalleryCard(galleryMedia: widget.galleryImage)),
                        ),
                        SingleChildScrollView(child: SalonReviewCard(vendorId: widget.vendorId)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildScrollView(Widget child) {
    return child;
  }
}
