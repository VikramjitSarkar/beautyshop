import 'dart:io';
import 'package:beautician_app/constants/globals.dart';

import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final profileController = Get.find<UserProfileController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String _completePhoneNumber = '';
  String gender = '';
  String? userLat;
  String? userLong;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    nameController.text = profileController.name.value;
    emailController.text = profileController.email.value;
    phoneController.text = profileController.phoneNumber.value;
    birthDateController.text = profileController.dateOfBirth.value;
    addressController.text = profileController.locationAddress.value;
    gender = profileController.gender.value;
    userLat = profileController.userLat.value;
    userLong = profileController.userLong.value;
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Disabled', 'Please enable Location Services.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission Denied', 'Location permission is required.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied',
        'Location permanently denied. Enable from settings.',
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLat = position.latitude.toString();
        userLong = position.longitude.toString();
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String address =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        addressController.text = address;
      }
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (userLat == null || userLong == null) {
      Get.snackbar('Location Required', 'Please select your location first.');
      return;
    }

    final success = await profileController.updateUserProfile(
      locationAddress: addressController.text,
      userLat: userLat!,
      userLong: userLong!,
      userName: nameController.text,
      email: emailController.text,
      phoneNumber:
          _completePhoneNumber.isNotEmpty
              ? _completePhoneNumber
              : profileController.phoneNumber.value,
      dateOfBirth: birthDateController.text,
      gender: gender,
      profileImageFile: _profileImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : profileController.imageUrl.value.isNotEmpty
                                  ? NetworkImage(
                                    profileController.imageUrl.value,
                                  )
                                  : AssetImage('') as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickProfileImage,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Icon(Icons.camera_alt, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildTextField(nameController, "Name", 'assets/person.png'),
                  buildTextField(
                    emailController,
                    "Email",
                    'assets/email_big.png',
                  ),
                  SizedBox(height: 10),
                  // IntlPhoneField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Phone number',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),

                  //   controller: phoneController,
                  //   onChanged: (phone) {
                  //     phoneController.text = phone.toString();
                  //   },
                  // ),
                  DropdownButtonFormField<String>(
                    value: gender.isNotEmpty ? gender : null,
                    decoration: buildInputDecoration('assets/gender.png'),
                    items:
                        ["Male", "Female", "Other"]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => gender = value ?? ''),
                    hint: Text('Gender'),
                  ),
                  SizedBox(height: 10),
                  buildTextField(
                    birthDateController,
                    "Date of Birth",
                    'assets/booking.png',
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    readOnly: true,
                    onTap: getCurrentLocation,
                    decoration: buildInputDecoration(
                      'assets/discover.png',
                    ).copyWith(hintText: "Address"),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            profileController.isUpdating.value
                                ? null
                                : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            // minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        child:
                            profileController.isUpdating.value
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  "Save changes",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () =>
                profileController.isUpdating.value
                    ? Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    String iconPath,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: buildInputDecoration(iconPath).copyWith(hintText: hint),
      ),
    );
  }

  InputDecoration buildInputDecoration(String iconPath) {
    return InputDecoration(
      prefixIcon: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(iconPath), scale: 4),
        ),
      ),
      hintStyle: TextStyle(color: kGreyColor2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
    );
  }
}
