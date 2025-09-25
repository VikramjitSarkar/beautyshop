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
    print("genders: ${profileController.name.value}");
  }

  void _initializeForm() {
    nameController.text = profileController.name.value;
    emailController.text = profileController.email.value;
    phoneController.text = profileController.phoneNumber.value;
    birthDateController.text = profileController.dateOfBirth.value;
    addressController.text = profileController.locationAddress.value;
    gender = profileController.gender.value.trim().toLowerCase();
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

  DateTime? _selectedDob;

  Future<void> _pickDob() async {
    final now = DateTime.now();
    // Adjust range to your needs
    final first = DateTime(now.year - 100, 1, 1);
    final last = now;

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDob ??
          (birthDateController.text.isNotEmpty
              ? DateTime.tryParse(birthDateController.text) ?? DateTime(now.year - 20, 1, 1)
              : DateTime(now.year - 20, 1, 1)),
      firstDate: first,
      lastDate: last,
      helpText: 'Select date of birth',
      // builder: (ctx, child) {
      //   return Theme(
      //     data: Theme.of(ctx).copyWith(
      //       colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: kPrimaryColor),
      //     ),
      //     child: child!,
      //   );
      // },
    );

    if (picked != null) {
      _selectedDob = picked;
      // Format as yyyy-MM-dd (backend-friendly)
      final dob =
          "${picked.year.toString().padLeft(4, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";
      birthDateController.text = dob;
      print('DOB selected: $dob');
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
      Get.snackbar('Permission Denied', 'Location permanently denied. Enable from settings.');
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLat = position.latitude.toString();
        userLong = position.longitude.toString();
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        addressController.text = address;
      }
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  static const _genderOptions = ['male', 'female', 'other'];

  String? _genderValueOrNull(String g) {
    final v = g.trim().toLowerCase();
    return _genderOptions.contains(v) ? v : null; // null avoids the assertion
  }

  String _titleCase(String v) => v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);

  Future<void> _updateProfile() async {
    if (userLat == null || userLong == null) {
      Get.snackbar('Location Required', 'Please select your location first.');
      return;
    }

    final phoneToSend = _completePhoneNumber.isNotEmpty ? _completePhoneNumber : profileController.phoneNumber.value;

    // Fallback to controller values if user didn’t touch the controls
    final genderToSend = (gender.isNotEmpty ? gender : profileController.gender.value).trim().toLowerCase();

    final dobToSend = birthDateController.text.trim().isNotEmpty ? birthDateController.text.trim() : profileController.dateOfBirth.value.trim();

    // Log payload once
    print('--- Saving profile ---');
    print('name: ${nameController.text}');
    print('email: ${emailController.text}');
    print('phone: $phoneToSend');
    print('gender: $genderToSend');
    print('dateOfBirth: $dobToSend');
    print('address: ${addressController.text}');
    print('lat: $userLat, long: $userLong');
    print('----------------------');

    // NOTE: updateUserProfile returns void; do not assign it to a variable
    await profileController.updateUserProfile(
      locationAddress: addressController.text,
      userLat: userLat!,
      userLong: userLong!,
      userName: nameController.text,
      email: emailController.text,
      phoneNumber: phoneToSend,
      dateOfBirth: dobToSend,
      gender: genderToSend,
      profileImageFile: _profileImage,
    );

    await profileController.fetchUserProfile();
    Get.back();
    Get.snackbar('Updated', 'Profile saved successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Row(children: [GestureDetector(onTap: () => Get.back(), child: SvgPicture.asset('assets/back icon.svg', height: 50))]),
            title: Text("Edit Profile", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
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
                                  ? NetworkImage(profileController.imageUrl.value)
                                  : const AssetImage('assets/placeholder.png') as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickProfileImage,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey.shade400)),
                            child: Icon(Icons.camera_alt, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildTextField(nameController, "Name", 'assets/person.png'),
                  buildTextField(emailController, "Email", 'assets/email_big.png'),
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
                    value: _genderValueOrNull(gender), // matches lowercase items
                    decoration: buildInputDecoration('assets/gender.png'),
                    items:
                        _genderOptions.map((v) {
                          return DropdownMenuItem(
                            value: v, // store lowercase
                            child: Text(_titleCase(v)), // display Title Case
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => gender = value ?? ''),
                    hint: const Text('Gender'),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDob,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: birthDateController,
                        decoration: buildInputDecoration('assets/booking.png').copyWith(hintText: "Date of Birth (tap to select)"),
                        readOnly: true,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    readOnly: true,
                    onTap: getCurrentLocation,
                    decoration: buildInputDecoration('assets/discover.png').copyWith(hintText: "Address"),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: profileController.isUpdating.value ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            // minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        child:
                            profileController.isUpdating.value
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("Save changes", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
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
                    ? Container(color: Colors.black.withOpacity(0.5), child: Center(child: CircularProgressIndicator()))
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint, String iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(controller: controller, decoration: buildInputDecoration(iconPath).copyWith(hintText: hint)),
    );
  }

  InputDecoration buildInputDecoration(String iconPath) {
    return InputDecoration(
      prefixIcon: Container(height: 22, width: 22, decoration: BoxDecoration(image: DecorationImage(image: AssetImage(iconPath), scale: 4))),
      hintStyle: TextStyle(color: kGreyColor2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
    );
  }
}
