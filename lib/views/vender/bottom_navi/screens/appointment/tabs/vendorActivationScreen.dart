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

  late Timer _timer;
  Duration _remainingTime = const Duration(minutes: 45);
  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _startTimer();
    // Listen to push notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      print('Received message: $title');
      if (title == 'Booking Cancelled') {
        Get.snackbar('Booking Cancelled', 'The booking has been cancelled.');
        Get.offAll(() => BottomNavBarScreen());
      }
    });
  }

  Future<void> _initializeSocket() async {
    await socketController.connectIfNotConnected();
    socketController.register(widget.vendorId, 'vendor');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() => _remainingTime -= const Duration(seconds: 1));
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _completeBooking() async {
    setState(() => _isLoading = true);

    try {
      final apiSuccess = await completeController.completeBooking(
        widget.bookingId,
      );
      if (!apiSuccess) throw Exception('API failed');

      socketController.socket.emitWithAck(
        'complete-booking',
        {'bookingId': widget.bookingId},
        ack: (response) {
          setState(() => _isLoading = false);
          if (response is Map && response['status'] == 'success') {
            setState(() => _isCompleted = true);
            Get.offAll(() => BottomNavBarScreen());
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back navigation unless user taps cancel
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Active Booking'),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: _isCompleted ? _buildSuccessUI() : _buildActiveUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.check_circle, color: Colors.green, size: 100),
      const SizedBox(height: 20),
      Text(
        'Booking #${widget.bookingId.substring} completed!',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,

          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildActiveUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        _formatDuration(_remainingTime),
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 40),
      ElevatedButton(
        onPressed: _isLoading ? null : _completeBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor1,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
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
      TextButton.icon(
        onPressed: _showCancelDialog,
        icon: const Icon(Icons.cancel, color: Colors.red),
        label: const Text(
          "Cancel Booking",
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
      ),
    ],
  );
  void _showCancelDialog() {
    Get.defaultDialog(
      title: "Cancel Booking?",
      middleText: "Are you sure you want to cancel this booking?",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Close dialog
        await PendingBookingController().rejectBooking(widget.bookingId);
        Get.offAll(() => BottomNavBarScreen());
      },
      onCancel: () {}, // Do nothing
    );
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
