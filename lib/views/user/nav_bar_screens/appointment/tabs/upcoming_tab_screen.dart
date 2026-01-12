import 'package:beautician_app/controllers/users/home/userUpcommingBokingController.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

class UpcomingTabScreen extends StatefulWidget {
  final bool? isShow;

  UpcomingTabScreen({super.key, this.isShow = false});

  @override
  State<UpcomingTabScreen> createState() => _UpcomingTabScreenState();
}

class _UpcomingTabScreenState extends State<UpcomingTabScreen> {
  final UserUpCommingbookingController controller = Get.put(
    UserUpCommingbookingController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
  }

  Future<Map<String, dynamic>?> _fetchUserReviewForVendor(String vendorId) async {
    try {
      final token = GlobalsVariables.token;
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/review/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final reviews = result['data'] as List;
        // Find review for this specific vendor
        final userReview = reviews.firstWhere(
          (review) => review['vendor'] == vendorId,
          orElse: () => null,
        );
        return userReview;
      }
    } catch (e) {
      print('Error fetching user review: $e');
    }
    return null;
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accept':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'active':
        return Colors.blue;
      case 'past':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'accept':
        return Icons.check_circle;
      case 'reject':
        return Icons.cancel;
      case 'active':
        return Icons.play_circle;
      case 'past':
        return Icons.history;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Pending Approval';
      case 'accept':
        return 'Accepted';
      case 'reject':
        return 'Cancelled';
      case 'active':
        return 'Active';
      case 'past':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  void _showBookingDetailsDialog(Map<String, dynamic> booking) {
    final vendor = booking['vendor'] ?? {};
    final services = booking['services'] ?? [];
    final bookingDate = booking['bookingDate'];
    final formattedDate =
        bookingDate != null
            ? DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(DateTime.parse(bookingDate))
            : 'Unknown';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        vendor['shopName'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vendor['locationAddress'] ??
                              vendor['location'] ??
                              'Unknown location',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Services Booked',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      controller.getServiceNamesWithTotal(services),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Booking Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  // Service Location Type
                  if (booking['serviceLocationType'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Service Location',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: booking['serviceLocationType'] == 'home'
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            booking['serviceLocationType'] == 'home'
                                ? Icons.home_rounded
                                : Icons.store_rounded,
                            size: 18,
                            color: booking['serviceLocationType'] == 'home'
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking['serviceLocationType'] == 'home'
                                ? 'Home Service'
                                : 'Salon Visit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: booking['serviceLocationType'] == 'home'
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // User Location (if home service)
                  if (booking['serviceLocationType'] == 'home' &&
                      booking['userLocation'] != null &&
                      booking['userLocation']['address'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Your Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['userLocation']['address'] ??
                                  'Address not available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Special Requests/Notes
                  if (booking['specialRequests'] != null &&
                      booking['specialRequests'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Special Requests',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note_alt_outlined,
                              size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['specialRequests'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Booking Status
                  const SizedBox(height: 16),
                  Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getStatusColor(booking['status']).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(booking['status']),
                          size: 18,
                          color: _getStatusColor(booking['status']),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(booking['status']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(booking['status']),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contact Information
                  if (vendor['phone'] != null || vendor['whatsapp'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (vendor['phone'] != null)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('tel:${vendor['phone']}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone,
                                        size: 18, color: Colors.green.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Call',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (vendor['phone'] != null && vendor['whatsapp'] != null)
                          const SizedBox(width: 10),
                        if (vendor['whatsapp'] != null)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(
                                    'https://wa.me/${vendor['whatsapp']}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat,
                                        size: 18, color: Colors.green.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'WhatsApp',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // User's Review Section
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchUserReviewForVendor(vendor['_id'] ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        final review = snapshot.data!;
                        final rating = review['rating'] ?? 0;
                        final comment = review['comment'] ?? '';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Your Review',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 20, color: Colors.amber.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$rating / 5',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ...List.generate(5, (index) {
                                        return Icon(
                                          index < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber.shade700,
                                        );
                                      }),
                                    ],
                                  ),
                                  if (comment.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      comment,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // No review found
                      return SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text('Error: ${controller.errorMessage.value}'),
            );
          }

          if (controller.pendingBookings.isEmpty) {
            return const Center(child: Text('No upcoming bookings found'));
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: _buildBookingList(sizingInformation),
          );
        });
      },
    );
  }

  Widget _buildBookingList(SizingInformation sizingInformation) {
    final bookings = List<Map<String, dynamic>>.from(controller.pendingBookings);
    
    // Sort bookings by date (latest first)
    bookings.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['bookingDate'] ?? '');
        final dateB = DateTime.parse(b['bookingDate'] ?? '');
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 15,
          mainAxisExtent: widget.isShow == false ? 230 : 350,
        ),
        itemCount: bookings.length,
        itemBuilder:
            (context, index) => GestureDetector(
              onTap: () => _showBookingDetailsDialog(bookings[index]),
              child: _buildBookingItem(bookings[index]),
            ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder:
          (context, index) => GestureDetector(
            onTap: () => _showBookingDetailsDialog(bookings[index]),
            child: _buildBookingItem(bookings[index]),
          ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    final vendor = (booking['vendor'] as Map<String, dynamic>?) ?? {};
    final services = booking['services'] as List<dynamic>;
    final shopName = vendor['shopName'] ?? 'Unknown';
    final address = vendor['locationAddress'] ?? vendor['location'] ?? 'No Address Available';
    final serviceNames = controller.getServiceNamesWithTotal(services);
    final imageUrl = vendor['shopBanner'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isShow == true && vendor['gallery'] != null && vendor['gallery'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    vendor['gallery'][0],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/app icon 2.png', height: 180, fit: BoxFit.cover),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isShow == false)
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                        border: imageUrl.isEmpty ? Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1) : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset('assets/app icon 2.png', fit: BoxFit.cover),
                              )
                            : Image.asset('assets/app icon 2.png', fit: BoxFit.cover),
                      ),
                    ),
                  if (widget.isShow == false) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                shopName,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                final bookingDate = DateTime.parse(booking['bookingDate']);
                                final hoursDifference = bookingDate.difference(DateTime.now()).inHours;
                                final bookingStatus = booking['status'];

                                if (bookingStatus == 'accept' && hoursDifference < 24 && hoursDifference > 0) {
                                  Get.defaultDialog(
                                    title: "Cancellation Policy",
                                    middleText:
                                        "You cannot cancel this booking within 24 hours of the appointment time.\n\nAppointment: ${DateFormat('dd MMM yyyy, hh:mm a').format(bookingDate)}",
                                    textConfirm: "OK",
                                    confirmTextColor: Colors.white,
                                    onConfirm: () => Get.back(),
                                  );
                                  return;
                                }

                                Get.defaultDialog(
                                  title: "Cancel Booking?",
                                  middleText: "Are you sure you want to cancel this booking?",
                                  textCancel: "No",
                                  textConfirm: "Yes, Cancel",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    Get.back();
                                    await vendorPendingController.deleteBooking(booking['_id']);
                                    controller.fetchPendingBookings();
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: kGreyColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: kGreyColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          serviceNames,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (booking['bookingDate'] != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: kGreyColor),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(booking['bookingDate'])),
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time, size: 14, color: kGreyColor),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('h:mm a').format(DateTime.parse(booking['bookingDate'])),
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (booking['serviceLocationType'] != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking['serviceLocationType'] == 'home' 
                                  ? Colors.orange.shade50 
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  booking['serviceLocationType'] == 'home' ? Icons.home_rounded : Icons.store_rounded,
                                  size: 14,
                                  color: booking['serviceLocationType'] == 'home' 
                                      ? Colors.orange.shade700 
                                      : Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking['serviceLocationType'] == 'home' ? 'Home Service' : 'At Salon',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: booking['serviceLocationType'] == 'home' 
                                        ? Colors.orange.shade700 
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (widget.isShow == true && booking['status'] != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking['status'].toString().toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kPrimaryColor1,
                              ),
                            ),
                          ),
                        ],
                        if (booking['specialRequests'] != null && booking['specialRequests'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.note_outlined, size: 18, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Special Request:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking['specialRequests'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scan QR Code Button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: InkWell(
                onTap: () {
                  final userId = GlobalsVariables.userId;
                  if (userId != null) {
                    Get.to(() => QRScannerScreen(
                      userId: userId,
                      qrCode: booking['qrCode'] ?? '',
                    ));
                  } else {
                    Get.snackbar(
                      'Error',
                      'User not logged in',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 24,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Scan Vendor QR Code',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Contact Buttons
            if (vendor['phone'] != null || vendor['whatsapp'] != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    if (vendor['phone'] != null && vendor['phone'].toString().isNotEmpty)
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final uri = Uri(scheme: 'tel', path: vendor['phone'].toString());
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.call, size: 16, color: Colors.black87),
                                const SizedBox(width: 6),
                                Text(
                                  'Call',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (vendor['phone'] != null && vendor['whatsapp'] != null)
                      const SizedBox(width: 10),
                    if (vendor['whatsapp'] != null && vendor['whatsapp'].toString().isNotEmpty)
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final phone = vendor['whatsapp'].toString().replaceAll(RegExp(r'[^\d+]'), '');
                            final uri = Uri.parse('https://wa.me/$phone');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF25D366),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'WhatsApp',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
