import 'package:beautician_app/constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/controllers/vendors/dashboard/servicesController.dart';
import 'package:beautician_app/controllers/vendors/auth/add_services_controller.dart';

class EditServiceScreen extends StatefulWidget {
  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final addCtrl = Get.put(AddServicesController());
  final servCtrl = Get.put(ServicesController());
  final chargeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCategoryId;
  String? selectedSubcategoryId;
  late final Map<String, dynamic> service;

  @override
  void initState() {
    super.initState();
    service = Get.arguments as Map<String, dynamic>;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await addCtrl.categories();
    selectedCategoryId = service['categoryId']['_id']?.toString();
    chargeCtrl.text = service['charges']?.toString() ?? '';

    if (selectedCategoryId != null) {
      await addCtrl.fetchSubcategories(selectedCategoryId!);
      selectedSubcategoryId = service['subcategoryId']['_id']?.toString();
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    chargeCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategoryId == null || selectedSubcategoryId == null) {
      Get.snackbar(
        'Selection Required',
        'Please select both category and subcategory',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );

      return;
    }

    await servCtrl.updateService(
      serviceId: service['_id'].toString(),
      categoryId: selectedCategoryId!,
      subcategoryId: selectedSubcategoryId!,
      charges: chargeCtrl.text.trim(),
    );
   await addCtrl.fetchServicesByVendorId(GlobalsVariables.vendorId!);
    if (!servCtrl.isLoading.value) {
      Get.back();
      Get.snackbar(
        'Success',
        'Service updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: AppBar(
            backgroundColor: Colors.white,
            leading: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                ),
              ],
            ),
            title: const Text(
              "Edit Service",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700
              ),
            ),

          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Edit Service Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Update your service information below',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),

              // Category Dropdown
              // In your EditServiceScreen, modify the category dropdown section like this:

              // Category Dropdown
              Text(
                'Service Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Obx(() {
                if (addCtrl.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                }

                // Find the currently selected category in the list
                final selectedCategory = addCtrl.categories.firstWhere(
                  (c) => c['_id']?.toString() == selectedCategoryId,
                  orElse: () => {},
                );

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonFormField<String>(
                    value:
                        selectedCategory.isNotEmpty ? selectedCategoryId : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    hint: Text(
                      'Select Category',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                    items:
                        addCtrl.categories.map<DropdownMenuItem<String>>((c) {
                          final categoryId = c['_id']?.toString();
                          return DropdownMenuItem<String>(
                            value: categoryId,
                            child: Text(
                              c['name']?.toString() ?? '',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedCategoryId = v;
                        selectedSubcategoryId = null;
                      });
                      addCtrl.fetchSubcategories(v!);
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select a category' : null,
                  ),
                );
              }),
              SizedBox(height: 20),

              // Subcategory Dropdown
              // Subcategory Dropdown
              Text(
                'Service Subcategory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Obx(() {
                if (addCtrl.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                }

                if (addCtrl.subcategories.isEmpty) {
                  return SizedBox.shrink();
                }

                // Find the currently selected subcategory in the list
                final selectedSubcategory = addCtrl.subcategories.firstWhere(
                  (s) => s['_id']?.toString() == selectedSubcategoryId,
                  orElse: () => {},
                );

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonFormField<String>(
                    value:
                        selectedSubcategory.isNotEmpty
                            ? selectedSubcategoryId
                            : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    hint: Text(
                      'Select Subcategory',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                    items:
                        addCtrl.subcategories.map<DropdownMenuItem<String>>((
                          s,
                        ) {
                          final subcategoryId = s['_id']?.toString();
                          return DropdownMenuItem<String>(
                            value: subcategoryId,
                            child: Text(
                              s['name']?.toString() ?? '',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSubcategoryId = v;
                      });
                    },
                    validator:
                        addCtrl.subcategories.isNotEmpty
                            ? (value) =>
                                value == null
                                    ? 'Please select a subcategory'
                                    : null
                            : null,
                  ),
                );
              }),
              SizedBox(height: 20),

              // Charges Input
              Text(
                'Service Charges',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: chargeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter service charges',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service charges';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Obx(() {
                    return servCtrl.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'SAVE CHANGES',
                          style: kHeadingStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
