import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/users/home/categoryController.dart'
    show CategoryController;
import 'book_appointment_screen.dart';

class SalonServicesCard2 extends StatefulWidget {
  final String vedorId;
  final String shopName;
  final String shopAddress;

  const SalonServicesCard2({super.key, required this.vedorId, required this.shopName, required this.shopAddress});

  @override
  State<SalonServicesCard2> createState() => _SalonServicesCardState();
}

class _SalonServicesCardState extends State<SalonServicesCard2> {
  final Map<int, String> selectedServices = {}; // Tracks selected service _ids
  final Map<int, double> selectedPrices = {};
  final CategoryController _catCtrl = Get.put(CategoryController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _catCtrl.fetchAndStoreServicesByVendorId(widget.vedorId);
    });
  }

  List<Map<String, dynamic>> getSelectedServices() {
    final List<Map<String, dynamic>> result = [];

    selectedServices.forEach((serviceIndex, serviceId) {
      // Ensure we're using the integer index correctly
      if (serviceIndex < _catCtrl.vendorServices.length) {
        final service = _catCtrl.vendorServices[serviceIndex];
        result.add({
          "serviceId": service['_id'], // Use the direct _id from service
          "serviceName": service['subcategoryId']['name'],
          "price":
              selectedPrices[serviceIndex] ??
              double.tryParse(service['charges']) ??
              0.0,
          "categoryName": service['categoryId']['name'],
          "duration": service['duration'] ?? "45 min",
        });
      }
    });

    return result;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          // Services List
          Expanded(
            child: GetX<CategoryController>(
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final services = controller.vendorServices;

                if (services.isEmpty) {
                  return const Center(child: Text('No services available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: services.length,
                  itemBuilder: (context, idx) {
                    final service = services[idx];
                    final cat = service['categoryId'];
                    final isSel = selectedServices.containsKey(idx);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        height: isSel ? 84 : 54,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSel ? kPrimaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isSel ? Border.all(color: kPrimaryColor) : null,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              cat['name'],
                              style: kHeadingStyle.copyWith(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isSel) ...[
                                  Text(
                                    "\$${selectedPrices[idx]?.toStringAsFixed(2) ?? service['charges']}",
                                    style: kSubheadingStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    service['subcategoryId']['name'],
                                    style: kSubheadingStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ] else
                                  GestureDetector(
                                    onTap: () {
                                      showCustomBottomSheet(
                                        context,
                                        idx,
                                        service,
                                      );
                                    },
                                    child: const Text('View'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Book Buttons
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Book Later",
                    isEnabled: selectedServices.isNotEmpty,
                    onPressed: () {
                      final selected = getSelectedServices();
                      if (selected.isNotEmpty) {
                        Get.to(
                          () =>
                              GlobalsVariables.token != null
                                  ? BookAppointmentScreen(
                                shopAddress: widget.shopAddress,
                                shopName: widget.shopName,
                                services: selected,
                                    vendorId: widget.vedorId,
                                  )
                                  : UserVendorScreen(),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    title: "Book now",
                    isEnabled: selectedServices.isNotEmpty,
                    onPressed: () {
                      final selected = getSelectedServices();
                      if (selected.isNotEmpty) {
                        Get.to(
                          () =>
                              GlobalsVariables.token != null
                                  ? BookAppointmentScreen(
                                shopAddress: widget.shopAddress,
                                shopName: widget.shopName,
                                services: selected,
                                    vendorId: widget.vedorId,
                                  )
                                  : UserVendorScreen(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCustomBottomSheet(
    BuildContext context,
    int serviceIndex,
    Map<String, dynamic> service,
  ) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.9;
    final cat = service['categoryId'];
    final sub = service['subcategoryId'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder:
          (_) => StatefulBuilder(
            builder: (ctx, bottomSheetSetState) {
              bool isSelected = selectedServices.containsKey(serviceIndex);

              return Container(
                height: sheetHeight,
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat['name'],
                              style: kHeadingStyle.copyWith(fontSize: 18),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Icon(
                                Icons.close,
                                size: 24,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.grey[300]),
                        Expanded(
                          child: ListView(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  bottomSheetSetState(() {
                                    isSelected = !isSelected;

                                    if (isSelected) {
                                      // Store the service _id instead of subcategory id
                                      selectedServices[serviceIndex] =
                                          service['_id'];
                                      selectedPrices[serviceIndex] =
                                          double.tryParse(service['charges']) ??
                                          0.0;
                                    } else {
                                      selectedServices.remove(serviceIndex);
                                      selectedPrices.remove(serviceIndex);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sub['name'],
                                              style: kHeadingStyle.copyWith(
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              service['duration'] ?? "45 min",
                                              style: kSubheadingStyle,
                                            ),
                                            Text(
                                              "\$${service['charges']}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? kPrimaryColor.withOpacity(
                                                    0.2,
                                                  )
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? kPrimaryColor
                                                    : Colors.grey,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            isSelected
                                                ? Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: kPrimaryColor,
                                                )
                                                : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: CustomButton(
                        title: "Done",
                        isEnabled: true,
                        onPressed: () {
                          setState(() {});
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
