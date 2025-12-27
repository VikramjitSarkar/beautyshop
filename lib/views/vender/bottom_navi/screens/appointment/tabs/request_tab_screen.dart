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
                final user = booking['user']?['userName'] ?? 'Unknown';
                final address = booking['user']?['location'] ?? 'No address';
                final services = booking['services'];
                final profilemage =
                    booking['user']?['profileImage'] ?? 'Unknown';

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
                                  Text(
                                    address,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kGreyColor,
                                    ),
                                  ),
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
