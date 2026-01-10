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
  String whatsapp = '';
  String listingPlan = 'free';
  File? profileImage;
  bool homeServiceAvailable=false;
  bool hasPhysicalShop=false;

  // New fields for latitude and longitude
  double? vendorLat;
  double? vendorLong;
  
  // To store coordinates from map picker
  bool hasCoordinatesFromMap = false;

  void setBasicInfo({
    required String userName,
    required String userEmail,
    required String userPassword,
  }) {
    name = userName;
    email = userEmail;
    password = userPassword;
    
    print('=== PAGE 1: BASIC INFO SAVED ===');
    print('Name: $name');
    print('Email: $email');
    print('Password length: ${password.length}');
  }

  void setProfileInfo({
    required String shop,
    required String desc,
    required String titleText,
    required String loc,
    required String phone,
    required String whatsapp,
    required File? image,
    required bool homeServiceAvailable,
    required bool hasPhysicalShop,
    double? latitude,
    double? longitude,
  }) {
    shopName = shop;
    description = desc;
    title = titleText;
    location = loc;
    this.phone = phone;
    this.whatsapp = whatsapp;
    profileImage = image;
    this.homeServiceAvailable = homeServiceAvailable;
    this.hasPhysicalShop = hasPhysicalShop;
    
    print('=== PAGE 2: PROFILE INFO SAVED ===');
    print('Shop Name: $shopName');
    print('Phone: $phone');
    print('WhatsApp: $whatsapp');
    print('Location: $location');
    print('Has Physical Shop: $hasPhysicalShop (${hasPhysicalShop.runtimeType})');
    print('Home Service Available: $homeServiceAvailable (${homeServiceAvailable.runtimeType})');
    print('Profile Image: ${image != null ? "YES" : "NO"}');
    
    // If coordinates provided from map picker, use them directly
    if (latitude != null && longitude != null) {
      vendorLat = latitude;
      vendorLong = longitude;
      hasCoordinatesFromMap = true;
      print('Using coordinates from map: $vendorLat, $vendorLong');
    }
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

    // Only geocode address if coordinates weren't provided from map picker
    if (!hasCoordinatesFromMap && location.isNotEmpty) {
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
      'whatsapp': whatsapp,
      'locationAddress': location,
      'shopName': shopName,
      'description': description,
      'title': title,
      'listingPlan': listingPlan,
      'fcmToken': fcmToken,
      'homeServiceAvailable': homeServiceAvailable.toString(),
      'hasPhysicalShop': hasPhysicalShop.toString(),
    });

    print('=== SUBMIT REGISTRATION DEBUG ===');
    print('homeServiceAvailable field value: ${homeServiceAvailable.toString()}');
    print('hasPhysicalShop field value: ${hasPhysicalShop.toString()}');
    print('===== ALL FIELDS BEING SENT =====');
    print('userName: $name');
    print('email: $email');
    print('phone: $phone');
    print('whatsapp: $whatsapp');
    print('shopName: $shopName');
    print('title: $title');
    print('description: $description');
    print('locationAddress: $location');
    print('vendorLat: ${vendorLat ?? "null"}');
    print('vendorLong: ${vendorLong ?? "null"}');
    print('homeServiceAvailable: ${homeServiceAvailable.toString()}');
    print('hasPhysicalShop: ${hasPhysicalShop.toString()}');
    print('listingPlan: $listingPlan');
    print('profileImage: ${profileImage != null ? "attached" : "null"}');
    print('====================================');

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

        print('=== PAGE 2: VENDOR CREATED IN DATABASE ===');
        print('Vendor ID: $userId');
        print('Response hasPhysicalShop: ${body['data']['hasPhysicalShop']}');
        print('Response homeServiceAvailable: ${body['data']['homeServiceAvailable']}');
        print('==========================================');

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
