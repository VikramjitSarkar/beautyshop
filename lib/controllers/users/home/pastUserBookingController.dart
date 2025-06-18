import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PastBookingController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  @override
  void onInit() {
    super.onInit();
    // fetchCategories(); // 🟢 Call when controller initializes
    fetchPastBookings();
  }

  Future<void> fetchPastBookings() async {
    try {
      isLoading(true);
      errorMessage('');

      final token = GlobalsVariables.token; // Replace with actual token
      final response = await http.get(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/booking/user?status=past',
        ), // Changed to 'past'
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          bookings.assignAll(List<Map<String, dynamic>>.from(data['data']));
        } else {
          throw Exception('Please Login');
        }
      } else {
        // throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('', 'Please Check your internet connection');
    } finally {
      isLoading(false);
    }
  }

  String getServiceNamesWithTotal(List<dynamic> services) {
    double total = 0.0;

    final serviceList =
        services.map((service) {
          final name = service['serviceName'];
          final charge = double.tryParse(service['charges'].toString()) ?? 0.0;
          total += charge;
          return '$name ';
        }).toList();

    final serviceText = serviceList.join(', ');
    return '$serviceText \nTotal: \$${total.toStringAsFixed(2)}';
  }

  double getTotalCharges(List<dynamic> services) {
    return services.fold(0.0, (sum, service) {
      final charge = double.tryParse(service['charges'].toString()) ?? 0.0;
      return sum + charge;
    });
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDate) async {
    final token = GlobalsVariables.token;
    try {
      isLoading.value = true;
      final response = await http.put(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/booking/reschedule/$bookingId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"newDate": newDate.toUtc().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Booking rescheduled!");
        fetchPastBookings(); // Refresh bookings
      } else {
        Get.snackbar("Error", "Failed to reschedule");
      }
    } catch (e) {
      Get.snackbar("Error", "Please check your internet connection");
    } finally {
      isLoading.value = false;
    }
  }
}
