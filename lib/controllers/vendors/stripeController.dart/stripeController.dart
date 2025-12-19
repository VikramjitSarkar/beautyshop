import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/auth/vendor_listing_controler.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../views/vender/bottom_navi/bottom_nav_bar.dart';

// class StripeController extends GetxController{
//
//   Map<String, dynamic>? paymentIntent;
//
//   Future<void> makePayment({required int amountInCents,required String planId}) async {
//     try {
//       paymentIntent = await createPaymentIntent(amountInCents);
//       final paymentMethodId = paymentIntent!['payment_method']; // or get it from payment sheet result
//       var gpay = const PaymentSheetGooglePay(
//           merchantCountryCode: "US", currencyCode: "USD", testEnv: true);
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent!["client_secret"],
//           style: ThemeMode.light,
//           merchantDisplayName: "Iqra",
//           googlePay: gpay,
//         ),
//       );
//       displayPaymentSheet(planId, paymentMethodId);
//     } catch (e) {
//       if (kDebugMode) print(e);
//     }
//   }
//
//   void displayPaymentSheet(String planId, String paymentMethodId) async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//
//       if (kDebugMode) print("Payment successful");
//
//       await PlanService.createSubscription(planId, paymentMethodId);
//
//     } catch (e) {
//       if (kDebugMode) print("Payment failed: $e");
//     }
//   }
//
//   Future<Map<String, dynamic>> createPaymentIntent(int amount) async {
//     try {
//       Map<String, dynamic> body = {
//         "amount": amount.toString(), // Amount in cents
//         "currency": "USD",
//       };
//
//       http.Response response = await http.post(
//         Uri.parse("https://api.stripe.com/v1/payment_intents"),
//         body: body,
//         headers: {
//           "Authorization": "Bearer sk_test_yy71U48LEjRFDAq64Hjk74y000lyzm1BY5",
//           "Content-Type": "application/x-www-form-urlencoded",
//         },
//       );
//
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
//
// }

class StripeController extends GetxController {
  RxList<Map<String, dynamic>> subscriptions = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic>? currentVendorSubscription = RxMap();
  late String name;
  RxBool isCancelling = false.obs;
  String? setupIntentId;
  Future<void> makePayment({
    required BuildContext context,
    required double amountInDollars,
    required String planId,
  }) async {
    try {
      print(
        "▶ Starting subscription flow for plan: $planId, \$${amountInDollars}",
      );

      final vendorId = GlobalsVariables.vendorId;
      if (vendorId == null) throw Exception("Vendor ID is null");

      final stripeCustomerId = await createStripeCustomer(vendorId);
      final amountInCents = (amountInDollars * 100).toInt();

      final paymentIntent = await createPaymentIntentForFutureUse(
        stripeCustomerId,
        amountInCents,
      );
      final clientSecret = paymentIntent['client_secret'];
      final paymentIntentId = paymentIntent['id'];
      print(
        "✅ PaymentIntent created: $paymentIntentId, client_secret: $clientSecret",
      );
      // Initialize Stripe

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: "Beautician",
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US'),
        ),
      );

      print("✅ Showing PaymentSheet...");
      await Stripe.instance.presentPaymentSheet();

      print("✅ PaymentSheet completed");

      // Retrieve updated PaymentIntent with attached PaymentMethod
      final paymentIntentDetails = await fetchPaymentIntentDetails(
        paymentIntentId,
      );
      final paymentMethodId = paymentIntentDetails['payment_method'];

      print("✅ CustomerId: $stripeCustomerId");

      await createSubscription(
        planId: planId,
        paymentMethodId: paymentMethodId,
        customerId: stripeCustomerId,
      );
      
      // Update DashboardController listing value after payment success
      final dashCtrl = Get.put(DashBoardController());
      dashCtrl.listing.value = 'paid';
      
      // Save planId for subscription management
      await GlobalsVariables.savePaymentId(planId);
      print("✅ PaymentId saved: $planId");
      
