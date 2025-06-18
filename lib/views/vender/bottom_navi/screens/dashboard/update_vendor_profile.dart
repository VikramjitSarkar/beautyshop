import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class VendorUpdateProfileScreen extends StatefulWidget {
  final String vendorId;
  final String token;

  const VendorUpdateProfileScreen({
    super.key,
    required this.vendorId,
    required this.token,
  });

  @override
  State<VendorUpdateProfileScreen> createState() =>
      _VendorUpdateProfileScreenState();
}

class _VendorUpdateProfileScreenState extends State<VendorUpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> vendorData = {};
  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVendorData();
  }

  Future<void> fetchVendorData() async {
    try {
      final res = await http.get(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/vendor/byVendorId/${widget.vendorId}',
        ),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == 'success') {
          vendorData = json['data'];
          userNameController.text = vendorData['userName'] ?? '';
          shopNameController.text = vendorData['shopName'] ?? '';
          emailController.text = vendorData['email'] ?? '';
          phoneController.text = vendorData['phone'] ?? '';
          descriptionController.text = vendorData['description'] ?? '';
          addressController.text = vendorData['locationAddres'] ?? '';
        }
      }
    } catch (e) {
      print("Error fetching vendor: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateVendorProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final updatedData = {
      "_id": widget.vendorId,
      "userName": userNameController.text,
      "shopName": shopNameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "description": descriptionController.text,
      "locationAddres": addressController.text,
      "profileImage": vendorData['profileImage'] ?? "",
      "gender": vendorData['gender'] ?? "",
      "listingPlan": vendorData['listingPlan'] ?? "free",
      "status": vendorData['status'] ?? "offline",
      "accountStatus": vendorData['accountStatus'] ?? "pending",
      "hasPhysicalShop": vendorData['hasPhysicalShop'] ?? false,
      "homeServiceAvailable": vendorData['homeServiceAvailable'] ?? false,
      "isProfileComplete": true,
      "age": vendorData['age'] ?? '',
      "surname": vendorData['surname'] ?? '',
      "cnic": vendorData['cnic'] ?? '',
      "avgRating": vendorData['avgRating'] ?? '0.0',
    };

    final res = await http.put(
      Uri.parse("${GlobalsVariables.baseUrlapp}/vendor/update"),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    setState(() => isSubmitting = false);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        Get.snackbar("Success", "Profile updated successfully");
        Get.back(); // Return to detail screen
      } else {
        Get.snackbar("Failed", json['message'] ?? "Something went wrong");
      }
    } else {
      Get.snackbar("Error", "Failed to update profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Vendor Profile")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Basic Info"),
                      const SizedBox(height: 10),
                      _buildTextField(userNameController, "User Name", true),
                      _buildTextField(shopNameController, "Shop Name"),

                      const SizedBox(height: 20),
                      _buildSectionHeader("Contact Info"),
                      const SizedBox(height: 10),
                      _buildTextField(emailController, "Email"),
                      _buildTextField(phoneController, "Phone"),
                      _buildTextField(addressController, "Address"),

                      const SizedBox(height: 20),
                      _buildSectionHeader("Shop Description"),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : updateVendorProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              isSubmitting
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "Save Changes",
                                    style: TextStyle(color: Colors.black),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    bool isRequired = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator:
            isRequired
                ? (value) => value == null || value.isEmpty ? 'Required' : null
                : null,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
