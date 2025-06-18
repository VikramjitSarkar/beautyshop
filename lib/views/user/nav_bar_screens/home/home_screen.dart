import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/constants/image.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/controllers/users/services/service_controller.dart';
import 'package:beautician_app/models/SalonCategoryModel.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/home/salon_list_screen.dart';
import 'package:beautician_app/views/widgets/saloon_card_three.dart';
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

  // };
  @override
  void initState() {
    super.initState();
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
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(160),
              child: CustomAppBar(title: 'My Custom AppBar'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: Obx(() {
                        if (userServicesController.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (userServicesController.subcategoryList.isEmpty) {
                          return Center(child: Text('No services available'));
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
                                GlobalsVariables.token == null
                                    ? Get.to(() => UserVendorScreen())
                                    : SalonSpecialistDetailScreen(
                                      vendorId: vendor['_id'].toString(),
                                    );
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
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(title: 'My Custom AppBar'),

                    SizedBox(
                      height: 120,
                      child: Obx(() {
                        if (userServicesController.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          );
                        }

                        if (userServicesController.subcategoryList.isEmpty) {
                          return Center(child: Text('No services available'));
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
                    SizedBox(height: 10),
                    Container(
                      height: 200,
                      width: double.maxFinite,
                      padding: EdgeInsets.only(
                        left: 15,
                        top: 20,
                        bottom: 8,
                        right: 8,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Text(
                                '25%',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Vourcher for you next\nhaircut service',
                                style: TextStyle(
                                  height: 1.2,
                                  fontSize: 14,
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
                                    vendorId: vendor['_id'].toString(),
                                  ),
                                );
                              },
                              onBook: () {
                                GlobalsVariables.token == null
                                    ? Get.to(() => UserVendorScreen())
                                    : SalonSpecialistDetailScreen(
                                      vendorId: vendor['_id'].toString(),
                                    );
                              },
                            );
                          },
                        );
                      }),
                    ),
                    Divider(color: kGreyColor),
                    SizedBox(height: 20),
                    Obx(() {
                      if (homeController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final categories = homeController.categoryData;

                      if (categories.isEmpty) {
                        return const Center(child: Text("No categories found"));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            categories.map((category) {
                              final vendorsRaw = category['vendors'];
                              final categoryName =
                                  category['categoryName'] ?? 'Unnamed';
                              print('CategoryName: $categories');
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
                              return SalonCategoryWidget(
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
