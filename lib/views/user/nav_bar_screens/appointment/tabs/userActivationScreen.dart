import 'dart:async';
import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../custom_nav_bar.dart';
import 'userReviewScreen.dart';
import 'package:beautician_app/controllers/vendors/booking/qrCodeController.dart';

class UserActivationScreen extends StatefulWidget {
  final String bookingId;
  final String userId;
  final String vendorId;

  const UserActivationScreen({
    Key? key,
    required this.bookingId,
    required this.userId,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<UserActivationScreen> createState() => _UserActivationScreenState();
}

class _UserActivationScreenState extends State<UserActivationScreen> {
  final SocketController socketController = Get.find<SocketController>();
  late Timer _timer;
  Duration _remainingTime = const Duration(minutes: 45);
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    initSocketAndEvents();
    _startTimer();
    _setupFirebaseNotificationListeners();
  }

  Future<void> initSocketAndEvents() async {
    await socketController.connectIfNotConnected();
    socketController.register(widget.userId, 'user');

    socketController.onBookingCompleted((data) {
      if (mounted && !_isCompleted) {
        print('🎯 Booking completed received via socket: $data');
        setState(() => _isCompleted = true);
        _navigateToReview();
      }
    });
  }

  void _setupFirebaseNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final data = message.data;

      if (title == 'Booking Completed' && !_isCompleted) {
        _navigateToReviewFromPush(data['bookingId'], data['vendorId']);
      } else if (title == 'Booking Rejected') {
        _navigateToCustomNavBar();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final data = message.data;

      if (title == 'Booking Completed' && !_isCompleted) {
        _navigateToReviewFromPush(data['bookingId'], data['vendorId']);
      } else if (title == 'Booking Rejected') {
        _navigateToCustomNavBar();
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final title = message.notification?.title ?? '';
        final data = message.data;

        if (title == 'Booking Completed' && !_isCompleted) {
          _navigateToReviewFromPush(data['bookingId'], data['vendorId']);
        } else if (title == 'Booking Rejected') {
          _navigateToCustomNavBar();
        }
      }
    });
  }

  void _navigateToReviewFromPush(String? bookingId, String? vendorId) {
    setState(() => _isCompleted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAll(() => ReviewScreen(
          bookingId: widget.bookingId,
          vendorId: widget.vendorId,
        ));
      }
    });
  }

  void _navigateToReview() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAll(() => ReviewScreen(
          bookingId: widget.bookingId,
          vendorId: widget.vendorId,
        ));
      }
    });
  }

  void _navigateToCustomNavBar() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Get.offAll(() => CustomerBottomNavBarScreen());
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingTime.inSeconds > 0) {
        setState(() => _remainingTime -= const Duration(seconds: 1));
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kGretLiteColor,
        appBar: AppBar(
          title: Text(
            'Active Booking',
            style: TextStyle(fontWeight: FontWeight.w600, color: kBlackColor),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: kBlackColor),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _isCompleted ? _buildSuccessUI() : _buildWaitingUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        padding: const EdgeInsets.all(25),
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
        child: Icon(Icons.check_circle, color: kPrimaryColor1, size: 90),
      ),
      const SizedBox(height: 30),
      Text(
        'Service Completed!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: kBlackColor,
        ),
      ),
      const SizedBox(height: 15),
      Text(
        'Preparing your review screen...',
        style: TextStyle(fontSize: 16, color: kGreyColor),
      ),
      const SizedBox(height: 40),
      SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            backgroundColor: kGreyColor2,
            color: kPrimaryColor1,
            minHeight: 6,
          ),
        ),
      ),
    ],
  );
  Widget _buildWaitingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Animated circular accent background for visual interest
        Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor1.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.spa_rounded, // Spa or beautician-themed icon
            size: 80,
            color: kPrimaryColor1,
          ),
        ),

        const SizedBox(height: 35),

        Text(
          'Service in Progress',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kBlackColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your beautician is currently working on your service.\nPlease wait until it’s completed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: kGreyColor),
        ),

        const SizedBox(height: 50),

        // Cancel booking button
        ElevatedButton.icon(
          onPressed: _showCancelDialog,
          icon: const Icon(Icons.cancel_outlined, size: 20),
          label: const Text(
            "Cancel Booking",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.red, width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          ),
        ),
      ],
    );
  }


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
        Get.offAll(() => CustomerBottomNavBarScreen());
      },
      onCancel: () {},
    );
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
