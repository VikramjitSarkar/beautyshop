import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

class UserProfileControllers extends GetxController{
    var isUpdating = false.obs;

   Future<Map<String, dynamic>?> getUserProfile() async {
    
    final Uri url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/get');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('User profile fetched successfully: $data');
        return data;
      } else {
        print('Failed to fetch user profile. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String locationAdress,
    required String userLat,
    required String userLong,
  }) async {
    isUpdating.value = true;

 
    final Uri url = Uri.parse('${GlobalsVariables.baseUrlapp}/user/update');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "locationAdress": locationAdress,
          "userLat": userLat,
          "userLong": userLong,
        }),
      );

      isUpdating.value = false;

      if (response.statusCode == 200) {
        print('Profile updated successfully.');
        Get.snackbar('Success', 'Profile updated successfully!');
      } else {
        print('Failed to update profile. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        Get.snackbar('Error', 'Failed to update profile.');
      }
    } catch (e) {
      isUpdating.value = false;
      print('Error occurred while updating profile: $e');
      Get.snackbar('Error', 'Something went wrong!');
    }
  }
}
