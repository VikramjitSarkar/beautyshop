import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserSubcategoryController extends GetxController {


  var isLoading = false.obs;
  var subcategories = [].obs; // dynamic list (map)
  var errorMessage = ''.obs;

  Future<void> fetchSubcategoriesByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      subcategories.clear();

      final String url = '${GlobalsVariables.baseUrlapp}/subcategory/getbyCategoryId/$categoryId';
      debugPrint('Fetching subcategories from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(response.body);

        subcategories.assignAll(data['data']);
        debugPrint('Subcategories fetched successfully:');
        for (var item in subcategories) {
          debugPrint(
              'ID: ${item['_id']} | Name: ${item['name']} | Image: ${item['image'] ?? 'No Image'}');

          debugPrint(errorMessage.value);
        }
      } else {
        errorMessage.value = 'Failed with status code: ${response.statusCode}';
        debugPrint(errorMessage.value);
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Network error: ${e.message}';
      debugPrint(errorMessage.value);
    } on FormatException {
      errorMessage.value = 'Invalid JSON format';
      debugPrint(errorMessage.value);
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
