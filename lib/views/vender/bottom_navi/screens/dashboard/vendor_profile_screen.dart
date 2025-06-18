import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/update_vendor_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  Map<String, dynamic>? vendorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVendorById();
  }

  Future<void> fetchVendorById() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${GlobalsVariables.baseUrlapp}/vendor/byVendorId/${widget.vendorId}',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          setState(() {
            vendorData = Map<String, dynamic>.from(decoded['data']);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load vendor');
      }
    } catch (e) {
      print('Error fetching vendor: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Profile"),
        actions: [
          if (!isLoading && vendorData != null)
            IconButton(
              tooltip: "Edit Profile",
              icon: const Icon(Icons.edit_note_rounded, size: 28),
              onPressed: () {
                Get.to(
                  () => VendorUpdateProfileScreen(
                    vendorId: widget.vendorId,
                    token: GlobalsVariables.vendorLoginToken!,
                  ),
                );
              },
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : vendorData == null
              ? const Center(child: Text("No data found"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                vendorData!['profileImage'] ?? '',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              vendorData!['userName'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              vendorData!['shopName'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionHeader("Contact Info"),
                    _buildInfoTile(Icons.email, 'Email', vendorData!['email']),
                    _buildInfoTile(Icons.phone, 'Phone', vendorData!['phone']),
                    const SizedBox(height: 12),
                    // _sectionHeader("Status"),
                    // _buildInfoTile(
                    //   Icons.verified_user,
                    //   'Account Status',
                    //   vendorData!['accountStatus'],
                    // ),
                    // _buildInfoTile(
                    //   Icons.workspace_premium,
                    //   'Listing Plan',
                    //   vendorData!['listingPlan'],
                    // ),
                    // const SizedBox(height: 12),
                    _sectionHeader("About Shop"),
                    _buildInfoTile(
                      Icons.description,
                      'Description',
                      vendorData!['description'] ?? 'No description',
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const Divider(thickness: 1.2),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? value) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor1),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        value ?? 'N/A',
        style: const TextStyle(color: Colors.black87),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      horizontalTitleGap: 12,
    );
  }
}
