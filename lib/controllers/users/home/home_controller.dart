import 'dart:convert';
import 'dart:math';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/controllers/vendors/auth/profile_setup_Controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../userProfile/userProfileController.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var categories = [].obs;
  var vendors = [].obs;
  var nearbyVendors = [].obs;
  var vendorData = <String, dynamic>{}.obs;
  var categoryData = <Map<String, dynamic>>[].obs;
  var nearbyCategoryData = <Map<String, dynamic>>[].obs;
  var controller = Get.put(UserProfileControllers());
  var profileController = Get.put(UserProfileController());
  
  @override
  void onInit() {
    super.onInit();
    // fetchCategories(); // 🟢 Call when controller initializes
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Fetch all data first
      await Future.wait([
        fetchVendors(),
        fetchCategoriesWithVendors(),
      ]);

      // Get user profile to retrieve location
      final userProfile = await controller.getUserProfile();
      
      // Get current location
      await _fetchAndApplyLocation();
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<void> _fetchAndApplyLocation() async {
    try {
      // Always get fresh location from device
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        // Update profile controller with fresh location
        profileController.userLat.value = position.latitude.toString();
        profileController.userLong.value = position.longitude.toString();
        
        print('Location fetched: ${position.latitude}, ${position.longitude}');
        
        // Apply location-based filtering
        filterVendorsWithin30Km(userLat: position.latitude, userLong: position.longitude);
        filterVendorsInCategoryByLocation(userLat: position.latitude, userLong: position.longitude);
      } catch (e) {
        print('Error getting current location: $e');
        
        // Fall back to stored location if current location fails
        double? userLat = double.tryParse(profileController.userLat.value);
        double? userLong = double.tryParse(profileController.userLong.value);
        
        if (userLat != null && userLong != null && 
            !(userLat == 0.0 && userLong == 0.0)) {
          print('Using stored location: $userLat, $userLong');
          filterVendorsWithin30Km(userLat: userLat, userLong: userLong);
          filterVendorsInCategoryByLocation(userLat: userLat, userLong: userLong);
        }
      }
    } catch (e) {
      print('Error fetching and applying location: $e');
    }
  }

  /// Call this method when home screen becomes visible to refresh location data
  Future<void> refreshLocationData() async {
    print('Refreshing location data...');
    await _fetchAndApplyLocation();
  }

  // ------------ Fetch Categories Method -------------
  // Future<void> fetchCategories() async {
  //   isLoading.value = true;
  //   final url = Uri.parse('http://89.116.39.230:4000/category/getAll');

  //   try {
  //     final response = await http.get(url);
  //     isLoading.value = false;

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       categories.value = data['data'];
  //       print('Categories: $categories');
  //     } else {
  //       Get.snackbar("Error", "Failed to load categories");
  //     }
  //   } catch (e) {
  //     isLoading.value = false;
  //     Get.snackbar("Error", e.toString());
  //   }
  // }

  Future<void> fetchCategoriesWithVendors() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/category/userDashboard'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          categoryData.assignAll(List<Map<String, dynamic>>.from(data['data']));
          print(categoryData);
          print("user location: ${profileController.userLat} : ${profileController.userLong}");
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ------------- Fetch Vendors Method
  Future<void> fetchVendors() async {
    isLoading.value = true;
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/getAll');

    try {
      print("[fetchVendors] GET $url");
      final response = await http.get(url);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        vendors.value = data['data'] ?? [];
        print("[fetchVendors] Successfully fetched ${vendors.length} vendors");
      } else {
        // Get.snackbar('Error', '');
        print('[fetchVendors] Failed to load vendors - Status: ${response.statusCode}');
      }
    } catch (e) {
      isLoading.value = false;
      // Get.snackbar('Error', e.toString());
      print('[fetchVendors] Error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> fetchVendorById(String vendorId) async {
    final url = '${GlobalsVariables.baseUrlapp}/vendor/byVendorId/$vendorId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          vendorData.value = data['data'];

          return data['data']; // <-- This is your vendor data map
        } else {
          print('API returned non-success status');
        }
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }


  /// Converts degrees to radians
  double _degToRad(double deg) => deg * pi / 180;

  /// Returns distance in kilometers between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // Radius in km

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Filters vendors within 30km radius of user's location
  void filterVendorsWithin30Km({
    required double userLat,
    required double userLong,
  }) {
    print("Fetching vendors...");
    print("Total vendors before filter: ${vendors.length}");
    print("User location: Lat=$userLat, Long=$userLong");
    isLoading.value = true;

    try {
      final filtered = vendors.where((vendor) {
        final vLat = double.tryParse(vendor['vendorLat'].toString()) ?? 0.0;
        final vLong = double.tryParse(vendor['vendorLong'].toString()) ?? 0.0;

        final distance = _calculateDistance(userLat, userLong, vLat, vLong);
        print("Vendor: ${vendor['shopName']}, Distance: ${distance.toStringAsFixed(2)} km");
        return distance <= 30.0;
      }).toList();

      // Assign filtered list to observable
      nearbyVendors.assignAll(filtered);
      print("Updated vendors: ${nearbyVendors.length} vendors within 30km");

    } catch (e) {
      print("Error filtering vendors: $e");
    } finally {
      // Ensure UI reflects loading off AFTER assignAll completes
      Future.delayed(Duration.zero, () {
        isLoading.value = false;
      });
    }
  }




  /// Filters each category's vendor list to only include vendors within 30km
  void filterVendorsInCategoryByLocation({
    required double userLat,
    required double userLong,
  }) {
    final List<Map<String, dynamic>> updatedCategories = [];
    isLoading.value = true;

    try{

      for (var category in categoryData) {
        final vendors = category['vendors'] ?? [];

        final nearbyVendors = vendors.where((vendor) {
          final vLat = double.tryParse(vendor['vendorLat'].toString()) ?? 0.0;
          final vLong = double.tryParse(vendor['vendorLong'].toString()) ?? 0.0;
          final distance = _calculateDistance(userLat, userLong, vLat, vLong);
          return distance <= 30.0;
        }).toList();

        final updatedCategory = {
          ...category,
          'vendors': nearbyVendors,
        };

        updatedCategories.add(updatedCategory);
      }

      nearbyCategoryData.assignAll(updatedCategories);
      print("updated vendors 2: $nearbyCategoryData");
    }catch(e){

    }finally{
      // Ensure UI reflects loading off AFTER assignAll completes
      Future.delayed(Duration.zero, () {
        isLoading.value = false;
      });
    }
  }

  //
  // /// Filters vendors within 30km radius of user's location
  // void filterVendorsWithin30Km2({
  //   required RxString userLat,
  //   required RxString userLong,
  // }) {
  //   // Ensure valid coordinates
  //   if (userLat.value.isEmpty || userLong.value.isEmpty) return;
  //
  //   isLoading.value = true;
  //
  //   final double uLat = double.tryParse(userLat.value) ?? 0.0;
  //   final double uLong = double.tryParse(userLong.value) ?? 0.0;
  //
  //   final filtered = vendors.where((vendor) {
  //     final vLat = double.tryParse(vendor['vendorLat'].toString()) ?? 0.0;
  //     final vLong = double.tryParse(vendor['vendorLong'].toString()) ?? 0.0;
  //
  //     final distance = _calculateDistance(uLat, uLong, vLat, vLong);
  //     return distance <= 30.0;
  //   }).toList();
  //
  //   vendors.assignAll(filtered);
  //   isLoading.value = false;
  // }
  //
  //
  // /// Filters each category's vendor list to only include vendors within 30km
  // void filterVendorsInCategoryByLocation2({
  //   required RxString userLat,
  //   required RxString userLong,
  // }) {
  //   final List<Map<String, dynamic>> updatedCategories = [];
  //
  //   isLoading.value = true;
  //   final double uLat = double.tryParse(userLat.value) ?? 0.0;
  //   final double uLong = double.tryParse(userLong.value) ?? 0.0;
  //
  //   for (var category in categoryData) {
  //     final vendors = category['vendors'] ?? [];
  //
  //     final nearbyVendors = vendors.where((vendor) {
  //       final vLat = double.tryParse(vendor['vendorLat'].toString()) ?? 0.0;
  //       final vLong = double.tryParse(vendor['vendorLong'].toString()) ?? 0.0;
  //       final distance = _calculateDistance(uLat, uLong, vLat, vLong);
  //       return distance <= 30.0;
  //     }).toList();
  //
  //     final updatedCategory = {
  //       ...category,
  //       'vendors': nearbyVendors,
  //     };
  //
  //     updatedCategories.add(updatedCategory);
  //   }
  //
  //   categoryData.assignAll(updatedCategories);
  //   isLoading.value = false;
  //   print("updated vendors 2: $categoryData");
  // }
}
