import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/pastUserBookingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/reschedulingbookingScreen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class VendorPastTabScreen extends StatelessWidget {
  VendorPastTabScreen({super.key});

  final VendorPastBookingController controller = Get.put(
    VendorPastBookingController(),
  );
  String vendorId = GlobalsVariables.vendorId!; // Your vendor ID

  @override
  Widget build(BuildContext context) {
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBookings(vendorId: vendorId, status: 'past');
    });

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          if (controller.pastBookings.isEmpty) {
            return Center(child: Text('No past bookings found'));
          }

          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 230,
                ),
                itemCount: controller.pastBookings.length,
                itemBuilder: (context, index) {
                  final booking = controller.pastBookings[index];
                  return _buildBookingCard(booking, context);
                },
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ListView.builder(
              itemCount: controller.pastBookings.length,
              itemBuilder: (context, index) {
                final booking = controller.pastBookings[index];
                return _buildBookingCard(booking, context);
              },
            ),
          );
        });
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, BuildContext context) {
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

    final profileImage = booking['user']?['profileImage'] ?? '';
    final servicesText = booking['services'];
    final userName = booking['user']?['userName'] ?? 'No name';
    final userLocation = booking['user']?['location'] ?? 'No location';

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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Image
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
                              onTap: () => controller.deleteBooking(booking['_id']),
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
                                userLocation,
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
                          getServiceNamesWithTotal(servicesText),
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
                        if (booking['bookingDate'] != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 12, color: kPrimaryColor1),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(booking['bookingDate']),
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor1,
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
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        color: Colors.grey.shade50,
                      ),
                      child: Text(
                        'Review',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.to(() => ReschedulingBookingScreen(bookingId: booking['qrId'])),
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kPrimaryColor,
                        ),
                        child: Text(
                          'Reschedule',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}
