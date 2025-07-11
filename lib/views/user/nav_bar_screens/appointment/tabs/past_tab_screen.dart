import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/chatRoomCreateController.dart';
import 'package:beautician_app/controllers/users/home/userUpcommingBokingController.dart';
import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/reschedulingbookingScreen.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

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
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(15),
                  border: booking['vendor'] != null? (booking['vendor']['shopBanner'] != null? null : Border.all(color: Colors.lightGreen, width: 0.5)) : Border.all(color: Colors.lightGreen, width: 0.5),

                ),
                child:
                booking['vendor'] != null? booking['vendor']['shopBanner'] != null
                    ? Image.network(
                  booking['vendor']['shopBanner'],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                      Image.asset(
                        'assets/app icon 2.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                )
                    : Image.asset(
                  'assets/app icon 2.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ) : Image.asset(
                  'assets/app icon 2.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
              ),
              SizedBox(width: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vendor['shopName'] ?? 'Unkown',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await vendorPendingController.deleteBooking(
                                booking['_id'],
                              );
                              controller.fetchPastBookings();
                            },
                            child: Image(
                              image: AssetImage('assets/delete-Outline.png'),
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        vendor['locationAddres'] ??
                            vendor['location'] ??
                            'No Address Available',
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
                            TextSpan(
                              text: 'Services: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: controller.getServiceNamesWithTotal(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: kGreyColor2),
                    color: kGretLiteColor,
                  ),
                  child: Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 14,
                      color: kGreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final userId = GlobalsVariables.userId ?? '';
                    final vendorId = vendor['_id'] ?? '';

                    if (userId == null || vendorId == null) {
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
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: kPrimaryColor,
                    ),
                    child: Text(
                      'Reschedule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
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
