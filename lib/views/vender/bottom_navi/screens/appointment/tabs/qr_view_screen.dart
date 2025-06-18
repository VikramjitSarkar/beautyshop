import 'dart:convert';
import 'dart:typed_data';
import 'package:beautician_app/constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'vendorActivationScreen.dart';

class ViewQRCodeScreen extends StatefulWidget {
  final String vendorId;
  final String qrData; // base64 image string

  const ViewQRCodeScreen({
    Key? key,
    required this.vendorId,
    required this.qrData,
  }) : super(key: key);

  @override
  State<ViewQRCodeScreen> createState() => _ViewQRCodeScreenState();
}

class _ViewQRCodeScreenState extends State<ViewQRCodeScreen> {
  @override
  void initState() {
    super.initState();
    _listenToBookingActivatedNotification();
  }

  void _listenToBookingActivatedNotification() {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final bookingId = message.notification?.body;

      if (title == "Booking Activated" && bookingId != null) {
        _showSnackbar("Booking Activated!", Colors.green);
        Future.delayed(const Duration(milliseconds: 800), () {
          Get.to(
            () => VendorActivationScreen(
              bookingId: bookingId,
              vendorId: GlobalsVariables.vendorId!,
            ),
          );
        });
      }
    });

    // From tray
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final bookingId = message.notification?.body;

      if (title == "Booking Activated" && bookingId != null) {
        Get.to(
          () => VendorActivationScreen(
            bookingId: bookingId,
            vendorId: GlobalsVariables.vendorId!,
          ),
        );
      }
    });

    // Cold start
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null &&
          message.notification?.title == "Booking Activated") {
        final bookingId = message.notification?.body;
        print('📦 Booking ID from Notification Body: $bookingId');

        if (bookingId != null) {
          Future.delayed(const Duration(seconds: 1), () {
            Get.to(
              () => VendorActivationScreen(
                bookingId: bookingId,
                vendorId: GlobalsVariables.vendorId!,
              ),
            );
          });
        }
      }
    });
  }

  Uint8List _decodeBase64Image(String base64Str) {
    try {
      final stripped =
          base64Str.contains(',') ? base64Str.split(',').last : base64Str;
      return base64Decode(stripped);
    } catch (e) {
      print('❌ Base64 decode failed: $e');
      throw Exception('Invalid QR code');
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              _decodeBase64Image(widget.qrData),
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              "Show this QR to the user for scanning",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
