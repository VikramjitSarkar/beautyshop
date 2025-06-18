import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserSubcategoryServiceController extends GetxController {
  var isLoading = false.obs;
  var subcategoryList = <Subcategory>[].obs;

  RxList<Map<String, dynamic>> category = <Map<String, dynamic>>[].obs;
  final String apiUrl = "${GlobalsVariables.baseUrlapp}/subcategory/getAll";

  @override
  void onInit() {
    super.onInit();
    fetchSubcategories();
    fetchCateogries();
  }

  Future<void> fetchSubcategories() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['data'] != null) {
          final List<Subcategory> loadedSubcategories =
              (data['data'] as List)
                  .map((item) => Subcategory.fromJson(item))
                  .toList();
          subcategoryList.assignAll(loadedSubcategories);
        } else {
          Get.snackbar('Error', 'Invalid API response format.');
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load subcategories: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCateogries() async {
    isLoading.value = true;
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/category/getAll',
    ); // Replace with real

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        category.value = data.cast<Map<String, dynamic>>();
      } else {
        subcategoryList.clear();
      }
    } catch (e) {
      print("Error: $e");
      subcategoryList.clear();
    }
    isLoading.value = false;
  }
}

class Subcategory {
  final String id;
  final String categoryId;
  final String name;
  final String status;
  final DateTime createdAt;
  final String? image;

  Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.status,
    required this.createdAt,
    this.image,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['_id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      image: json['image'],
    );
  }

  String get formattedDate {
    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }
}
  // Fetch Categories
  

