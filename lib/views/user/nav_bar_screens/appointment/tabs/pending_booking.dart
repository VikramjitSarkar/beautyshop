import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/booking/userPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UserpendingBookingscreen extends StatefulWidget {
  final bool? isShow;

  const UserpendingBookingscreen({super.key, this.isShow = false});

  @override
  State<UserpendingBookingscreen> createState() =>
      _UserpendingBookingscreenState();
}

class _UserpendingBookingscreenState extends State<UserpendingBookingscreen> {
  final UserPendingBookngController _bookingController = Get.put(
    UserPendingBookngController(),
  );
  final VendorPastBookingController vendorPendingController = Get.put(
    VendorPastBookingController(),
  );

  @override
  void initState() {
    _bookingController.fetchUpcomingBookings();
    super.initState();
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
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      vendor['shopName'] ?? 'Unkown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vendor['locationAddres'] ??
                              vendor['location'] ??
                              'No Address Available',
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
                      _bookingController.getServiceNamesWithTotal(services),
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
          if (_bookingController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (_bookingController.bookings.isEmpty) {
            return Center(child: Text('No past bookings found'));
          }
          final bookings = _bookingController.bookings;

          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  mainAxisExtent: widget.isShow == false ? 230 : 350,
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return GestureDetector(
                    onTap: () => _showBookingDetailsDialog(booking),
                    child: buildBookingItem(booking),
                  );
                },
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ListView.builder(
              itemCount: _bookingController.bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return GestureDetector(
                  onTap: () => _showBookingDetailsDialog(booking),
                  child: buildBookingItem(booking),
                );
              },
            ),
          );
        });
      },
    );
  }

  Widget buildBookingItem(Map<String, dynamic> booking) {
    final vendor = (booking['vendor'] as Map<String, dynamic>?) ?? {};
    final services = booking['services'] as List<dynamic>;
    final bookingDate = booking['bookingDate'];
    
    final formattedDate =
        bookingDate != null
            ? DateFormat('dd MMM yyyy').format(DateTime.parse(bookingDate))
            : 'Unknown';
    final formattedTime =
        bookingDate != null
            ? DateFormat('hh:mm a').format(DateTime.parse(bookingDate))
            : '';

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
          children: [
            if (widget.isShow == false)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
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
                                    Image.asset(
                                      'assets/app icon 2.png',
                                      fit: BoxFit.cover,
                                    ),
                              )
                            : Image.asset(
                                'assets/app icon 2.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
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
                                  vendor['shopName'] ?? 'Unknown',
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
                                      middleText: "You cannot cancel this booking within 24 hours of the appointment time.\n\nAppointment: ${DateFormat('dd MMM yyyy, hh:mm a').format(bookingDate)}",
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
                                      _bookingController.fetchUpcomingBookings();
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (vendor['locationAddres'] != null || vendor['location'] != null)
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: kGreyColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    vendor['locationAddres'] ?? vendor['location'] ?? 'Unknown location',
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
                            _bookingController.getServiceNamesWithTotal(services),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                                    color: booking['serviceLocationType'] == 'home' ? Colors.orange.shade700 : Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking['serviceLocationType'] == 'home' ? 'Home Service' : 'At Salon',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: booking['serviceLocationType'] == 'home' ? Colors.orange.shade700 : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Desktop/Tablet view
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: vendor['gallery'] != null && vendor['gallery'].isNotEmpty
                            ? Image.network(
                                vendor['gallery'][0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset('assets/map_appoinment.png', fit: BoxFit.cover),
                              )
                            : Image.asset('assets/map_appoinment.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor['shopName'] ?? 'Unknown',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (vendor['locationAddres'] != null || vendor['location'] != null)
                                Text(
                                  vendor['locationAddres'] ?? vendor['location'] ?? '',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: kGreyColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                _bookingController.getServiceNamesWithTotal(services),
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                      ],
                    ),
                  ],
                ),
              ),
            // Date/Time Badge at bottom
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: Colors.black87, size: 16),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      if (formattedTime.isNotEmpty)
                        Text(
                          formattedTime,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                  if (booking['specialRequests'] != null && booking['specialRequests'].toString().isNotEmpty) ...[
                    const Spacer(),
                    Tooltip(
                      message: booking['specialRequests'],
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.note_outlined, size: 16, color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                  if (booking['serviceLocationType'] == 'salon' && vendor['vendorLat'] != null && vendor['vendorLong'] != null) ...[
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        final lat = vendor['vendorLat'];
                        final lng = vendor['vendorLong'];
                        final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.directions, size: 16, color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
