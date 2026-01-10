import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EarningsController extends GetxController {
  var isLoading = false.obs;
  var earningsData = <String, dynamic>{}.obs;
  var cancelledBookings = <Map<String, dynamic>>[].obs;
  var subscriptions = <Map<String, dynamic>>[].obs;
  var subscriptionTotal = 0.0.obs;

  Future<void> fetchEarnings(String vendorId, {String period = 'all'}) async {
    try {
      isLoading.value = true;
      
      // Fetch earnings data
      final earningsUrl = Uri.parse(
        '${GlobalsVariables.baseUrlapp}/booking/vendor-earnings/$vendorId?period=$period',
      );
      final earningsResponse = await http.get(earningsUrl);
      
      if (earningsResponse.statusCode == 200) {
        final earningsJson = json.decode(earningsResponse.body);
        if (earningsJson['status'] == 'success') {
          earningsData.value = earningsJson['data'];
        }
      }
      
      // Fetch cancelled bookings
      await fetchCancelledBookings(vendorId);
      
      // Fetch subscriptions
      await fetchSubscriptions(vendorId);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load earnings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCancelledBookings(String vendorId) async {
    try {
      final url = Uri.parse(
        '${GlobalsVariables.baseUrlapp}/booking/vendor/$vendorId?status=reject',
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          cancelledBookings.value = List<Map<String, dynamic>>.from(json['data'] ?? []);
        }
      }
    } catch (e) {
      print('Error fetching cancelled bookings: $e');
    }
  }

  Future<void> fetchSubscriptions(String vendorId) async {
    try {
      final url = Uri.parse(
        '${GlobalsVariables.baseUrlapp}/subscription?vendorId=$vendorId',
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          subscriptions.value = List<Map<String, dynamic>>.from(json['data'] ?? []);
          
          // Calculate total subscription payments
          double total = 0;
          for (var sub in subscriptions) {
            if (sub['status'] == 'active' || sub['status'] == 'expired') {
              total += (sub['price'] ?? 0).toDouble();
            }
          }
          subscriptionTotal.value = total;
        }
      }
    } catch (e) {
      print('Error fetching subscriptions: $e');
    }
  }
}
