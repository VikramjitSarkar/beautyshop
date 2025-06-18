import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:flutter/material.dart';
import 'package:beautician_app/utils/libs.dart'; // your own imports

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;
  final String bookingId;

  NotificationDetailScreen({
    super.key,
    required this.notification,
    required this.bookingId,
  });

  bool get isRescheduled =>
      (notification['title']?.toString().toLowerCase() ?? '').contains(
        "rescheduled",
      );
  PendingBookingController vendorPendingController = Get.put(
    PendingBookingController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Detail',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(notification['createdAt']),
              style: TextStyle(color: kGreyColor),
            ),
            const Divider(height: 30),
            Text(
              notification['body'] ?? 'No details available.',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (isRescheduled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        vendorPendingController.acceptBooking(bookingId);
                      },
                      child: const Text("Accept"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        vendorPendingController.rejectBooking(bookingId);
                      },
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? isoTime) {
    if (isoTime == null) return '';
    final dateTime = DateTime.tryParse(isoTime);
    if (dateTime == null) return '';
    final time = TimeOfDay.fromDateTime(dateTime);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at $hour:${time.minute.toString().padLeft(2, '0')} $period";
  }
}
