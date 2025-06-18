// lib/controllers/category_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:beautician_app/constants/globals.dart'; // for GlobalsVariables.token

class CategoryController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> vendorServices =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subcategories =
      <Map<String, dynamic>>[].obs;
  final RxList<String> selectedServiceIds =
      <String>[].obs; // Track selected servic

  /// GET /category/getAll
  Future<void> fetchCategories() async {
    final uri = Uri.parse('${GlobalsVariables.baseUrlapp}/category/getAll');
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${GlobalsVariables.token}',
      },
    );
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      if (body['status'] == 'success' && body['data'] is List) {
        categories.value = List<Map<String, dynamic>>.from(body['data']);
      }
    } else {
      print('❌ fetchCategories failed ${resp.statusCode}');
    }
  }

  Future<void> fetchAndStoreServicesByVendorId(String vendorId) async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/service/byVendorId/$vendorId',
    );

    try {
      isLoading.value = true; // Start loading

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GlobalsVariables.token}',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['status'] == 'success') {
          final List<dynamic> data = body['data'] ?? [];

          vendorServices.value = List<Map<String, dynamic>>.from(data);
          selectedServiceIds.value =
              vendorServices
                  .map((service) => service['_id'].toString())
                  .toList();

          print(
            '✅ Fetched ${vendorServices.length} services for vendor $vendorId',
          );
        } else {
          vendorServices.clear();
          selectedServiceIds.clear();
          throw Exception('API returned failure status');
        }
      } else {
        vendorServices.clear();
        selectedServiceIds.clear();
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      vendorServices.clear();
      selectedServiceIds.clear();
      print('❌ Error fetching services: $e');
      Get.snackbar('Error', 'Failed to load services');
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  /// GET /subcategory/getbyCategoryId/:id
  Future<void> fetchSubcategories(String categoryId) async {
    final uri = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/subcategory/getbyCategoryId/$categoryId',
    );
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${GlobalsVariables.token}',
      },
    );
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      if (body['status'] == 'success' && body['data'] is List) {
        subcategories.value = List<Map<String, dynamic>>.from(body['data']);
      }
    } else {
      print('❌ fetchSubcategories failed ${resp.statusCode}');
    }
  }

  // Add this method to get service IDs for booking
  List<String> getServiceIdsForBooking() {
    return selectedServiceIds.toList();
  }

  // Add this method to get services with their details
  List<Map<String, dynamic>> getServicesForBooking() {
    return vendorServices.toList();
  }
}
