import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';

class SubcategoryController extends GetxController {
  final RxList<Map<String, dynamic>> subcategories = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  Future<void> fetchSubcategories() async {
    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/subcategory/getAll');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          subcategories.assignAll(List<Map<String, dynamic>>.from(body['data']));
        } else {
          Get.snackbar("Error", "Unexpected API response");
        }
      } else {
        Get.snackbar("Error", "Failed to fetch subcategories");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> getSubcategoriesByCategory(String categoryId) {
    return subcategories.where((subcat) => subcat['categoryId'] == categoryId).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchSubcategories();
  }
}