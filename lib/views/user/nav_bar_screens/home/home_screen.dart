import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/constants/image.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/controllers/users/services/service_controller.dart';
import 'package:beautician_app/models/SalonCategoryModel.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/home/salon_list_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/home/top_specialist_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/profile_screen.dart';
import 'package:beautician_app/views/widgets/saloon_card_three.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../controllers/users/home/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userServicesController = Get.put(UserSubcategoryServiceController());
  final homeController = Get.put(HomeController());
  final profileController = Get.put(UserProfileController());

  String greetings = "";
  String asset = "";

  String getGreetingBasedOnTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      asset = "sun";
      return "Good morning";
    } else if (hour >= 12 && hour < 18) {
      asset = "sun";
      return "Good afternoon";
    } else {
      asset = "evening1";
      return "Good evening";
    }
  }

  void getTop3Vendors({
    required var nearbyVendors,
    required var nearbyCategoryData,
  }) {
    var topVendors = <Map<String, dynamic>>[].obs;

    // If nearbyVendors has 3 or fewer, return all
    if (nearbyVendors.length <= 3) {
      for (var vendor in nearbyVendors) {
        final vendorId = vendor['_id'].toString();

        for (var category in nearbyCategoryData) {
          if (category.containsKey('vendors')) {
            final vendorsList = category['vendors'] as List<dynamic>;

            final match = vendorsList.firstWhere(
              (v) => v['_id'].toString() == vendorId,
              orElse: () => null,
            );

            if (match != null) {
              topVendors.add({
                '_id': match['_id'],
                'profileImage': match['profileImage'] ?? '',
                'userName': match['userName'] ?? '',
                'shopRating':
                    double.tryParse(match['shopRating'].toString()) ?? 0.0,
              });
              break; // stop after first match
            }
          }
        }
      }
    } else {
      // Take top 3 vendors from the list
      final topVendorIds =
          nearbyVendors
              .take(3)
              .map((vendor) => vendor['_id'].toString())
              .toSet();

      final addedVendorIds = <String>{};

      for (var category in nearbyCategoryData) {
        if (category.containsKey('vendors')) {
          final vendorsList = category['vendors'] as List<dynamic>;

          for (var vendor in vendorsList) {
            final vendorId = vendor['_id'].toString();

            if (topVendorIds.contains(vendorId) &&
                !addedVendorIds.contains(vendorId)) {
              topVendors.add({
                '_id': vendor['_id'],
                'profileImage': vendor['profileImage'] ?? '',
                'userName': vendor['userName'] ?? '',
                'shopRating':
                    double.tryParse(vendor['shopRating'].toString()) ?? 0.0,
              });
              addedVendorIds.add(vendorId);
            }

            if (topVendors.length == 3) break;
          }
        }

        if (topVendors.length == 3) break;
      }
    }

    print("Top Vendors: $topVendors");

    Get.to(() => TopSpecialistScreen(vendors: topVendors));
  }

  // };
  @override
  void initState() {
    super.initState();
    greetings = getGreetingBasedOnTime();
    userServicesController.fetchSubcategories();
    GlobalsVariables.loadToken();
  }

  @override
  Widget build(BuildContext context) {
    GlobalsVariables.loadToken();
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        //desktop responsive screen code
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Scaffold(
            backgroundColor: Colors.white,

            // appBar: PreferredSize(
            //   preferredSize: Size.fromHeight(160),
            //   child: CustomAppBar(title: 'My Custom AppBar', greetings: greetings,),
            // ),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(55),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Image.asset("assets/$asset.png", height: 30, width: 30),
                    SizedBox(width: 5),
                    // Text(
                    //   "$greetings,",
                    //   style: kHeadingStyle.copyWith(fontSize: 20),
                    // ),
                  ],
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (GlobalsVariables.token == null) {
                        Get.to(() => UserVendorScreen());
                      } else {
                        Get.to(() => NotificationsScreen());
                      }
                    },
                    child: Row(
                      children: [
                        GlobalsVariables.token == null
                            ? SizedBox()
                            : Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xffC0C0C0),
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: SvgPicture.asset(
                                'assets/notification.svg',
                              ),
                            ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: kGreyColor2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: GestureDetector(
                      onTap: () => Get.to(() => ProfileScreen()),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/menu.svg'),
                          SizedBox(width: 5),
                          Text(
                            "menu",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: kGreyColor2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                ],
              ),
            ),

            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(title: 'My Custom AppBar'),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: Obx(() {
                        if (userServicesController.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (userServicesController.subcategoryList.isEmpty) {
                          return Center(
                            child: Text(
                              'No services available',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kGreyColor2,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: 2,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final service =
                                userServicesController.subcategoryList[index];

                            // Safe image fetching
                            final imageUrl =
                                (index < subcateImage.length)
                                    ? images[index]
                                    : 'https://via.placeholder.com/150'; // default image

                            print('CategoryId: ${service.categoryId}');

                            return ServicesCard(
                              title: service.name,
                              categoryId: service.categoryId,
                              image: imageUrl,
                            );
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 350,
                      width: double.maxFinite,
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 20,
                        bottom: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: AssetImage('assets/Banner.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'up to',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Text(
                                '25%',
                                style: TextStyle(
                                  fontSize: 70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Vourcher for you next\nhaircut service',
                                style: TextStyle(
                                  height: 1.2,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Top specialist',
                      style: kHeadingStyle.copyWith(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: Obx(() {
                        if (homeController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeController.vendors.length,
                          itemBuilder: (context, index) {
                            final vendor = homeController.vendors[index];

                            return TopSpecialistCard(
                              imagePath: vendor['profileImage'] ?? '',
                              specialistName: vendor['userName'] ?? 'No Name',
                              onTap: () {
                                Get.to(
                                  () => SalonSpecialistDetailScreen(
                                    vendorId: vendor['_id'],
                                  ),
                                );
                              },
                              onBook: () {
                                if (GlobalsVariables.token == null) {
                                  Get.to(() => UserVendorScreen());
                                } else {
                                  Get.to(
                                    () => SalonSpecialistDetailScreen(
                                      vendorId: vendor['_id'],
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }),
                    ),
                    Divider(color: kGreyColor),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
        //mobile responsive screen code
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55),
            child: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Image.asset("assets/$asset.png", height: 30, width: 30),
                  SizedBox(width: 5),
                  Text(
                    "$greetings,",
                    style: kHeadingStyle.copyWith(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    if (GlobalsVariables.token == null) {
                      Get.to(() => UserVendorScreen());
                    } else {
                      Get.to(() => NotificationsScreen());
                    }
                  },
                  child: Row(
                    children: [
                      GlobalsVariables.token == null
                          ? SizedBox()
                          : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xffC0C0C0),
                              ),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: SvgPicture.asset('assets/notification.svg'),
                          ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => ProfileScreen()),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: kGreyColor2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/menu.svg'),
                        SizedBox(width: 5),
                        Text(
                          "Menu",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: kGreyColor2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(title: 'My Custom AppBar'),

                    //service categories
                    SizedBox(
                      height: 160,
                      child: Obx(() {
                        if (userServicesController.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          );
                        }

                        if (userServicesController.subcategoryList.isEmpty) {
                          return Center(
                            child: Text(
                              'No services available',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kGreyColor2,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: userServicesController.category.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final service =
                                userServicesController.category[index];

                            return ServicesCard(
                              title: service['name'] ?? 'Unnamed',
                              categoryId: service['_id'] ?? '',
                              image: subcateImage[index],
                            );
                          },
                        );
                      }),
                    ),
                    // SizedBox(height: 10),

                    //Ad Banner
                    // Container(
                    //   height: 200,
                    //   width: double.maxFinite,
                    //   padding: EdgeInsets.only(
                    //     left: 15,
                    //     top: 20,
                    //     bottom: 8,
                    //     right: 8,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(30),
                    //     image: DecorationImage(
                    //       image: AssetImage('assets/Banner.png'),
                    //       fit: BoxFit.fill,
                    //     ),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         'up to',
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //       Row(
                    //         spacing: 10,
                    //         children: [
                    //           Text(
                    //             '25%',
                    //             style: TextStyle(
                    //               fontSize: 40,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //           Text(
                    //             'Vourcher for you next\nhaircut service',
                    //             style: TextStyle(
                    //               height: 1.2,
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       Spacer(),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 20),

                    //Top Specialist List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Top specialist',
                          style: kHeadingStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: Obx(() {
                        if (homeController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (homeController.nearbyVendors.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Center(child: Text("No Specialists Found")),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              homeController.nearbyVendors.length <= 5
                                  ? homeController.nearbyVendors.length
                                  : 5,
                          itemBuilder: (context, index) {
                            final vendor = homeController.nearbyVendors[index];
                            print("object");
                            print(
                              "these are vendors: ${homeController.nearbyVendors}",
                            );

                            return TopSpecialistCard(
                              imagePath: vendor['profileImage'] ?? '',
                              specialistName: vendor['userName'] ?? 'No Name',
                              onTap: () {
                                Get.to(
                                  () => SalonSpecialistDetailScreen(
                                    vendorId: vendor['_id'].toString(),
                                  ),
                                );
                              },
                              onBook: () {
                                GlobalsVariables.token == null
                                    ? Get.to(() => UserVendorScreen())
                                    : Get.to(
                                      () => SalonSpecialistDetailScreen(
                                        vendorId: vendor['_id'].toString(),
                                      ),
                                    );
                              },
                            );
                          },
                        );
                      }),
                    ),
                    // Divider(color: kGreyColor),
                    // SizedBox(height: 20),
                    Obx(() {
                      if (homeController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final categories = homeController.nearbyCategoryData;

                      if (homeController.nearbyCategoryData.isEmpty) {
                        return const Center(child: Text("No categories found"));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            categories.map((category) {
                              final vendorsRaw = category['vendors'];
                              final categoryName =
                                  category['categoryName'] ?? 'Unnamed';
                              final categoryId = category['_id'] ?? 'Unnamed';
                              print('CategoryName: $categories $categoryId');
                              // Make sure vendorsRaw is a List
                              if (vendorsRaw == null || vendorsRaw is! List) {
                                return const SizedBox.shrink();
                              }

                              final vendors =
                                  vendorsRaw
                                      .where(
                                        (v) =>
                                            v != null &&
                                            v is Map<String, dynamic>,
                                      )
                                      .cast<Map<String, dynamic>>()
                                      .toList();

                              print("vendors data $vendors");
                              return SalonCategoryWidget(
                                categoryId: categoryId,
                                title: categoryName,
                                vendors: vendors,
                                screen: NearestSalonScreen(),
                              );
                            }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
