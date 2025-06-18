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
// If you're using CustomNavBar as a widget instead of a named route, import it
// import 'package:beautician_app/views/user/customNavBar.dart';

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
        print('🔔 Booking completed received in foreground');
        final bookingId = data['bookingId'];
        final vendorId = data['vendorId'];
        print('Booking ID: $bookingId, Vendor ID: $vendorId');
        _navigateToReviewFromPush(bookingId, vendorId);
      } else if (title == 'Booking Rejected') {
        print('❌ Booking rejected received in foreground');
        _navigateToCustomNavBar();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final data = message.data;

      if (title == 'Booking Completed' && !_isCompleted) {
        print('🔔 Booking completed tapped from background');
        final bookingId = data['bookingId'];
        final vendorId = data['vendorId'];
        print('Booking ID2: $bookingId, Vendor ID2: $vendorId');
        _navigateToReviewFromPush(bookingId, vendorId);
      } else if (title == 'Booking Rejected') {
        print('❌ Booking rejected tapped from background');
        _navigateToCustomNavBar();
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        final title = message.notification?.title ?? '';
        final data = message.data;

        if (title == 'Booking Completed' && !_isCompleted) {
          print('🔔 Booking completed opened from terminated app');
          final bookingId = data['bookingId'];
          final vendorId = data['vendorId'];
          print('Booking ID3: $bookingId, Vendor ID3: $vendorId');
          _navigateToReviewFromPush(bookingId, vendorId);
        } else if (title == 'Booking Rejected') {
          print('❌ Booking rejected opened from terminated app');
          _navigateToCustomNavBar();
        }
      }
    });
  }

  void _navigateToReviewFromPush(String? bookingId, String? vendorId) {
    setState(() => _isCompleted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAll(
          () => ReviewScreen(
            bookingId: widget.bookingId,
            vendorId: widget.vendorId,
          ),
        );
      }
    });
  }

  void _navigateToReview() {
    print(
      'Navigating to review screen... ${widget.bookingId}, ${widget.vendorId}',
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAll(
          () => ReviewScreen(
            bookingId: widget.bookingId,
            vendorId: widget.vendorId,
          ),
        );
      }
    });
  }

  void _navigateToCustomNavBar() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Get.offAll(() => CustomNavBar());
        // If using a direct widget instead:
        // Get.offAll(() => CustomNavBar());
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
      onWillPop: () async {
        // Disable back navigation unless user taps cancel
        return false;
      },
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
      Container(
        padding: const EdgeInsets.all(20),
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
        child: Icon(Icons.check_circle, color: kPrimaryColor1, size: 80),
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
        'Preparing review screen...',
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

  Widget _buildWaitingUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor1, kPrimaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor1.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(_remainingTime),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Remaining Time',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
      const SizedBox(height: 50),
      GestureDetector(
        onTap: () async {
          await PendingBookingController().rejectBooking(widget.bookingId);
          Get.offAll(() => BottomNavBarScreen());
        },
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showCancelDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red, width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 20),
                SizedBox(width: 10),
                Text(
                  "Cancel Booking",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
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
        Get.offAll(() => CustomNavBar());
      },
      onCancel: () {}, // Do nothing
    );
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