      Get.to(() => VendorBottomNavBarScreen());
      Get.snackbar("Success", "Subscription created successfully");
    } catch (e) {
      print("❌ makePayment Error: $e");
      Get.snackbar("Error", "Transaction failed. Try Later");
    }
  }

  Future<String> createStripeCustomer(String vendorId) async {
    final response = await http.post(
      Uri.parse("https://api.stripe.com/v1/customers"),
      headers: {
        'Authorization': 'Bearer sk_test_yy71U48LEjRFDAq64Hjk74y000lyzm1BY5',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'name': vendorId,
        'address[line1]': 'Vendor Default Address',
        'address[country]': 'IN',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print("✅ Stripe customer created: ${data['id']}");
      return data['id'];
    } else {
      print("❌ Failed to create customer: ${response.body}");
      throw Exception("Customer creation failed");
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentDetails(
    String intentId,
  ) async {
    final response = await http.get(
      Uri.parse("https://api.stripe.com/v1/payment_intents/$intentId"),
      headers: {
        'Authorization': 'Bearer sk_test_yy71U48LEjRFDAq64Hjk74y000lyzm1BY5',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch PaymentIntent: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> createPaymentIntentForFutureUse(
    String customerId,
    int amountInCents,
  ) async {
    final response = await http.post(
      Uri.parse("https://api.stripe.com/v1/payment_intents"),
      headers: {
        'Authorization': 'Bearer sk_test_yy71U48LEjRFDAq64Hjk74y000lyzm1BY5',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amountInCents.toString(),
        'currency': 'USD',
        'customer': customerId,
        'payment_method_types[]': 'card',
        'setup_future_usage': 'off_session', // ✅ makes method reusable
        'description': 'Subscription to premium vendor plan',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print("✅ PaymentIntent created: ${data['client_secret']}");
      return data;
    } else {
      print("❌ PaymentIntent creation failed: ${response.body}");
      throw Exception("PaymentIntent creation failed");
    }
  }

  Future<Map<String, dynamic>> fetchSetupIntentDetails(String intentId) async {
    final response = await http.get(
      Uri.parse("https://api.stripe.com/v1/setup_intents/$intentId"),
      headers: {
        'Authorization': 'Bearer sk_test_yy71U48LEjRFDAq64Hjk74y000lyzm1BY5',
      },
    );

    if (response.statusCode == 200) {
      print("✅ SetupIntent details fetched");
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch SetupIntent: ${response.body}");
    }
  }

  Future<void> createSubscription({
    required String planId,
    required String paymentMethodId,
    required String customerId, // 🔧 Added this
  }) async {
    final vendorId = GlobalsVariables.vendorId;
    if (vendorId == null) throw Exception('❌ Vendor ID is null');

    final response = await http.post(
      Uri.parse('${GlobalsVariables.baseUrlapp}/subscription'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vendorId': vendorId,
        'planId': planId,
        'paymentMethodId': paymentMethodId,
        'customerId': customerId, // 🔧 Include in payload
      }),
    );

    print(
      "▶ createSubscription response: ${response.statusCode} → ${response.body}",
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Subscription API successful');
    } else {
      throw Exception('Subscription API failed: ${response.body}');
    }
  }

  Future<void> fetchAndSetVendorSubscription() async {
    final url = Uri.parse(
      '${GlobalsVariables.baseUrlapp}/subscription',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        subscriptions.value = List<Map<String, dynamic>>.from(data);

        final matchedSub = subscriptions.firstWhereOrNull((sub) {
          final vendorId = sub['vendorId'];
          // Handle both populated (object) and unpopulated (string) vendorId
          if (vendorId is Map) {
            return vendorId['_id'] == GlobalsVariables.vendorId;
          } else if (vendorId is String) {
            return vendorId == GlobalsVariables.vendorId;
          }
          return false;
        });

        if (matchedSub != null) {
          currentVendorSubscription?.value = matchedSub;
        }
      } else {
        Get.snackbar('Error', 'Failed to load subscriptions');
      }
    } catch (e) {
      // Get.snackbar('Error', 'Something went wrong');
      // print('Subscription error: $e');
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      isCancelling.value = true;
      final url = Uri.parse('${GlobalsVariables.baseUrlapp}/subscription/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        currentVendorSubscription!.value = {};
        VendorListingController().updateListingPlan('Free', false);
      } else {
        Get.snackbar("Error", "Failed to cancel subscription.");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong.");
      print("Cancel Error: $e");
    } finally {
      isCancelling.value = false;
    }
  }
}
