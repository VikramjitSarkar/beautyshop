import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../constants/globals.dart';
import '../../../utils/libs.dart';

class UserPendingBookngController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  final RxString qrCode = ''.obs;
  final RxString bookingId = ''.obs;
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    await fetchUpcomingBookings();
    await fetchPendingBookings();
  }

  Future<void> refreshData() async {
    await loadData();
  }

  Future<void> fetchUpcomingBookings() async {
    try {
      isLoading(true);
      errorMessage('');

      final token = GlobalsVariables.token; // Replace with actual token
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/booking/user?status=pending'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          bookings.assignAll(List<Map<String, dynamic>>.from(data['data']));
        } else {
          throw Exception('');
        }
      } else {
        throw Exception('Please Login');
      }
    } catch (e) {
      errorMessage(e.toString());
      // Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPendingBookings() async {
    try {
      isLoading(true);
      errorMessage('');

      final token = GlobalsVariables.token; // Replace with actual token
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/booking/user?status=accept'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          pendingBookings.assignAll(
            List<Map<String, dynamic>>.from(data['data']),
          );
        } else {
          throw Exception('Please Login');
        }
      } else {
        // throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
      // Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoading(false);
    }
  }

  String formatBookingDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')} pm - ${date.day} ${_getMonthName(date.month)}';
    } catch (e) {
      return '6:30 pm - 05 Jun'; // Fallback if date parsing fails
    }
  }

  // bookingActivated
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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
}
