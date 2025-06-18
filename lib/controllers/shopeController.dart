import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopController extends GetxController {
  // Reactive variables
  var services = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

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
        services.value = List<Map<String, dynamic>>.from(body['data']);
        print('Map Services : $services');
      }
    } else {
      print('❌ fetchCategories failed ${resp.statusCode}');
    }
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
  }
}
