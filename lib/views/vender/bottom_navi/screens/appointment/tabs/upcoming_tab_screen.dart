import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/qr_view_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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

          final bookings = _bookingController.activeBooking;


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
    final location = user['location'] ?? 'No address';
    final serviceNames = booking['services'];
    final profileImage = booking['user']?['profileImage'] ?? '';
    final bookingDate = booking['bookingDate'] ?? '';
    final dateTime = DateTime.tryParse(bookingDate);
    final formattedDate = dateTime != null
        ? "${dateTime.day.toString().padLeft(2, '0')} ${_monthName(dateTime.month)}, ${dateTime.year}"
        : 'N/A';
    final formattedTime = dateTime != null
        ? "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}"
        : 'N/A';

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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: kGreyColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
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