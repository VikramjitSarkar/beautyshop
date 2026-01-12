import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/chatRoomCreateController.dart';
import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/controllers/vendors/booking/requestBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/qr_view_screen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/reschedulingbookingScreen.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/message/tabs/vendor_chat_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:intl/intl.dart';

class RequestTabScreen extends StatelessWidget {
  RequestTabScreen({super.key});
  final RequestBookingController requestBookingController = Get.put(
    RequestBookingController(),
  );
  PendingBookingController pendingBookingController = Get.put(
    PendingBookingController(),
  );
  ChatRoomCreateController chatRoomCreateController = Get.put(
    ChatRoomCreateController(),
  );
  @override
  Widget build(BuildContext context) {
    VendorPastBookingController pastController = Get.put(
      VendorPastBookingController(),
    );
    requestBookingController.fetchRequests(); // Replace with dynamic ID

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Obx(() {
          if (requestBookingController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestBookingController.bookings.isEmpty) {
            return const Center(child: Text("No booking requests found."));
          }

          String getServiceNamesWithTotal(List<dynamic> services) {
            double total = 0.0;

            final serviceList =
                services.map((service) {
                  final name = service['serviceName'];
                  final charge =
                      double.tryParse(service['charges'].toString()) ?? 0.0;
                  total += charge;
                  return '$name ';
                }).toList();

            final serviceText = serviceList.join(', ');
            return '$serviceText \n Total: \$${total.toStringAsFixed(2)}';
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ListView.builder(
              itemCount: requestBookingController.bookings.length,
              itemBuilder: (context, index) {
                final booking = requestBookingController.bookings[index];
                print("Bookings: $booking");
                print("🔍 DEBUG - bookingDate: ${booking['bookingDate']}");
                print("🔍 DEBUG - serviceLocationType: ${booking['serviceLocationType']}");
                print("🔍 DEBUG - userLocation: ${booking['userLocation']}");
                print("🔍 DEBUG - specialRequests: ${booking['specialRequests']}");
                
                final user = booking['user']?['userName'] ?? 'Unknown';
                final services = booking['services'];
                final profilemage = booking['user']?['profileImage'] ?? 'Unknown';
                
                // Extract booking details
                final bookingDate = booking['bookingDate'];
                final serviceLocationType = booking['serviceLocationType'] ?? 'salon';
                final userLocation = booking['userLocation'];
                final specialRequests = booking['specialRequests'];
                
                // Format date and time
                String formattedDate = 'Not specified';
                String formattedTime = 'Not specified';
                if (bookingDate != null) {
                  try {
                    final date = DateTime.parse(bookingDate);
                    formattedDate = DateFormat('EEE, MMM d, yyyy').format(date);
                    formattedTime = DateFormat('h:mm a').format(date);
                  } catch (e) {
                    print('Error parsing date: $e');
                  }
                }
                
                // Get address based on service type
                String displayAddress = 'No address';
                if (serviceLocationType == 'home' && userLocation != null) {
                  displayAddress = userLocation['address'] ?? 'Address not available';
                } else if (serviceLocationType == 'salon') {
                  displayAddress = 'Visit Salon';
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(profilemage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        user,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final bookingId = booking['_id'];
                                          pendingBookingController
                                              .rejectBooking(bookingId);
                                        },
                                        child: GestureDetector(
                                          onTap: () async {
                                            await pastController.deleteBooking(
                                              booking['_id'],
                                            );
                                            await pendingBookingController
                                                .fetchBooking(
                                                  vendorId:
                                                      GlobalsVariables
                                                          .vendorId!,
                                                );
                                          },
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/delete-Outline.png',
                                            ),
                                            height: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Service location type badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: serviceLocationType == 'home' 
                                          ? Colors.orange.shade100 
                                          : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          serviceLocationType == 'home' 
                                              ? Icons.home 
                                              : Icons.store,
                                          size: 14,
                                          color: serviceLocationType == 'home' 
                                              ? Colors.orange.shade700 
                                              : Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          serviceLocationType == 'home' 
                                              ? 'Home Service' 
                                              : 'Salon Visit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: serviceLocationType == 'home' 
                                                ? Colors.orange.shade700 
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Booking date and time
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: kGreyColor),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: kGreyColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Address (for home service) or location indicator
                                  if (serviceLocationType == 'home') ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: Colors.red.shade400),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            displayAddress,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: kGreyColor,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Services: ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: getServiceNamesWithTotal(
                                            services,
                                          ),
                                          style: TextStyle(
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: kGreyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (specialRequests != null && specialRequests.toString().isNotEmpty) ...[
                                    const SizedBox(height: 10),
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
                                          Icon(Icons.note_outlined, size: 16, color: Colors.blue.shade700),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Special Request:',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  specialRequests,
                                                  style: TextStyle(
                                                    fontSize: 12,
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
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          final chatData =
                                              await chatRoomCreateController
                                                  .createChatRoom(
                                                    userId:
                                                        booking['user']?['_id'],
                                                    vendorId:
                                                        GlobalsVariables
                                                            .vendorId!,
                                                  );

                                          if (chatData != null) {
                                            Get.to(
                                              () => VendorChatScreen(
                                                vendorName: user,
                                                chatId: chatData['_id'],
                                                currentUser: chatData['other'] ,
                                                reciverId:chatData['user'],
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.chat),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //     right: 5,
                                      //   ),
                                      //   child: GestureDetector(
                                      //     onTap: () async {
                                      //       Get.to(
                                      //         () => ViewQRCodeScreen(
                                      //           vendorId: booking['_id'],
                                      //           qrData: booking['qrCode'] ?? '',
                                      //         ),
                                      //       );
                                      //     },
                                      //     child: Icon(Icons.qr_code),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Get.to(
                                  () => ReschedulingBookingScreen(
                                    bookingId: booking['_id'],
                                  ),
                                );
                              },
                              child: Container(
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: kGreyColor2),
                                  color: kGretLiteColor,
                                ),
                                child: Text(
                                  'Reschedule',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kGreyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final bookingId = booking['_id'];
                                await pendingBookingController.acceptBooking(
                                  bookingId,
                                );
                                requestBookingController.fetchRequests();
                              },
                              child: Container(
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: kPrimaryColor,
                                ),
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }
}
