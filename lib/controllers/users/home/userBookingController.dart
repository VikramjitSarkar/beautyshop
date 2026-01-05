import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:http/http.dart' as http;

class UserBookingController extends GetxController {
  final isLoading = false.obs;
  final bookingResponse = {}.obs; // You can use a proper model if available

  Future<bool> createBooking({
    required String vendorId,
    required List serviceIds,
    required DateTime bookingDate,
    required String userName,
    required String userAddress,
    required String userLat,
    required String userLong,
    String? specialRequests,
    String? serviceLocationType,
  }) async {
    try {
      isLoading.value = true;
      final token = GlobalsVariables.token;

      // ✅ Extract subcategoryId instead of categoryId
      final List<String> subcategoryIdList =
          serviceIds.map((item) => item['serviceId'].toString()).toList();

      // Convert to comma-separated string
      debugPrint('Subcategory IDs: $subcategoryIdList');

      final response = await http.post(
        Uri.parse('${GlobalsVariables.baseUrlapp}/booking/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "vendor": vendorId,
          "services": subcategoryIdList, // ✅ send subcategory IDs
          "bookingDate": bookingDate.toIso8601String(),
          "userName": userName,
          "userLocation": {
            "address": userAddress,
            "latitude": double.tryParse(userLat) ?? 0.0,
            "longitude": double.tryParse(userLong) ?? 0.0,
          },
          "specialRequests": specialRequests ?? "",
          "serviceLocationType": serviceLocationType ?? "salon",
        }),
      );

      // Debug: Log what we're sending to backend
      debugPrint('🔵 BOOKING REQUEST: specialRequests="$specialRequests", serviceLocationType="$serviceLocationType"');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        if (body['status'] == 'success') {
          bookingResponse.value = body['data'];
          
          // Debug: Log what backend returned
          debugPrint('🟢 BOOKING RESPONSE: specialRequests=${body['data']?['specialRequests']}, serviceLocationType=${body['data']?['serviceLocationType']}');

          Get.snackbar(
            'Success',
            '${body['message'] ?? 'Booking created successfully'}\\n\\nNote: Your appointment includes 1-hour buffer time to account for any delays.',
            duration: Duration(seconds: 5),
          );

          print("created booking: $body");
          return true;
        } else {
          print("Booking failed: ${response.body}");
          Get.snackbar('Failed', body['message'] ?? 'Unknown error');
          return false;
        }
      } else {
        debugPrint("Booking failed with status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        
        // Try to parse error message from response
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Booking failed';
          Get.snackbar(
            'Booking Failed',
            errorMessage,
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red[100],
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Booking failed with status ${response.statusCode}',
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint("Booking error: $e");
      Get.snackbar('Error', 'Booking failed due to an error');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
