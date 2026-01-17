import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:http/http.dart' as http;

class AddServicesController extends GetxController {
  var isLoading = false.obs;
  var categories = [].obs;
  var services = [].obs;
  var subcategories = [].obs;
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? _servicesVendorId;
  @override
  void onInit() {
    super.onInit();
    // fetchCategories(); // 🟢 Call when controller initializes
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/category/getAll'),
      );
      isLoading.value = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        categories.value = data['data'];
      } else {
        Get.snackbar("Error", "Failed to load categories");
      }
    } catch (e) {
      isLoading.value = false;
      // Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> fetchSubcategories(String categoryId) async {
    selectedCategoryId = categoryId;
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/subcategory/getbyCategoryId/$categoryId',
        ),
      );
      isLoading.value = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        subcategories.value = data['data'];
      } else {
        Get.snackbar("Error", "Failed to load subcategories");
      }
    } catch (e) {
      isLoading.value = false;
      // Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> fetchServicesByVendorId(String vendorId) async {
    final String url =
        '${GlobalsVariables.baseUrlapp}/service/byVendorId/$vendorId';

    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(url));
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        services.value = data['data'] ?? [];
        _servicesVendorId = vendorId;
        print('Service : ${services.toList()}');
      } else {
        // Get.snackbar(
        //   "Error",
        //   "Failed to load services: ${response.reasonPhrase}",
        // );
      }
    } catch (e) {
      isLoading.value = false;
      // Get.snackbar("Exception", e.toString());
    }
  }

  Future<void> createService({
    required String categoryId,
    required String subcategoryId,
    required String charges,
    required String createdBy, // vendor ID
  }) async {
    if (createdBy.isNotEmpty) {
      if (_servicesVendorId != createdBy || services.isEmpty) {
        await fetchServicesByVendorId(createdBy);
      }
      if (_isDuplicateService(categoryId: categoryId, subcategoryId: subcategoryId)) {
        Get.snackbar(
          "Duplicate",
          "This service already exists for your shop",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('${GlobalsVariables.baseUrlapp}/service/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "categoryId": categoryId,
          "subcategoryId": subcategoryId,
          "charges": charges,
          "createdBy": createdBy,
        }),
      );
      isLoading.value = false;
      if (response.statusCode == 200 || response.statusCode == 201) {
        services.add({
          "categoryId": categoryId,
          "subcategoryId": subcategoryId,
          "charges": charges,
          "createdBy": createdBy,
        });
        Get.snackbar("Success", "Service created successfully");
      } else {
        Get.snackbar("Error", "Failed to create service");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Exception", e.toString());
    }
  }

  bool _isDuplicateService({
    required String categoryId,
    required String subcategoryId,
  }) {
    for (final service in services) {
      if (service is! Map) continue;
      final existingCategoryId = _extractId(service['categoryId']);
      final existingSubcategoryId = _extractId(service['subcategoryId']);
      if (existingCategoryId == categoryId &&
          existingSubcategoryId == subcategoryId) {
        return true;
      }
    }
    return false;
  }

  String? _extractId(dynamic value) {
    if (value is Map && value['_id'] != null) {
      return value['_id'].toString();
    }
    return value?.toString();
  }
}
