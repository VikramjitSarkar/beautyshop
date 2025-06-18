import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/globals.dart';
import '../utils/libs.dart';

class PlanModel {
  final String id;
  final int price;
  final int durationInDays;

  PlanModel({required this.id, required this.price, required this.durationInDays});

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id'],
      price: json['price'],
      durationInDays: json['durationInDays'],
    );
  }
}

class PlanService {
  static Future<List<PlanModel>> fetchPlans() async {
    final response = await http.get(Uri.parse('${GlobalsVariables.baseUrlapp}/plans/getAll'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      List data = body['data'];
      return data.map((plan) => PlanModel.fromJson(plan)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
  }

  static Future<void> createSubscription(String planId, String paymentMethodId) async {
    final vendorId = GlobalsVariables.vendorId;
    if (vendorId == null) {
      throw Exception("Vendor ID is null");
    }

    final url = Uri.parse("${GlobalsVariables.baseUrlapp}/subscription");
    final body = {
      "vendorId": vendorId,
      "planId": planId,
      "paymentMethodId": paymentMethodId,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Subscription created successfully");
    } else {
      throw Exception("Failed to create subscription: ${response.body}");
    }
  }

}