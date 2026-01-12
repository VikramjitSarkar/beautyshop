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

      final token = GlobalsVariables.token;
      
      // Fetch both past and rejected (cancelled) bookings
      final pastResponse = await http.get(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/booking/user?status=past',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      final rejectedResponse = await http.get(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/booking/user?status=reject',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<Map<String, dynamic>> allBookings = [];

      if (pastResponse.statusCode == 200) {
        final pastData = json.decode(pastResponse.body);
        if (pastData['status'] == 'success') {
          allBookings.addAll(List<Map<String, dynamic>>.from(pastData['data']));
        }
      }

      if (rejectedResponse.statusCode == 200) {
        final rejectedData = json.decode(rejectedResponse.body);
        if (rejectedData['status'] == 'success') {
          allBookings.addAll(List<Map<String, dynamic>>.from(rejectedData['data']));
        }
      }

      if (allBookings.isNotEmpty) {
        bookings.assignAll(allBookings);
      } else if (pastResponse.statusCode != 200 && rejectedResponse.statusCode != 200) {
        throw Exception('Please Login');
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
