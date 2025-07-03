// ===============================
// File: gallery_controller.dart
// ===============================
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';

import 'dashboardController.dart';

class GalleryController extends GetxController {
  final RxList<File> galleryFiles = <File>[].obs;
  final isLoading = false.obs;
  final DashBoardController dashCtl = Get.put(DashBoardController());

  Future<void> pickGalleryMedia(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final List<XFile>? pickedFiles = await picker.pickMultipleMedia();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        if(pickedFiles.length <= 5){
          for (var media in pickedFiles) {
            final file = File(media.path);
            if (!galleryFiles.any((f) => f.path == file.path)) {
              galleryFiles.add(file);
            }
          }
          await uploadAllGalleryMedia();
        }else{
          showMaxFilesAlert(context);
        }
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar(
        "Error",
        "Failed to pick media: \${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadAllGalleryMedia() async {
    isLoading.value = true;
    final token = GlobalsVariables.vendorLoginToken;
    if (token == null) {
      Get.snackbar("Error", "Vendor token is missing");
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/update');
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    try {
      for (final file in galleryFiles) {
        final fileName = file.path.split('/').last.toLowerCase();
        final isVideo =
            fileName.endsWith('.mp4') ||
            fileName.endsWith('.mov') ||
            fileName.endsWith('.avi');

        request.files.add(
          await http.MultipartFile.fromPath(
            'gallery',
            file.path,
            contentType:
                isVideo
                    ? MediaType('video', 'mp4')
                    : MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await dashCtl.fetchVendor();
        update();

        Get.snackbar(
          "Success",
          "Media uploaded successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        galleryFiles.clear();
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Upload failed';
        print("message: $message");
        throw Exception(message);
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  void showMaxFilesAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'You can upload a maximum of 5 files in the gallery.',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyle(color: kPrimaryColor1),
            ),
          ),
        ],
      ),
    );
  }

}
