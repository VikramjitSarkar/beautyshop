import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/controllers/vendors/dashboard/servicesController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/edit_service_screen.dart';
import 'package:beautician_app/views/widgets/premium_feature_dialogue.dart';
import '../../../controllers/vendors/auth/add_services_controller.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

final serviceController = Get.put(ServicesController());

class _AddServiceScreenState extends State<AddServiceScreen> {
  final AddServicesController controller = Get.put(AddServicesController());
  @override
  void initState() {
    super.initState();
    controller.fetchServicesByVendorId(GlobalsVariables.vendorId!);
  }

  @override
  Widget build(BuildContext context) {
    final DashBoardController dashCtl = Get.put(DashBoardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => BottomNavBarScreen()),
                    child: Text('Skip', style: kSubheadingStyle),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          final isPaid = dashCtl.listing.value == 'paid';
                          final isFreeWithNoServices =
                              dashCtl.listing.value == 'free' &&
                              controller.services.length == 0;

                          if (isPaid || isFreeWithNoServices) {
                            Get.to(() => AddServiceInputScreen())?.then((_) {
                              controller.fetchServicesByVendorId(
                                GlobalsVariables.vendorId!,
                              );
                            });
                          } else {
                            showPremiumFeatureDialog(context);
                          }
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: kPrimaryColor1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.services.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'No services found.',
                            style: kSubheadingStyle,
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              mainAxisExtent: 200,
                            ),
                        itemCount: controller.services.length,
                        itemBuilder: (context, index) {
                          final service = controller.services[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kGreyColor2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: kGreyColor2),
                                  ),
                                  child: Image.asset(
                                    'assets/${images2[index % images2.length]}.png', // fallback loop
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Charges: \$${service['charges']}",
                                  style: kHeadingStyle.copyWith(fontSize: 14),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service['categoryId']['name']
                                          .toString()
                                          .capitalize ??
                                      '',
                                  style: kSubheadingStyle.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  service['subcategoryId']['name']
                                          .toString()
                                          .capitalize ??
                                      '',
                                  style: kSubheadingStyle.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => EditServiceScreen(),
                                      arguments: service,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: kGreyColor2),
                                    ),
                                    child: Text(
                                      'Edit',
                                      style: kSubheadingStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              // Bottom continue button
              CustomButton(
                isEnabled: true,
                title: 'Continue',
                onPressed: () {
                  dashCtl.listing.value == 'free'
                      ? Get.offAll(() => BottomNavBarScreen())
                      : Get.to(() => ShowPlanForMonthlyOrYearScreen());
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(AddServicesController controller) {
    return GestureDetector(
      onTap: () async {
        await controller.fetchServicesByVendorId(
          GlobalsVariables.vendorLoginToken!,
        );
        await serviceController.fetchServices();
        Get.to(() => AddServiceInputScreen());
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kPrimaryColor.withOpacity(0.08),
          border: Border.all(color: kPrimaryColor, width: 2),
        ),
        child: Icon(Icons.add, size: 30, color: kPrimaryColor),
      ),
    );
  }
}
