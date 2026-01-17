import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/dashboard/servicesController.dart';
import 'package:beautician_app/utils/libs.dart';
import '../../../controllers/vendors/auth/add_services_controller.dart';

class AddServiceInputScreen extends StatefulWidget {
  const AddServiceInputScreen({super.key});

  @override
  State<AddServiceInputScreen> createState() => _AddServiceInputScreenState();
}

class _AddServiceInputScreenState extends State<AddServiceInputScreen> {
  final controller = Get.put(AddServicesController());
  final TextEditingController homeServiceChargeController =
      TextEditingController();

  String? selectedCategoryId;
  String? selectedSubcategoryId;
  final List<Map<String, dynamic>> services = [];
  final List<TextEditingController> priceControllers = [];

  @override
  void initState() {
    super.initState();
    final vendorId = GlobalsVariables.vendorId ?? '';
    if (vendorId.isNotEmpty) {
      controller.fetchServicesByVendorId(vendorId);
    }
  }

  @override
  void dispose() {
    homeServiceChargeController.dispose();
    for (var c in priceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void addServiceToList(
    String categoryId,
    String subId,
    String categoryName,
    String subName,
  ) {
    final alreadyExists = services.any(
      (s) => s['categoryId'] == categoryId && s['subcategoryId'] == subId,
    );

    if (!alreadyExists) {
      final priceController = TextEditingController(text: "0");
      setState(() {
        priceControllers.add(priceController);
        services.add({
          "categoryId": categoryId,
          "categoryName": categoryName,
          "subcategoryId": subId,
          "subcategoryName": subName,
          "priceController": priceController,
        });
      });
    } else {
      Get.snackbar(
        "Duplicate",
        "This service is already added",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitServices(BuildContext context) async {
    // Validate that all services have a price
    for (var service in services) {
      final price = service['priceController'].text.trim();
      if (price.isEmpty || price == '0' || double.tryParse(price) == null || double.tryParse(price)! <= 0) {
        Get.snackbar(
          "Error", 
          "Please enter a valid price for ${service['subcategoryName']}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }
    
    for (var service in services) {
      await controller.createService(
        createdBy: GlobalsVariables.vendorId ?? '',
        categoryId: service['categoryId'],
        subcategoryId: service['subcategoryId'],
        charges: service['priceController'].text.trim(),
      );
    }

    final serviceController =
        Get.isRegistered<ServicesController>()
            ? Get.find<ServicesController>()
            : Get.put(ServicesController(), permanent: true);

    await serviceController.fetchServices();
    Get.snackbar("Success", "All services added");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final serviceController =
        Get.isRegistered<ServicesController>()
            ? Get.find<ServicesController>()
            : Get.put(ServicesController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await serviceController.fetchServices();
                      Get.back();
                    },
                    child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await serviceController.fetchServices();
                      Get.back();
                    },
                    child: Text('Skip', style: kSubheadingStyle),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Select Category',
                style: kHeadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return controller.isLoading.value
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      hint: const Text('Choose Category'),
                      isExpanded: true,
                      items:
                          controller.categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['_id'],
                              child: Text(cat['name']),
                            );
                          }).toList(),
                      onChanged: (value) async {
                        selectedCategoryId = value;
                        selectedSubcategoryId = null;
                        controller.subcategories.clear();
                        await controller.fetchSubcategories(value!);
                        setState(() {});
                      },
                    );
              }),
              const SizedBox(height: 16),

              if (selectedCategoryId != null) ...[
                Text(
                  'Select Subcategory',
                  style: kHeadingStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value:
                        controller.subcategories.any(
                              (sub) => sub['_id'] == selectedSubcategoryId,
                            )
                            ? selectedSubcategoryId
                            : null,
                    hint: const Text('Choose Subcategory'),
                    isExpanded: true,
                    items:
                        controller.subcategories.map((sub) {
                          return DropdownMenuItem<String>(
                            value: sub['_id'],
                            child: Text(sub['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedSubcategoryId = value;
                      final cat = controller.categories.firstWhere(
                        (e) => e['_id'] == selectedCategoryId,
                      );
                      final sub = controller.subcategories.firstWhere(
                        (e) => e['_id'] == selectedSubcategoryId,
                      );
                      addServiceToList(
                        cat['_id'],
                        sub['_id'],
                        cat['name'],
                        sub['name'],
                      );
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],

              Text(
                'Home Service Charges (Optional)',
                style: kHeadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: homeServiceChargeController,
                hintText: '\$',
                inputType: TextInputType.number,
                radius: 8,
              ),
              const SizedBox(height: 16),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: services.length * 80.0,
                  minHeight: 0,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['categoryName'],
                                  style: kHeadingStyle.copyWith(fontSize: 14),
                                ),
                                Text(
                                  service['subcategoryName'],
                                  style: kSubheadingStyle.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              controller: service['priceController'],
                              decoration: const InputDecoration(
                                hintText: "\$",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              CustomButton(
                isEnabled: services.isNotEmpty,
                title: 'Add Service',
                onPressed: () async {
                  await submitServices(context);
                },
              ),
              const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
