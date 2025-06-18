import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/pastUserBookingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/reschedulingbookingScreen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
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

    // Format services list

    final profilemage = booking['user']?['profileImage'] ?? 'Unknown';
    final servicesText = booking['services'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user image or placeholder
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                  image:
                      profilemage != null
                          ? DecorationImage(
                            image: NetworkImage(profilemage),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            booking['user']['userName'] ?? 'No name',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.deleteBooking(booking['_id']);
                            },
                            child: Image(
                              image: AssetImage('assets/delete-Outline.png'),
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        booking['user']['location'] ?? 'No location',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: kGreyColor,
                        ),
                      ),
                      SizedBox(height: 5),
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
                              text: getServiceNamesWithTotal(servicesText),
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
                      SizedBox(height: 5),
                      Text(
                        'Date: ${_formatDate(booking['bookingDate'])}',
                        style: TextStyle(fontSize: 12, color: kGreyColor),
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
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: kPrimaryColor,
                  ),
                  child: MaterialButton(
                    minWidth: double.maxFinite,
                    onPressed: () {
                      Get.to(
                        () => ReschedulingBookingScreen(
                          bookingId: booking['qrId'],
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Reschedule',
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
