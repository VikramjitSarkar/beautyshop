import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class ServicesController extends GetxController {
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  Future<void> fetchServices() async {
    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/service/getAll');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          services.assignAll(List<Map<String, dynamic>>.from(body['data']));
        } else {
          Get.snackbar("Error", "Unexpected API response");
        }
      } else {
        // Get.snackbar("Error", "Failed to fetch services");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService({
    required String serviceId,
    required String categoryId,
    required String subcategoryId,
    required String charges,
  }) async {
    isLoading(true);
    try {
      final token = GlobalsVariables.vendorLoginToken;
      final url = '${GlobalsVariables.baseUrlapp}/service/update/$serviceId';
      final resp = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'categoryId': categoryId,
          'subcategoryId': subcategoryId,
          'charges': charges,
          'createdBy': GlobalsVariables.vendorId,
        }),
      );

      if (resp.statusCode == 200) {
        Get.snackbar('Success', 'Service updated');
        await fetchServices();
      } else {
        Get.snackbar('Error', 'Failed to update');
      }
    } catch (e) {
      Get.snackbar('Exception', e.toString());
    } finally {
      isLoading(false);
      Get.back();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }
}
