import 'package:beautician_app/utils/libs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalsVariables {
  static String? token;
  static String? vendorLoginToken;
  static String? vendorId;
  static String? userId;
  static String? bookingIdUser;
  static String? paymentId;
  static String? userVendorIdForBooking;

  static const baseUrlapp = 'https://api.thebeautyshop.io';

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    debugPrint('User token : $token');
    vendorLoginToken = prefs.getString('vendorLoginToken');
    print('vendor login token  : $vendorLoginToken');
    vendorId = prefs.getString('vendorId');
    print('vendor ld  : $vendorId');
    userId = prefs.getString('userId');
    print('User id : $userId');
    bookingIdUser = prefs.getString('bookingId');
    userVendorIdForBooking = prefs.getString('vendorBookingId');
    print('vendor: $userVendorIdForBooking');
    paymentId = prefs.getString('vendorPaymentId');
    print('paymentId: $paymentId');
  }

  static Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    token = newToken;
    await prefs.setString('token', newToken);
  }

  static Future<void> saveVendorLoginToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    vendorLoginToken = newToken;
    await prefs.setString('vendorLoginToken', newToken);
  }

  static Future<void> saveVendorId(String newId) async {
    final prefs = await SharedPreferences.getInstance();
    vendorId = newId;
    await prefs.setString('vendorId', newId);
  }

  static Future<void> saveUserId(String newUserId) async {
    // Changed parameter name
    final prefs = await SharedPreferences.getInstance();
    userId = newUserId; // Fixed assignment
    await prefs.setString('userId', newUserId);
  }

  static Future<void> saveBookingId(String newUserId) async {
    // Changed parameter name
    final prefs = await SharedPreferences.getInstance();
    bookingIdUser = newUserId; // Fixed assignment
    await prefs.setString('bookingId', newUserId);
  }

  static Future<void> saveVendorBookingId(String newUserId) async {
    // Changed parameter name
    final prefs = await SharedPreferences.getInstance();
    bookingIdUser = newUserId; // Fixed assignment
    await prefs.setString('vendorBookingId', newUserId);
  }

  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    token = null;
    vendorLoginToken = null;
    vendorId = null;
    userId = null;
    await prefs.remove('token');
    await prefs.remove('vendorLoginToken');
    await prefs.remove('vendorId');
    await prefs.remove('userId');
  }

  static Future<void> savePaymentId(String paymentId) async {
    // Changed parameter name
    final prefs = await SharedPreferences.getInstance();
    paymentId = paymentId; // Fixed assignment
    await prefs.setString('vendorPaymentId', paymentId);
  }

  static Future<void> clearbookingId() async {
    final prefs = await SharedPreferences.getInstance();
    bookingIdUser = null;
    await prefs.remove('bookingId');
    // await prefs.remove('vendorBookingId');
  }
}
