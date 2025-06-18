import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/widgets/premium_feature_dialogue.dart';
import 'package:get/get.dart';
import '../../../../../../controllers/vendors/auth/add_services_controller.dart';
// ✅ Your controller path
import 'edit_service_screen.dart';

class ServicesTabScreen extends StatefulWidget {
  const ServicesTabScreen({super.key});

  @override
  State<ServicesTabScreen> createState() => _ServicesTabScreenState();
}

class _ServicesTabScreenState extends State<ServicesTabScreen> {
  final AddServicesController controller = Get.put(AddServicesController());
  @override
  void initState() {
    super.initState();
    controller.fetchServicesByVendorId(GlobalsVariables.vendorId!);
  }

  @override
  Widget build(BuildContext context) {
    // Replace this with dynamic vendor ID if needed
    print(controller.services.length);
    final DashBoardController dashCtl = Get.put(DashBoardController());
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          CustomButton(
            title: "Add Service",
            isEnabled: true,
            onPressed: () {
              // ignore: prefer_is_empty
              dashCtl.listing.value == 'paid'
                  ? Get.to(() => AddServiceInputScreen())?.then((_) {
                    controller.fetchServicesByVendorId(
                      GlobalsVariables.vendorId!,
                    );
                  })
                  : dashCtl.listing.value == 'free' &&
                      controller.services.length < 1
                  ? Get.to(() => AddServiceInputScreen())?.then((_) {
                    controller.fetchServicesByVendorId(
                      GlobalsVariables.vendorId!,
                    );
                  })
                  : showPremiumFeatureDialog(context);
            },
          ),
          const SizedBox(height: 15),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.services.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('No services found.', style: kSubheadingStyle),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        service['categoryId']['name'].toString().capitalize ??
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
                          Get.to(() => EditServiceScreen(), arguments: service);
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
                          child: Text('Edit', style: kSubheadingStyle),
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
    );
  }
}
