import 'dart:async';
import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautician_app/controllers/vendors/booking/completeBooingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import '../../../../../../controllers/vendors/booking/qrCodeController.dart';

class VendorActivationScreen extends StatefulWidget {
  final String bookingId;
  final String vendorId;

  const VendorActivationScreen({
    Key? key,
    required this.bookingId,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<VendorActivationScreen> createState() => _VendorActivationScreenState();
}

class _VendorActivationScreenState extends State<VendorActivationScreen> {
  final socketController = Get.find<SocketController>();
  final completeController = Get.put(CompleteBookingController());

  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _setupFirebaseListener();
  }

  Future<void> _initializeSocket() async {
    await socketController.connectIfNotConnected();
    socketController.register(widget.vendorId, 'vendor');
  }

  void _setupFirebaseListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      if (title == 'Booking Cancelled') {
        Get.snackbar('Booking Cancelled', 'The booking has been cancelled.');
        Get.offAll(() => VendorBottomNavBarScreen());
      }
    });
  }

  Future<void> _completeBooking() async {
    setState(() => _isLoading = true);
    try {
      final apiSuccess = await completeController.completeBooking(widget.bookingId);
      if (!apiSuccess) throw Exception('API failed');

      socketController.socket.emitWithAck(
        'complete-booking',
        {'bookingId': widget.bookingId},
        ack: (response) {
          setState(() => _isLoading = false);
          if (response is Map && response['status'] == 'success') {
            setState(() => _isCompleted = true);
            Future.delayed(const Duration(seconds: 2), () {
              Get.offAll(() => VendorBottomNavBarScreen());
            });
          } else {
            final err = response['message'] ?? 'Socket error';
            Get.snackbar('Error', err.toString());
          }
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to complete booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kGretLiteColor,
        appBar: AppBar(
          title: const Text(
            'Active Booking',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _isCompleted ? _buildSuccessUI() : _buildActiveUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveUI() => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      // Icon illustration (no asset needed)
      Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor1.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.handyman_rounded, // Tool icon (fits vendor/beautician)
          size: 80,
          color: kPrimaryColor1,
        ),
      ),

      const SizedBox(height: 35),
      const Text(
        'Service in Progress',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Please complete the service when done.\nThe client will then leave a review.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: kGreyColor),
      ),
      const SizedBox(height: 50),

      // Complete Booking Button
      ElevatedButton(
        onPressed: _isLoading ? null : _completeBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor1,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'COMPLETE BOOKING',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      const SizedBox(height: 20),

      // Cancel Booking
      TextButton.icon(
        onPressed: _showCancelDialog,
        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
        label: const Text(
          "Cancel Booking",
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
      ),
    ],
  );

  Widget _buildSuccessUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(Icons.check_circle, color: Colors.green, size: 90),
      ),
      const SizedBox(height: 30),
      const Text(
        'Booking Completed!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 15),
      const Text(
        'Returning to main dashboard...',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            backgroundColor: Colors.grey,
            color: Colors.green,
            minHeight: 6,
          ),
        ),
      ),
    ],
  );

  void _showCancelDialog() {
    Get.defaultDialog(
      contentPadding: EdgeInsets.all(10),
      title: "Cancel Booking?",
      middleText: "Are you sure you want to cancel this booking?",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await PendingBookingController().rejectBooking(widget.bookingId);
        Get.offAll(() => VendorBottomNavBarScreen());
      },
      onCancel: () {},
    );
  }
}
