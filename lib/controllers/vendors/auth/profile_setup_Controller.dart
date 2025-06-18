// 📁 profile_setup_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupController extends GetxController {
  var isLoading = false.obs;

  Future<void> submitProfile({
    required String name,
    required String surname,
    required String age,
    required String gender,
    required File cnic,
    required File license,
    required String phone,
    required String whatsapp,
  }) async {
    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/profileSetup');

    // ✅ Use token from GlobalsVariables
    final token = GlobalsVariables.vendorLoginToken;
    if (token == null) {
      Get.snackbar('Error', 'Vendor token not found');
      isLoading.value = false;
      return;
    }

    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['userName'] = name;
    request.fields['surname'] = surname;
    request.fields['age'] = age;
    request.fields['gender'] = gender;
    request.fields['phone'] = phone;
    request.fields['whatsapp'];

    request.files.add(
      await http.MultipartFile.fromPath(
        'cnicImage',
        cnic.path,
        filename: basename(cnic.path),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'certificateImage',
        license.path,
        filename: basename(license.path),
      ),
    );

    try {
      final response = await request.send();
      final res = await http.Response.fromStream(response);
      isLoading.value = false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Success', 'Profile setup completed');
        Get.off(() => FreeAndPaidListingServicesScreen());
      } else {
        Get.snackbar('Error', 'Failed: ${res.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', e.toString());
    }
  }
}
