import 'dart:io';
import 'dart:math' as math;
import 'package:beautician_app/controllers/vendors/auth/verdor_register_controller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/services/auths_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'widgets/map_location_picker.dart';

class BeauticianProfileCreationScreen extends StatefulWidget {
  BeauticianProfileCreationScreen({super.key});
  final vendorController = Get.put(VendorRegisterController());

  @override
  State<BeauticianProfileCreationScreen> createState() =>
      _BeauticianProfileCreationScreenState();
}

class _BeauticianProfileCreationScreenState
    extends State<BeauticianProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String phoneCountryCode = '+1';
  String whatsappCountryCode = '+1';
  String _fullPhoneNumber = '';
  String _fullWhatsappNumber = '';
  bool _isOtpSent = false;
  bool _isPhoneVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  
  final AuthService _authService = AuthService();

  File? _image;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  bool isShow = false;
  bool hasHomeService = false;
  LatLng? _selectedMapPosition;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _sendOtp() async {
    if (_fullPhoneNumber.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    final success = await _authService.sendOtp(_fullPhoneNumber);
    
    setState(() => _isSendingOtp = false);

    if (success) {
      setState(() => _isOtpSent = true);
      Get.snackbar(
        'Success',
        'OTP sent to your phone number',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _verifyOtp() async {
    final code = otpController.text.trim();
    
    if (code.isEmpty || code.length < 4) {
      Get.snackbar(
        'Error',
        'Please enter the 4-digit code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    final success = await _authService.verifyOtp(_fullPhoneNumber, code);
    
    setState(() => _isVerifyingOtp = false);

    if (success) {
      setState(() => _isPhoneVerified = true);
      Get.snackbar(
        'Success',
        'Phone number verified successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Get.to<Map<String, dynamic>>(
      () => MapLocationPicker(
        initialAddress: addressController.text,
        initialPosition: _selectedMapPosition,
      ),
    );

    if (result != null) {
      setState(() {
        addressController.text = result['address'] as String;
        _selectedMapPosition = result['position'] as LatLng;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw Exception("No front camera found."),
      );

      _cameraController = CameraController(frontCamera, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      print("Camera error: $e");
      Get.snackbar("Camera Error", "Unable to access the front camera.");
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Get.snackbar("Camera Error", "Camera is not ready.");
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();

      final bytes = await File(file.path).readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        final flippedImage = img.flipHorizontal(originalImage);
        final flippedBytes = img.encodeJpg(flippedImage);
        final flippedFile = await File(file.path).writeAsBytes(flippedBytes);
        setState(() => _image = flippedFile);
        print("Image captured: ${flippedFile.path}");
      }
    } catch (e) {
      print("Capture error: $e");
      Get.snackbar("Capture Failed", "Could not capture image.");
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    shopNameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    otpController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                ),
                const SizedBox(height: 24),

                // Camera or Captured Image
                Center(
                  child:
                      _image == null
                          ? Column(
                            children: [
                              _isCameraInitialized
                                  ? ClipOval(
                                    child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width:
                                              _cameraController!
                                                  .value
                                                  .previewSize!
                                                  .height,
                                          height:
                                              _cameraController!
                                                  .value
                                                  .previewSize!
                                                  .width,
                                          child: Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationY(
                                              math.pi,
                                            ),
                                            child: CameraPreview(
                                              _cameraController!,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  : const CircularProgressIndicator(),

                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _captureImage,
                                child: const Text(
                                  "Capture",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Front camera is used",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          )
                          : GestureDetector(
                            onTap: _captureImage,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(_image!),
                              backgroundColor: kGreyColor.withOpacity(0.3),
                            ),
                          ),
                ),

                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap image to retake photo',
                    style: kSubheadingStyle.copyWith(fontSize: 12),
                  ),
                ),

                const SizedBox(height: 32),
                Text('Shop Name', style: kHeadingStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "Enter shop name",
                  controller: shopNameController,
                  inputType: TextInputType.text,
                  radius: 20,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Shop name is required'
                              : null,
                ),
                const SizedBox(height: 16),
                Text('Title/Designation', style: kHeadingStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "e.g. Professional Beautician, Hair Stylist",
                  controller: titleController,
                  inputType: TextInputType.text,
                  radius: 20,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Title is required'
                              : null,
                ),

                const SizedBox(height: 16),
                Text('Phone Number *', style: kHeadingStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                IntlPhoneField(
                  controller: phoneController,
                  enabled: !_isPhoneVerified,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _isPhoneVerified ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _isPhoneVerified ? Colors.green : Colors.grey.shade300,
                        width: _isPhoneVerified ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _isPhoneVerified ? Colors.green : kPrimaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  initialCountryCode: 'US',
                  onChanged: (phone) {
                    setState(() {
                      phoneCountryCode = phone.countryCode;
                      _fullPhoneNumber = phone.completeNumber;
                      _isOtpSent = false;
                      _isPhoneVerified = false;
                    });
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                
                if (!_isPhoneVerified) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSendingOtp || phoneController.text.isEmpty) 
                          ? null 
                          : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isSendingOtp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Verify Now',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],

                if (_isOtpSent && !_isPhoneVerified) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: otpController,
                    hintText: 'Enter 4-digit code',
                    inputType: TextInputType.number,
                    radius: 20,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifyingOtp ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifyingOtp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],

                if (_isPhoneVerified)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Phone number verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                Text('WhatsApp Number (Optional)', style: kHeadingStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                IntlPhoneField(
                  controller: whatsappController,
                  decoration: InputDecoration(
                    hintText: 'Enter WhatsApp number',
                    prefixIcon: const Icon(Icons.phone_android, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  initialCountryCode: 'US',
                  onChanged: (phone) {
                    setState(() {
                      whatsappCountryCode = phone.countryCode;
                      _fullWhatsappNumber = phone.completeNumber;
                    });
                  },
                  validator: (phone) {
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: kHeadingStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "Enter description",
                  controller: descriptionController,
                  inputType: TextInputType.multiline,
                  maxLines: 3,
                  radius: 20,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Description is required'
                              : null,
                ),

                const SizedBox(height: 24),
                Text(
                  "Do you have a physical shop?",
                  style: kHeadingStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select if customers can visit your shop/salon',
                  style: kSubheadingStyle.copyWith(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('No'),
                        value: false,
                        groupValue: isShow,
                        onChanged: (value) => setState(() => isShow = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('Yes'),
                        value: true,
                        groupValue: isShow,
                        onChanged: (value) => setState(() => isShow = value!),
                      ),
                    ),
                  ],
                ),

                if (isShow) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Shop Address *',
                    style: kHeadingStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enter your shop location',
                        style: kSubheadingStyle.copyWith(fontSize: 12, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: _openMapPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map,
                                size: 16,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pick on map',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: "Enter address",
                    controller: addressController,
                    inputType: TextInputType.streetAddress,
                    radius: 20,
                    prefixIcon: const Icon(Icons.location_on),
                    validator: (value) {
                      if (!isShow) return null;
                      return value == null || value.isEmpty
                          ? 'Address is required'
                          : null;
                    },
                  ),
                ],

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home_work, color: kPrimaryColor, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Do you provide home services?",
                                  style: kHeadingStyle.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Visit customers at their location',
                                  style: kSubheadingStyle.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: hasHomeService,
                            onChanged: (value) => setState(() => hasHomeService = value),
                            activeColor: Colors.white,
                            activeTrackColor: kPrimaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    isLoading: widget.vendorController.isLoading.value,
                    isEnabled: !widget.vendorController.isLoading.value && _isPhoneVerified,
                    title: "Continue",
                    onPressed: () {
                      if (!_isPhoneVerified) {
                        Get.snackbar(
                          'Verification Required',
                          'Please verify your phone number before continuing.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      if (_image == null) {
                        Get.snackbar(
                          "Missing Photo",
                          "Please capture a profile picture.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        widget.vendorController.setProfileInfo(
                          homeServiceAvailable: hasHomeService,
                          hasPhysicalShop: isShow,
                          shop: shopNameController.text.trim(),
                          desc: descriptionController.text.trim(),
                          titleText: titleController.text.trim(),
                          loc: addressController.text.trim(),
                          phone: _fullPhoneNumber,
                          whatsapp: _fullWhatsappNumber.isEmpty 
                            ? _fullPhoneNumber 
                            : _fullWhatsappNumber,
                          image: _image,
                          latitude: _selectedMapPosition?.latitude,
                          longitude: _selectedMapPosition?.longitude,
                        );
                        widget.vendorController.submitRegistration();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
