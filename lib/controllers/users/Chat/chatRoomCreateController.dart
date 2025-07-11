import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatRoomCreateController extends GetxController {
  var isCreating = false.obs;
  var errorMessage = ''.obs;


  Future<Map<String, dynamic>?> createChatRoom({
    required String userId,
    required String vendorId,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/chat/create');
    final body = jsonEncode({
      "userId": userId,
      "vendorId": vendorId,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      isCreating.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['data']; // return chat room info to UI
      } else {
        Get.snackbar("Error", errorMessage.value);
      }
    } catch (e) {
      isCreating.value = false;
      errorMessage.value = 'Network error: $e';
      Get.snackbar("Error", errorMessage.value);
      // Get.snackbar("Failed", "Please try again later.", backgroundColor: Colors.white);
    }

    return null;
  }
}
