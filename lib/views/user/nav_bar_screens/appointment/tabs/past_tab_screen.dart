import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/chatRoomCreateController.dart';
import 'package:beautician_app/controllers/users/home/userUpcommingBokingController.dart';
import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/reschedulingbookingScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../controllers/users/home/pastUserBookingController.dart';

class PastTabScreen extends StatefulWidget {
  const PastTabScreen({super.key});

  @override
  State<PastTabScreen> createState() => _PastTabScreenState();
}

final VendorPastBookingController vendorPendingController = Get.put(
  VendorPastBookingController(),
);
final UserUpCommingbookingController controller = Get.put(
  UserUpCommingbookingController(),
);
PastBookingController _bookingController = Get.put(PastBookingController());
final chatcontroller = Get.put(ChatRoomCreateController());

class _PastTabScreenState extends State<PastTabScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await GlobalsVariables.loadToken();
    _bookingController = Get.put(PastBookingController());
    _bookingController.fetchPastBookings();
  }

  @override
  Widget build(BuildContext context) {
    if (_bookingController == null || GlobalsVariables.userId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return GetX<PastBookingController>(
          init: _bookingController,
          builder: (controller) {
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

            if (controller.bookings.isEmpty) {
              return Center(child: Text('No past bookings found'));
            }

            if (sizingInformation.deviceScreenType ==
                DeviceScreenType.desktop) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 230,
                  ),
                  itemCount: controller.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = controller.bookings[index];
                    return GestureDetector(
                      onTap: () {},
                      child: _buildBookingItem(booking, controller),
                    );
                  },
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: ListView.builder(
                itemCount: controller.bookings.length,
                itemBuilder: (context, index) {
                  final booking = controller.bookings[index];
                  return GestureDetector(
                    onTap: () => _showBookingDetailsDialog(booking),
                    child: _buildBookingItem(booking, controller),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingItem(
    Map<String, dynamic> booking,
    PastBookingController controller,
  ) {
    final vendor = (booking['vendor'] as Map<String, dynamic>?) ?? {};
    final services = booking['services'] as List<dynamic>;
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
                                await vendorPendingController.deleteBooking(booking['_id']);
                                controller.fetchPastBookings();
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
                        if (vendor['locationAddres'] != null || vendor['location'] != null)
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: kGreyColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor['locationAddres'] ?? vendor['location'] ?? 'No Address Available',
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
                          controller.getServiceNamesWithTotal(services),
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
                      onTap: () async {
                        final userId = GlobalsVariables.userId ?? '';
                        final vendorId = vendor['_id'] ?? '';

                        if (userId.isEmpty || vendorId.isEmpty) {
                          Get.snackbar('Error', 'Missing user or vendor ID');
                          return;
                        }

                        try {
                          final chatData = await chatcontroller.createChatRoom(
                            userId: userId,
                            vendorId: vendorId,
                          );

                          if (chatData != null) {
                            Get.to(
                              () => UserChatScreen(
                                vendorName: vendor['userName'] ?? 'Vendor',
                                chatId: chatData['_id'],
                                currentUser: chatData['user'],
                                reciverId: chatData['other'],
                              ),
                            );
                          } else {
                            Get.snackbar("Failed", "Please try again later.", backgroundColor: Colors.white);
                          }
                        } catch (e) {
                          Get.snackbar("Failed", "Please try again later.", backgroundColor: Colors.white);
                          print('Chat room creation error: $e');
                        }
                      },
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
                        vendor['shopName'] ?? 'Unkown',
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
                          vendor['locationAddres'] ??
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
}
