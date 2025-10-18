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
      // 1) Read user (to get favoriteVendors ids)
      final userUrl = Uri.parse('${GlobalsVariables.baseUrlapp}/user/get');
      final headers = {
        'Authorization': 'Bearer ${GlobalsVariables.token}',
        'Accept': 'application/json',
      };

      final ures = await http.get(userUrl, headers: headers);
      if (ures.statusCode != 200) {
        Get.snackbar('Error', 'Failed to load profile (${ures.statusCode}).');
        vendors.clear();
        return;
      }

      final raw = jsonDecode(ures.body);
      final data = (raw is Map && raw['status'] == 'success' && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      // Could be ["id","id"] or [{"_id":"id"}, ...]
      final fav = (data['favoriteVendors'] as List?) ?? const [];
      final ids = <String>{
        for (final e in fav)
          if (e is String) e
          else if (e is Map && e['_id'] is String) e['_id'] as String
      }.toList(); // de-dupe via set

      if (ids.isEmpty) {
        vendors.clear();
        return;
      }

      // 2) Hydrate vendors in parallel (per-id). Keep the first successful shape.
      final fetched = await Future.wait(ids.map(_fetchVendorById));
      vendors.assignAll(fetched.whereType<Map<String, dynamic>>());

    } catch (e) {
      Get.snackbar('Error', 'Could not load favorites.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Try common GET-by-id patterns. Return a vendor map or null.
  Future<Map<String, dynamic>?> _fetchVendorById(String id) async {
    final base = GlobalsVariables.baseUrlapp;
    final headers = {
      'Authorization': 'Bearer ${GlobalsVariables.token}',
      'Accept': 'application/json',
    };

    // Keep/trim to match your API. These are tried in order.
    final candidates = <Uri>[
      Uri.parse('$base/vendor/$id'),
      Uri.parse('$base/vendor/get/$id'),
      Uri.parse('$base/vendor/getById?id=$id'),
      Uri.parse('$base/vendors/$id'),
    ];

    for (final url in candidates) {
      try {
        final res = await http.get(url, headers: headers);
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          // Accept either {status,data:{...}} or a plain vendor map
          if (body is Map) {
            if (body['data'] is Map<String, dynamic>) {
              return body['data'] as Map<String, dynamic>;
            }
            // Some APIs just return the vendor as the top-level object
            if (body.isNotEmpty) return Map<String, dynamic>.from(body);
          }
        } else if (res.statusCode == 404) {
          continue;
        }
      } catch (_) {}
    }
    return null;
  }
}
