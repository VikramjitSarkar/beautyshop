import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../../../data/db_helper.dart';
import '../../../utils/libs.dart';
import '../profile/getfavourieController.dart';

class GenralController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isFavorite = false.obs;

  RxList<Map<String, dynamic>> filteredSubcategories =
      <Map<String, dynamic>>[].obs;
  final String baseUrl = '${GlobalsVariables.baseUrlapp}/';

  void checkFavoriteStatus(String vendorId) async {
    isFavorite.value = await DBHelper.isFavorite(vendorId);
  }

  Future<void> toggleFavorite(String vendorId) async {
    isFavorite.toggle();

    if (isFavorite.value) {
      await markFavorite(vendorId: vendorId);
      await DBHelper.insertFavorite(vendorId);
    } else {
      await markUnFavorite(vendorId: vendorId);
      await DBHelper.deleteFavorite(vendorId);
    }
    
    // Refresh the favorites list
    try {
      final favController = Get.find<FavoriteFromUserController>();
      await favController.loadFavoritesFromUser();
    } catch (e) {
      // Controller not initialized yet, that's okay
    }
  }

  Future<void> markFavorite({required String vendorId}) async {
    final Uri url = Uri.parse('${baseUrl}user/markFavorite/$vendorId');
    try {
      print('Marking vendor $vendorId as favorite...');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
      );
      print('Mark favorite response (${response.statusCode}): ${response.body}');
    } catch (e) {
      print('Favorite API error: $e');
    }
  }

  Future<void> markUnFavorite({required String vendorId}) async {
    final Uri url = Uri.parse('${baseUrl}user/unmarkFavorite/$vendorId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
      );
      print('Unmarked as favorite: ${response.body}');
    } catch (e) {
      print('Unfavorite API error: $e');
    }
  }

  Future<void> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    isLoading.value = true;
    final url = Uri.parse('${baseUrl}user/updatePassword/$userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GlobalsVariables.token}',
        },
        body: jsonEncode({
          'password': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        Get.back(); // Close the change password screen
        Get.snackbar(
          'Success',
          'Password updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Failed to update password';
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update password: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch category by near by

  Future<List<Map<String, dynamic>>> fetchFilteredSubcategories({
    String? userLat,
    String? userLong,
    required String categoryId,
  }) async {
    final String baseUrl = '${GlobalsVariables.baseUrlapp}';
    final Uri url = Uri.parse('$baseUrl/subcategory/nearbySubcategory');

    try {
      // Check and request location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double userLat = position.latitude;
      final double userLong = position.longitude;

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'categoryId': categoryId,
          'userLat': userLat.toString(),
          'userLong': userLong.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map<Map<String, dynamic>>((item) {
          return {
            '_id': item['_id'],
            'categoryId': categoryId,
            'shopBanner': item['shopBanner'] ?? '',
            'shopName': item['shopName'] ?? item['shopName'] ?? 'No Name',

            'avgRating': item['avgRating'] ?? '0.0',
            'distance': item['distance'] ?? '0.0',
            'locationAddress': item['locationAddress'] ?? 'No Address',
            'status': item['status'] ?? 'offline',
            'charges': item['charges'] ?? '0',
          };
        }).toList();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    }
  }

  // Filter bu sub category

  Future<void> fetchFilteredsSubcategories({
    required String categoryId,
    required String userLat,
    required String userLong,
    String? status,
    String? homeVisit,
    String? hasSalon,
    int? minPrice,
    int? maxPrice,
    bool? onlineNow,
    bool? nearby,
    TimeOfDay? selectedTime,
    bool? isAvailableNow,
  }) async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('${GlobalsVariables.baseUrlapp}/subcategory/nearbySubcategory'),
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "categoryId": categoryId,
          "userLat": userLat,
          "userLong": userLong,
          if (status != null) "status": status,
          if (homeVisit != null) "homeVisit": homeVisit,
          if (hasSalon != null) "hasSalon": hasSalon,
          if (minPrice != null) "minPrice": minPrice,
          if (maxPrice != null) "maxPrice": maxPrice,
          if (onlineNow != null) "onlineNow": onlineNow,
          if (nearby != null) "nearby": nearby,
          if (selectedTime != null)
            "selectedTime": "${selectedTime.hour}:${selectedTime.minute}",
          if (isAvailableNow != null) "isAvailableNow": isAvailableNow,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];

        // Backend has already filtered by homeVisit and hasSalon
        // Only apply client-side filters for fields not handled by backend
        data.removeWhere((item) {
          final itemCharges =
              int.tryParse(item['charges']?.toString() ?? '0') ?? 0;
          final itemOpeningTime = item['openingTime'];

          // Check price range (backend doesn't filter by price in body params)
          if (minPrice != null && itemCharges < minPrice) return true;
          if (maxPrice != null && itemCharges > maxPrice) return true;

          // Simulated availability based on opening time
          if (isAvailableNow == true && itemOpeningTime is Map) {
            final openHour =
                int.tryParse(itemOpeningTime['hour']?.toString() ?? '0') ?? 0;
            final openMinute =
                int.tryParse(itemOpeningTime['minute']?.toString() ?? '0') ?? 0;
            final now = TimeOfDay.now();
            if (now.hour < openHour ||
                (now.hour == openHour && now.minute < openMinute)) {
              return true;
            }
          }

          if (selectedTime != null && itemOpeningTime is Map) {
            final openHour =
                int.tryParse(itemOpeningTime['hour']?.toString() ?? '0') ?? 0;
            final openMinute =
                int.tryParse(itemOpeningTime['minute']?.toString() ?? '0') ?? 0;
            if (selectedTime.hour < openHour ||
                (selectedTime.hour == openHour &&
                    selectedTime.minute < openMinute)) {
              return true;
            }
          }

          return false;
        });

        filteredSubcategories.value =
            data.map<Map<String, dynamic>>((item) {
              return {
                '_id': item['_id'],
                'categoryId': categoryId,
                'image': item['profileImage'] ?? '',
                'profileImage': item['profileImage'] ?? '',
                'name': item['name'] ?? item['title'] ?? 'No Name',
                'title': item['title'] ?? 'No Title',
                'shopName': item['shopName'] ?? '',
                'avgRating': item['avgRating']?.toString() ?? '0.0',
                'shopBanner': item['shopBanner']?.toString() ?? '',
                'distance':
                    (item['distance']?.toString() == '')
                        ? '0.0'
                        : item['distance']?.toString() ?? '0.0',
                'locationAddress': item['locationAddress'] ?? 'No Address',
                'status': item['status'] ?? 'offline',
                'charges': item['charges']?.toString() ?? '0',
                'openingTime': item['openingTime'] ?? {},
                'gallery': item['gallery'] ?? [],
                'gender': item['gender'] ?? '',
                'description': item['description'] ?? '',
                'vendorLat': item['vendorLat'] ?? '',
                'vendorLong': item['vendorLong'] ?? '',
                'email': item['email'] ?? '',
                'cnic': item['cnic'] ?? '',
                'license': item['license'] ?? '',
                'accountStatus': item['accountStatus'] ?? '',
              };
            }).toList();

        print('Filtered Subcategories: ${filteredSubcategories.length}');
      } else {
        filteredSubcategories.clear();
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      filteredSubcategories.clear();
      print('Exception: $e');
    }

    isLoading.value = false;
  }
}
