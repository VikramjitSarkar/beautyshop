import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:beautician_app/controllers/vendors/booking/pastBookingController.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/appointment/tabs/qr_view_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

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

    final user = booking['user'] ?? {};
    // final services = booking['services'] as List<dynamic>? ?? [];
    final bookingDate = booking['bookingDate'] ?? '';

    final userName = user['userName'] ?? 'Client';
    final location = user['location'] ?? 'No address';
    final serviceNames = booking['services'];

    final profilemage = booking['user']?['profileImage'] ?? 'Unknown';
    final dateTime = DateTime.tryParse(bookingDate);
    final formattedDate =
        dateTime != null
            ? "${dateTime.day.toString().padLeft(2, '0')}  ${_monthName(dateTime.month)}, ${dateTime.year}"
            : 'N/A';
    final formattedTime =
        dateTime != null
            ? "${dateTime.hour.toString().padLeft(2, '0')}: ${dateTime.minute.toString().padLeft(2, '0')}"
            : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          if (widget.isShow == false)
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pastController.deleteBooking(booking['_id']);
                              },
                              child: Image(
                                image: AssetImage('assets/delete-Outline.png'),
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          location,
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
                                text: getServiceNamesWithTotal(serviceNames),
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
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  height: 180,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: const DecorationImage(
                      image: AssetImage('assets/map_appoinment.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await pastController.deleteBooking(
                                booking['_id'],
                              );
                              await _bookingController.fetchActiveBooking(
                                vendorId: GlobalsVariables.vendorId!,
                              );
                            },
                            child: const Image(
                              image: AssetImage('assets/delete-Outline.png'),
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        location,
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
                              text: serviceNames,
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
              ],
            ),
          const SizedBox(height: 10),
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: kGretLiteColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/timer.png'),
                        height: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "$formattedTime - $formattedDate",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: kGreyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Container(
                      //   height: 22,
                      //   width: 40,
                      //   padding: const EdgeInsets.all(1),
                      //   child: FittedBox(
                      //     fit: BoxFit.cover,
                      //     child: Switch(
                      //       trackOutlineColor: const WidgetStatePropertyAll(
                      //           Colors.transparent),
                      //       activeTrackColor: kPrimaryColor,
                      //       inactiveTrackColor: kGreyColor2,
                      //       inactiveThumbColor: Colors.white,
                      //       value: true,
                      //       onChanged: (value) {},
                      //     ),
                      //   ),
                      // ),
                      // Expanded(
                      //   child: DropdownButton(
                      //     isExpanded: true,
                      //     value: selectedTime,
                      //     icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      //         color: Colors.black),
                      //     dropdownColor: Colors.white,
                      //     underline: const SizedBox(),
                      //     items: [
                      //       DropdownMenuItem(
                      //         value: '30 min before',
                      //         child: Text('30 min before',
                      //             style: TextStyle(
                      //                 color: kGreyColor, fontSize: 12)),
                      //       ),
                      //       DropdownMenuItem(
                      //         value: '15 min before',
                      //         child: Text('15 min before',
                      //             style: TextStyle(
                      //                 color: kGreyColor, fontSize: 12)),
                      //       ),
                      //     ],
                      //     onChanged: (value) {
                      //       setState(() {
                      //         selectedTime = value;
                      //       });
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
