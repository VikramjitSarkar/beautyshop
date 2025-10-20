import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:beautician_app/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/users/home/categoryController.dart'
    show CategoryController;
import 'book_appointment_screen.dart';

class SalonServicesCard extends StatefulWidget {
  final String vendorId;
  final String status;
  final String shopName;
  final String shopAddress;

  const SalonServicesCard({
    super.key,
    required this.vendorId,
    required this.status,
    required this.shopName,
    required this.shopAddress,
  });

  @override
  State<SalonServicesCard> createState() => _SalonServicesCardState();
}

class _SalonServicesCardState extends State<SalonServicesCard> {
  /// Track selections by serviceId (stable even when UI reorders/groups)
  final Set<String> _selectedServiceIds = {};
  final Map<String, double> _selectedPrices = {};

  final CategoryController _catCtrl = Get.put(CategoryController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("SalonServicesCard initState for vendor: ${widget.vendorId}");
      await _catCtrl.fetchAndStoreServicesByVendorId(widget.vendorId);
      print("Fetched vendorServices: ${_catCtrl.vendorServices.length}");
      if (_catCtrl.vendorServices.isNotEmpty) {
        print("Sample service: ${_catCtrl.vendorServices.first}");
      }
    });
  }

  /// Build selected services payload in the shape your downstream screen expects
  List<Map<String, dynamic>> _buildSelectedPayload() {
    final list = <Map<String, dynamic>>[];
    final services = _catCtrl.vendorServices.whereType<Map<String, dynamic>>().toList();

    for (final s in services) {
      final id = "${s['_id']}";
      if (_selectedServiceIds.contains(id)) {
        list.add({
          "serviceId": id,
          "serviceName": s['subcategoryId']?['name'] ?? '',
          "price": _selectedPrices[id] ??
              double.tryParse("${s['charges']}") ??
              0.0,
          "categoryName": s['categoryId']?['name'] ?? '',
        });
      }
    }
    print("Selected payload: $list");
    return list;
  }

  /// Group vendorServices by category name to keep subcategories under their category
  Map<String, List<Map<String, dynamic>>> _groupByCategory(
      List<Map<String, dynamic>> services) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final s in services) {
      final categoryName = s['categoryId']?['name']?.toString() ?? 'Other';
      grouped.putIfAbsent(categoryName, () => []);
      grouped[categoryName]!.add(s);
    }
    print("Grouped categories count: ${grouped.length}");
    return grouped;
  }

  void _toggleSelection(Map<String, dynamic> service) {
    final id = "${service['_id']}";
    final price = double.tryParse("${service['charges']}") ?? 0.0;

    setState(() {
      if (_selectedServiceIds.contains(id)) {
        _selectedServiceIds.remove(id);
        _selectedPrices.remove(id);
      } else {
        _selectedServiceIds.add(id);
        _selectedPrices[id] = price;
      }
    });

    print("Toggled serviceId=$id selected=${_selectedServiceIds.contains(id)} "
        "currentSelectedCount=${_selectedServiceIds.length}");
  }

  @override
  Widget build(BuildContext context) {
    final canBookNow = _selectedServiceIds.isNotEmpty && widget.status == 'online';
    final canBookLater = _selectedServiceIds.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                title: "Book Later",
                isEnabled: canBookLater,
                onPressed: () {
                  final selected = _buildSelectedPayload();
                  if (selected.isNotEmpty) {
                    print("Book Later pressed. Services: $selected");
                    Get.to(
                          () => GlobalsVariables.token != null
                          ? BookAppointmentScreen(
                        shopAddress: widget.shopAddress,
                        shopName: widget.shopName,
                        services: selected,
                        vendorId: widget.vendorId,
                      )
                          :  UserVendorScreen(),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                title: "Book Now",
                isEnabled: canBookNow,
                onPressed: () {
                  final selected = _buildSelectedPayload();
                  if (selected.isNotEmpty && widget.status == 'online') {
                    print("Book Now pressed. Services: $selected");
                    Get.to(
                          () => GlobalsVariables.token != null
                          ? BookAppointmentScreen(
                        shopAddress: widget.shopAddress,
                        shopName: widget.shopName,
                        services: selected,
                        vendorId: widget.vendorId,
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
      body: GetX<CategoryController>(
        builder: (controller) {
          final services = controller.vendorServices.whereType<Map<String, dynamic>>().toList();
          print("Build -> vendorServices length: ${services.length}");

          if (services.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text("No services available"),
              ),
            );
          }

          final grouped = _groupByCategory(services);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grouped.entries.map((entry) {
                  final categoryName = entry.key;
                  final catServices = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _CategoryBlock(
                      categoryName: categoryName,
                      services: catServices,
                      isSelected: (service) => _selectedServiceIds.contains("${service['_id']}"),
                      onToggle: _toggleSelection,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Category section with a header and Urban Company–style service rows
class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    required this.categoryName,
    required this.services,
    required this.isSelected,
    required this.onToggle,
  });

  final String categoryName;
  final List<Map<String, dynamic>> services;
  final bool Function(Map<String, dynamic>) isSelected;
  final void Function(Map<String, dynamic>) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Text(
          categoryName,
          style: kHeadingStyle.copyWith(fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 10),

        // Service rows
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: services.map((service) {
              final subName = service['subcategoryId']?['name']?.toString() ?? 'Service';
              // final duration = service['duration']?.toString() ?? '45 min';
              final rawPrice = double.tryParse("${service['charges']}") ?? 0.0;
              final priceText = rawPrice.toStringAsFixed(
                rawPrice.truncateToDouble() == rawPrice ? 0 : 2,
              );
              final selected = isSelected(service);

              return InkWell(
                onTap: () => onToggle(service),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Custom round checkbox
                      _RoundCheck(selected: selected),
                      const SizedBox(width: 12),

                      // Name + duration
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subName,
                                style: kSubheadingStyle.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),

                      // Price
                      Text(
                        "\$$priceText",
                        style: kSubheadingStyle.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RoundCheck extends StatelessWidget {
  const _RoundCheck({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? kPrimaryColor.withOpacity(0.12) : Colors.transparent,
        border: Border.all(color: selected ? kPrimaryColor : Colors.grey),
        shape: BoxShape.circle,
      ),
      child: selected
          ? Icon(Icons.check, size: 16, color: kPrimaryColor)
          : null,
    );
  }
}
