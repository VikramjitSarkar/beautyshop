import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class FavoriteFromUserController extends GetxController {
  final isLoading = false.obs;
  final vendors   = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavoritesFromUser();
  }

  Future<void> loadFavoritesFromUser() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      // 1) Read user (to get favoriteVendors ids and location)
      final userUrl = Uri.parse('${GlobalsVariables.baseUrlapp}/user/get');
      final headers = {
        'Authorization': 'Bearer ${GlobalsVariables.token}',
        'Accept': 'application/json',
      };

      final ures = await http.get(userUrl, headers: headers);
      print('User profile response status: ${ures.statusCode}');
      
      if (ures.statusCode != 200) {
        Get.snackbar('Error', 'Failed to load profile (${ures.statusCode}).');
        vendors.clear();
        return;
      }

      final raw = jsonDecode(ures.body);
      print('User profile raw response: $raw');
      
      final data = (raw is Map && raw['status'] == 'success' && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      // Get user location for nearby search
      final userLat = data['userLat']?.toString() ?? '0';
      final userLong = data['userLong']?.toString() ?? '0';
      print('User location: lat=$userLat, long=$userLong');

      // Could be ["id","id"] or [{"_id":"id"}, ...]
      final fav = (data['favoriteVendors'] as List?) ?? const [];
      print('Favorite vendors from API: $fav');
      
      final ids = <String>{
        for (final e in fav)
          if (e is String) e
          else if (e is Map && e['_id'] is String) e['_id'] as String
      }.toList(); // de-dupe via set

      print('Extracted favorite vendor IDs: $ids');

      if (ids.isEmpty) {
        print('No favorite vendor IDs found');
        vendors.clear();
        return;
      }

      // 2) Fetch full vendor details for each favorite ID
      print('Fetching full details for ${ids.length} favorite vendors...');
      final favoriteVendors = <Map<String, dynamic>>[];
      
      for (final vendorId in ids) {
        try {
          final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/byVendorId/$vendorId');
          final res = await http.get(url, headers: headers);
          
          if (res.statusCode == 200) {
            final body = jsonDecode(res.body);
            if (body is Map && body['data'] is Map) {
              final vendor = Map<String, dynamic>.from(body['data']);
              print('Fetched vendor $vendorId: locationAddres=${vendor['locationAddres']}');
              favoriteVendors.add(vendor);
            }
          } else {
            print('Failed to fetch vendor $vendorId: ${res.statusCode}');
          }
        } catch (e) {
          print('Error fetching vendor $vendorId: $e');
        }
      }
      
      vendors.assignAll(favoriteVendors);
      
      print('Loaded ${vendors.length} favorite vendors from ${ids.length} IDs');

    } catch (e) {
      print('Error loading favorites: $e');
      Get.snackbar('Error', 'Could not load favorites.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Try to fetch vendor by ID from nearby endpoint
  Future<Map<String, dynamic>?> _fetchVendorById(String id) async {
    final base = GlobalsVariables.baseUrlapp;
    final headers = {
      'Authorization': 'Bearer ${GlobalsVariables.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      // Use nearby endpoint to get all vendors, then filter by ID
      // We'll use a dummy location - the backend should still return the vendor
      final url = Uri.parse('$base/vendor/nearby');
      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'userLat': '0',
          'userLong': '0',
          'categoryId': '', // empty category to get all
        }),
      );
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print('Nearby vendors response for ID $id: status=${res.statusCode}');
        
        if (body is Map && body['data'] is List) {
          final vendors = body['data'] as List;
          print('Nearby returned ${vendors.length} vendors');
          
          // Debug: print first vendor ID if available
          if (vendors.isNotEmpty && vendors[0] is Map) {
            print('Sample vendor ID: ${vendors[0]['_id']}');
          }
          
          // Find vendor with matching ID
          for (final vendor in vendors) {
            if (vendor is Map && vendor['_id'] == id) {
              print('Found vendor $id in nearby results');
              return Map<String, dynamic>.from(vendor);
            }
          }
          
          print('Vendor $id not found in ${vendors.length} nearby results');
        } else {
          print('Unexpected nearby response format: ${body.runtimeType}');
        }
      } else {
        print('Nearby endpoint returned status ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching vendor $id: $e');
    }
    
    return null;
  }
  
  /// Fetch all vendors from nearby endpoint
  Future<List<Map<String, dynamic>>> _fetchAllVendorsNearby(String lat, String long) async {
    final base = GlobalsVariables.baseUrlapp;
    final headers = {
      'Authorization': 'Bearer ${GlobalsVariables.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final url = Uri.parse('$base/vendor/nearby');
      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'userLat': lat,
          'userLong': long,
          'categoryId': '', // empty to get all categories
        }),
      );
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print('Fetched all nearby vendors: status=${res.statusCode}');
        
        // Print raw response to see what backend returns
        print('Nearby API raw response structure: ${body.runtimeType}');
        if (body is Map && body['data'] is List) {
          final vendorsList = body['data'] as List;
          print('Nearby API returned ${vendorsList.length} vendors');
          
          // Print first vendor RAW data
          if (vendorsList.isNotEmpty) {
            print('First vendor RAW from API: ${vendorsList[0]}');
          }
          
          final vendors = vendorsList
              .whereType<Map<String, dynamic>>()
              .map((v) {
                final vendorMap = Map<String, dynamic>.from(v);
                return vendorMap;
              })
              .toList();
          
          // Debug: print address field for first vendor
          if (vendors.isNotEmpty) {
            print('First vendor after mapping - locationAddres: ${vendors[0]['locationAddres']}, keys: ${vendors[0].keys.toList()}');
          }
          
          print('Found ${vendors.length} total vendors nearby');
          return vendors;
        }
      } else {
        print('Nearby endpoint returned status ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching all nearby vendors: $e');
    }
    
    return [];
  }
}
