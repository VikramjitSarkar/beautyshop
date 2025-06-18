import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/auth/profile_setup_Controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../userProfile/userProfileController.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var categories = [].obs;
  var vendors = [].obs;
  var vendorData = <String, dynamic>{}.obs;
  var categoryData = <Map<String, dynamic>>[].obs;
  var controller = Get.put(UserProfileControllers());
  @override
  void onInit() {
    super.onInit();
    // fetchCategories(); // 🟢 Call when controller initializes

    fetchVendors();
    fetchCategoriesWithVendors();
    controller.getUserProfile();
  }

  // ------------ Fetch Categories Method -------------
  // Future<void> fetchCategories() async {
  //   isLoading.value = true;
  //   final url = Uri.parse('http://89.116.39.230:4000/category/getAll');

  //   try {
  //     final response = await http.get(url);
  //     isLoading.value = false;

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       categories.value = data['data'];
  //       print('Categories: $categories');
  //     } else {
  //       Get.snackbar("Error", "Failed to load categories");
  //     }
  //   } catch (e) {
  //     isLoading.value = false;
  //     Get.snackbar("Error", e.toString());
  //   }
  // }

  Future<void> fetchCategoriesWithVendors() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/category/userDashboard'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          categoryData.assignAll(List<Map<String, dynamic>>.from(data['data']));
          print(categoryData);
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ------------- Fetch Vendors Method
  Future<void> fetchVendors() async {
    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/getAll');

    try {
      final response = await http.get(url);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        vendors.value = data['data'] ?? [];
      } else {
        // Get.snackbar('Error', '');
        print('Failed to load vendors');
      }
    } catch (e) {
      isLoading.value = false;
      // Get.snackbar('Error', e.toString());
      print(e.toString());
    }
  }

  Future<Map<String, dynamic>?> fetchVendorById(String vendorId) async {
    final url = '${GlobalsVariables.baseUrlapp}/vendor/byVendorId/$vendorId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          vendorData.value = data['data'];

          return data['data']; // <-- This is your vendor data map
        } else {
          print('API returned non-success status');
        }
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }
}
