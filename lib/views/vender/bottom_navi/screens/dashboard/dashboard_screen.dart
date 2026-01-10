import 'dart:io';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/about_us_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/gallery_tab_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/review_tab_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/services_tab_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/vendorNotificatioin.dart';
import 'package:beautician_app/views/widgets/premium_feature_dialogue.dart';
import 'package:beautician_app/views/widgets/rating_dialogue.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../../../../../controllers/vendors/dashboard/dashboardController.dart';
import '../../../../../controllers/vendors/dashboard/statusController.dart';
import 'setingsScreen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

final statusController = Get.put(StatusController());
final dashCtrl = Get.put(DashBoardController());

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> vendorReviews = [];

  @override
  void initState() {
    super.initState();
    dashCtrl.fetchVendor();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadVendorReviews();
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Exit App'),
                content: Text('Are you sure you want to close the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text('Yes', style: TextStyle(color: kPrimaryColor1)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void loadVendorReviews() async {
    vendorReviews = await dashCtrl.fetchVendorReviews(dashCtrl.vendorId.value);
    setState(() {}); // Refresh the UI
  }

  String getRatingEmoji() {
    final rating = double.tryParse(getAverageRating()) ?? 0.0;
    if (rating <= 1.0) return '😡';
    if (rating <= 2.0) return '🙁';
    if (rating <= 3.0) return '🙂';
    return '😃';
  }

  @override
  Widget build(BuildContext context) {
    print(GlobalsVariables.vendorId);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder:
                  (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      surfaceTintColor: Colors.transparent,
                      pinned: true,
                      expandedHeight: 390,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Dashboard',
                                      style: kHeadingStyle.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Get.to(() => VendorSettings());
                                          },
                                          icon: Icon(Icons.settings),
                                          padding: EdgeInsets.all(8),
                                          constraints: BoxConstraints(),
                                        ),
                                        GestureDetector(
                                          onTap:
                                              () =>
                                                  statusController
                                                      .toggleStatus(),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  statusController
                                                          .isOnline
                                                          .value
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.grey.withOpacity(
                                                        0.1,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    statusController
                                                            .isOnline
                                                            .value
                                                        ? Colors.green
                                                        : Colors.grey,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        statusController
                                                                .isOnline
                                                                .value
                                                            ? Colors.green
                                                            : Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  statusController
                                                          .isOnline
                                                          .value
                                                      ? 'Go Offline'
                                                      : 'Go Online',
                                                  style: kHeadingStyle.copyWith(
                                                    fontSize: 13,
                                                    color:
                                                        statusController
                                                                .isOnline
                                                                .value
                                                            ? Colors.green
                                                            : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Get.to(() => VendorNotificationsScreen());
                                          },
                                          icon: Icon(Icons.notification_add_outlined),
                                          padding: EdgeInsets.all(8),
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (picked != null) {
                                    await dashCtrl
                                        .updateVendorVerificationImage(
                                      verificationImage: File(
                                        picked.path,
                                      ),
                                      token:
                                      GlobalsVariables
                                          .vendorLoginToken!,
                                    );
                                  }
                                  // if (dashCtrl.listing.value == 'paid') {
                                  //   final picked = await ImagePicker()
                                  //       .pickImage(source: ImageSource.gallery);
                                  //   if (picked != null) {
                                  //     await dashCtrl
                                  //         .updateVendorVerificationImage(
                                  //           verificationImage: File(
                                  //             picked.path,
                                  //           ),
                                  //           token:
                                  //               GlobalsVariables
                                  //                   .vendorLoginToken!,
                                  //         );
                                  //   }
                                  // } else {
                                  //   showPremiumFeatureDialog(context);
                                  // }
                                },
                                child: Obx(() {
                                  final bannerUrl = dashCtrl.bannerImage.value;
                                  return Container(
                                    height: 185,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black12),
                                      image:
                                          bannerUrl.isNotEmpty
                                              ? DecorationImage(
                                                image: NetworkImage(bannerUrl),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        bannerUrl.isEmpty
                                            ? Center(
                                              child: Icon(
                                                Icons
                                                    .add_circle_outline_rounded,
                                                size: 50,
                                                color: Colors.black12,
                                              ),
                                            )
                                            : null,
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    final url = dashCtrl.profileImage.value;
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: kPrimaryColor.withOpacity(0.2),
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image:
                                              url.isNotEmpty
                                                  ? NetworkImage(url)
                                                  : AssetImage(
                                                        'assets/layers.png',
                                                      )
                                                      as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Obx(
                                              () => Text(
                                                dashCtrl
                                                        .vendorName
                                                        .value
                                                        .isNotEmpty
                                                    ? dashCtrl.vendorName.value
                                                    : '—',
                                                style: kHeadingStyle.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Text(
                                                    getAverageRating(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    getRatingEmoji(),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Obx(
                                          () => Text(
                                            dashCtrl.shopeName.value.isNotEmpty
                                                ? dashCtrl.shopeName.value
                                                : '—',
                                            style: kSubheadingStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48),
                        child: Container(
                          color: Colors.white,
                          child: TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: kPrimaryColor,
                            unselectedLabelColor: kGreyColor,
                            indicatorColor: kPrimaryColor,
                            indicatorWeight: 2,
                            tabs: const [
                              Tab(text: 'About Us'),
                              Tab(text: 'Services'),
                              Tab(text: 'Gallery'),
                              Tab(text: 'Review'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
              body: TabBarView(
                children: [
                  AboutUsScreen(),
                  ServicesTabScreen(),
                  GalleryTabScreen(),
                  ReviewTabScreen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getAverageRating() {
    if (vendorReviews.isEmpty) return '0.0';

    double total = 0;
    for (var review in vendorReviews) {
      total += (review['rating'] ?? 0).toDouble();
    }
    final average = total / vendorReviews.length;
    return average.toStringAsFixed(1);
  }
}
