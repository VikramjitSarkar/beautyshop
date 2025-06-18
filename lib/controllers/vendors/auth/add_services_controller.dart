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
        print('Service : ${services.value}');
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
        Get.snackbar("Success", "Service created successfully");
      } else {
        Get.snackbar("Error", "Failed to create service");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Exception", e.toString());
    }
  }
}
