import 'dart:io';
import 'dart:math' as math;
import 'package:beautician_app/controllers/vendors/auth/verdor_register_controller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

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

  File? _image;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  bool isShow = false;
  bool hasHomeService = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
                  child: SvgPicture.asset('assets/back icon.svg'),
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

                const SizedBox(height: 24),
                Text(
                  "Shop and Location/Address",
                  style: kHeadingStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('Off'),
                        value: false,
                        groupValue: isShow,
                        onChanged: (value) => setState(() => isShow = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('On'),
                        value: true,
                        groupValue: isShow,
                        onChanged: (value) => setState(() => isShow = value!),
                      ),
                    ),
                  ],
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

                if (isShow) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Location / Address',
                    style: kHeadingStyle.copyWith(fontSize: 14),
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
                SwitchListTile(
                  title: Text("Provide Home Service?", style: kSubheadingStyle),
                  value: hasHomeService,
                  onChanged: (value) => setState(() => hasHomeService = value),
                ),

                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    isLoading: widget.vendorController.isLoading.value,
                    isEnabled: !widget.vendorController.isLoading.value,
                    title: "Continue",
                    onPressed: () {
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
                          shop: shopNameController.text.trim(),
                          desc: descriptionController.text.trim(),
                          titleText: titleController.text.trim(),
                          loc: addressController.text.trim(),
                          image: _image,
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
