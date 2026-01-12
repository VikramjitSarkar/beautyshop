import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/qr_view_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../../../constants/globals.dart';

class VendorUpcomingTabScreen extends StatefulWidget {
  final bool? isShow;
  const VendorUpcomingTabScreen({super.key, this.isShow = false});

  @override
  State<VendorUpcomingTabScreen> createState() =>
      _VendorUpcomingTabScreenState();
}

class _VendorUpcomingTabScreenState extends State<VendorUpcomingTabScreen> {
  String? selectedTime = '30 min before';
  final PendingBookingController _bookingController = Get.put(
    PendingBookingController(),
  );
  VendorPastBookingController pastController = Get.put(
    VendorPastBookingController(),
  );
  @override
  void initState() {
    super.initState();
    _bookingController.fetchActiveBooking(vendorId: GlobalsVariables.vendorId!);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Obx(() {
          if (_bookingController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_bookingController.activeBooking.isEmpty) {
            return const Center(child: Text("No upcoming bookings found."));
          }

          // Sort bookings by date (latest first)
          final bookings = List<dynamic>.from(_bookingController.activeBooking);
          bookings.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['bookingDate'] ?? '');
              final dateB = DateTime.parse(b['bookingDate'] ?? '');
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });
          
          // Debug: Print first booking to check data
          if (bookings.isNotEmpty) {
            print('🔍 Upcoming Booking Data: ${bookings[0]}');
          }


          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  mainAxisExtent: widget.isShow == false ? 230 : 350,
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingItem(
                    Map<String, dynamic>.from(bookings[index]),
                  );
                },
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingItem(
                  Map<String, dynamic>.from(bookings[index]),
                );
              },
            ),
          );
        });
      },
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    String getServiceNamesWithTotal(List<dynamic> services) {
      double total = 0.0;
      final serviceList = services.map((service) {
        final name = service['serviceName'];
        final charge = double.tryParse(service['charges'].toString()) ?? 0.0;
        total += charge;
        return '$name';
      }).toList();
      final serviceText = serviceList.join(', ');
      return '$serviceText (Total: \$${total.toStringAsFixed(2)})';
    }

    final user = booking['user'] ?? {};
    final userName = user['userName'] ?? 'Client';
    final serviceNames = booking['services'];
    final profileImage = booking['user']?['profileImage'] ?? '';
    
    // Extract booking details
    final bookingDateStr = booking['bookingDate'];
    final serviceLocationType = booking['serviceLocationType'] ?? 'salon';
    final userLocation = booking['userLocation'] ?? {};
    final userPhone = user['phone'] ?? '';
    
    // Parse and format date/time
    String formattedDate = 'N/A';
    String formattedTime = 'N/A';
    print('📅 Upcoming - bookingDateStr: $bookingDateStr');
    print('📅 Upcoming - serviceLocationType: $serviceLocationType');
    try {
      if (bookingDateStr != null && bookingDateStr.toString().isNotEmpty) {
        final dateTime = DateTime.parse(bookingDateStr.toString());
        formattedDate = DateFormat('EEE, MMM d, yyyy').format(dateTime);
        formattedTime = DateFormat('h:mm a').format(dateTime);
        print('✅ Upcoming - Formatted Date: $formattedDate, Time: $formattedTime');
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    
    // Determine address to display
    String displayAddress = 'No address';
    if (serviceLocationType == 'home' && userLocation['address'] != null) {
      displayAddress = userLocation['address'];
    } else if (user['locationAdress'] != null) {
      displayAddress = user['locationAdress'];
    }

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
            if (widget.isShow == true && user['profileImage'] != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    user['profileImage'],
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
                        border: profileImage.isEmpty ? Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1) : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: profileImage.isNotEmpty
                            ? Image.network(
                                profileImage,
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
                                userName,
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
                                await pastController.deleteBooking(booking['_id']);
                                await _bookingController.fetchActiveBooking(vendorId: GlobalsVariables.vendorId!);
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
                        const SizedBox(height: 8),
                        // Service Location Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: serviceLocationType == 'home' 
                                ? Colors.orange.shade50 
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: serviceLocationType == 'home'
                                  ? Colors.orange.shade200
                                  : Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                serviceLocationType == 'home' ? Icons.home : Icons.store,
                                size: 12,
                                color: serviceLocationType == 'home'
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                serviceLocationType == 'home' ? 'Home Service' : 'Salon Visit',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: serviceLocationType == 'home'
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: kGreyColor),
                            const SizedBox(width: 6),
                            Text(
                              formattedDate,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Time
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: kGreyColor),
                            const SizedBox(width: 6),
                            Text(
                              formattedTime,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Address
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: kGreyColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                displayAddress,
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
                        if (userPhone.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          // Phone Number
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 14, color: kGreyColor),
                              const SizedBox(width: 6),
                              Text(
                                userPhone,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          getServiceNamesWithTotal(serviceNames),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      onTap: () async {
                        Get.to(
                          () => ViewQRCodeScreen(
                            vendorId: booking['_id'],
                            qrData: booking['qrCode'] ?? '',
                          ),
                        );
                      },
                      child: Icon(Icons.qr_code),
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

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}