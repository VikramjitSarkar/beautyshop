// 📁 profile_setup_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/auth/payment_method_selection_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ProfileSetupController extends GetxController {
  var isLoading = false.obs;

  Future<void> submitProfile({
    required String name,
    required String surname,
    required String age,
    required String gender,
    required File cnic,
    required File license,
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

    print('=== PAGE 3: PROFILE SETUP SUBMISSION ===');
    print('userName: $name');
    print('surname: $surname');
    print('age: $age');
    print('gender: $gender');
    print('cnicImage: attached');
    print('certificateImage: attached');
    print('NOTE: NOT sending hasPhysicalShop or homeServiceAvailable');
    print('=========================================');

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
        final body = jsonDecode(res.body);
        print('=== PAGE 3: PROFILE UPDATED IN DATABASE ===');
        print('Response hasPhysicalShop: ${body['data']['hasPhysicalShop']}');
        print('Response homeServiceAvailable: ${body['data']['homeServiceAvailable']}');
        print('===========================================');
        
        Get.snackbar('Success', 'Profile setup completed');
        Get.off(() => const PaymentMethodSelectionScreen());
      } else {
        Get.snackbar('Error', 'Failed: ${res.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', e.toString());
    }
  }
}
