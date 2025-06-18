import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class FavoriteController extends GetxController {
  var isLoading = false.obs;
  var favorites = [].obs;


  @override
  void onInit() {
    super.onInit();
    fetchFavoriteVendors();
  }

  Future<void> fetchFavoriteVendors() async {
    isLoading.value = true;
    final Uri url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/getFavorite');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          favorites.assignAll(data['data']);
          print('Favorite vendors loaded successfully.');
        } else {
          Get.snackbar('Error', 'Failed to fetch favorites.');
        }
      } else {
        Get.snackbar('Error', 'Error ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Error fetching favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
