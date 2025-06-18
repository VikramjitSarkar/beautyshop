import 'dart:convert';
import 'dart:io';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/auth/ProfileSetupScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

class VendorRegisterController extends GetxController {
  var isLoading = false.obs;

  // Step 1 data
  String name = '', email = '', password = '';

  // Step 2 data
  String phone = '', location = '';
  String shopName = '', description = '', title = '';
  String listingPlan = 'free';
  File? profileImage;
  bool homeServiceAvailable=false;

  // New fields for latitude and longitude
  double? vendorLat;
  double? vendorLong;

  void setBasicInfo({
    required String userName,
    required String userEmail,
    required String userPassword,
  }) {
    name = userName;
    email = userEmail;
    password = userPassword;
  }

  void setProfileInfo({
    required String shop,
    required String desc,
    required String titleText,
    required String loc,
    required File? image,
    required bool homeServiceAvailable,
  }) {
    shopName = shop;
    description = desc;
    title = titleText;
    location = loc;
    profileImage = image;
    homeServiceAvailable=homeServiceAvailable;
  }

  /// Helper method to convert address into latitude and longitude.
  Future<void> _getLatLngFromAddress(String address) async {
    try {
      // Use the geocoding package to fetch the list of locations for the address
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        vendorLat = locations.first.latitude;
        vendorLong = locations.first.longitude;
        print('Converted address to coordinates: $vendorLat, $vendorLong');
      } else {
        print('No locations found for the address');
      }
    } catch (e) {
      print('Error converting address: $e');
    }
  }

  Future<String?> _getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        Get.snackbar('Warning', 'Could not get FCM token');
        return null;
      }
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> submitRegistration() async {
    isLoading.value = true;
    final fcmToken = await _getFCMToken();
    if (fcmToken == null) {
      isLoading.value = false;
      Get.snackbar('Error', 'Notification services not available');
      return;
    }

    if (location.isNotEmpty) {
      await _getLatLngFromAddress(location);
    }

    final uri = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/register');
    final request = http.MultipartRequest('POST', uri);

    // Add the original fields
    request.fields.addAll({
      'userName': name,
      'email': email,
      'password': password,
      'phone': phone,
      'locationAddres': location,
      'shopName': shopName,
      'description': description,
      'title': title,
      'listingPlan': listingPlan,
      'fcmToken': fcmToken,
      'homeServiceAvailable':homeServiceAvailable.toString(),
    });

    // Add the latitude and longitude if available.
    if (vendorLat != null && vendorLong != null) {
      request.fields['vendorLat'] = vendorLat.toString();
      request.fields['vendorLong'] = vendorLong.toString();
    } else {
      // Optionally, you can add default values or handle error cases here.
      print(
        'Latitude and Longitude not available; check the provided address.',
      );
    }

    // Attach the profile image if available.
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          profileImage!.path,
          filename: basename(profileImage!.path),
        ),
      );
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        final token = body['token'];
        final userId = body['data']['_id'];
        await GlobalsVariables.saveVendorId(userId);
        if (token != null) {
          await GlobalsVariables.saveVendorLoginToken(token);
          print('Saved vendor token: $token');
        }

        Get.snackbar('Success', 'Vendor registered!');
        Get.offAll(() => ProfileSetupScreen());
      } else {
        Get.snackbar('Error', 'Failed: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Exception', e.toString());
    }
  }
}
