import 'package:beautician_app/controllers/users/home/userUpcommingBokingController.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/qr_scanner_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:intl/intl.dart';

class UpcomingTabScreen extends StatefulWidget {
  final bool? isShow;

  UpcomingTabScreen({super.key, this.isShow = false});

  @override
  State<UpcomingTabScreen> createState() => _UpcomingTabScreenState();
}

class _UpcomingTabScreenState extends State<UpcomingTabScreen> {
  final UserUpCommingbookingController controller = Get.put(
    UserUpCommingbookingController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Obx(() {
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

          if (controller.pendingBookings.isEmpty) {
            return const Center(child: Text('No upcoming bookings found'));
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: _buildBookingList(sizingInformation),
          );
        });
      },
    );
  }

  Widget _buildBookingList(SizingInformation sizingInformation) {
    final bookings = controller.pendingBookings;

    if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 15,
          mainAxisExtent: widget.isShow == false ? 230 : 350,
        ),
        itemCount: bookings.length,
        itemBuilder:
            (context, index) => GestureDetector(
              onTap: () => _showBookingDetailsDialog(bookings[index]),
              child: _buildBookingItem(bookings[index]),
            ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder:
          (context, index) => GestureDetector(
            onTap: () => _showBookingDetailsDialog(bookings[index]),
            child: _buildBookingItem(bookings[index]),
          ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    final vendor = (booking['vendor'] as Map<String, dynamic>?) ?? {};
    final services = booking['services'] as List<dynamic>;
    final shopName = vendor['shopName'] ?? 'Unkown';
    final address =
        vendor['locationAddres'] ??
        vendor['location'] ??
        'No Address Available';
    final serviceNames = controller.getServiceNamesWithTotal(services);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isShow == true &&
                  vendor['gallery'] != null &&
                  vendor['gallery'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    vendor['gallery'][0],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (widget.isShow == true) const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isShow == false)
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: booking['vendor'] != null? (booking['vendor']['shopBanner'] != null? null : Border.all(color: Colors.lightGreen, width: 0.5)) : Border.all(color: Colors.lightGreen, width: 0.5),

                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                    ),
                  if (widget.isShow == false) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                shopName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await vendorPendingController.deleteBooking(
                                  booking['_id'],
                                );
                                controller.fetchPendingBookings();
                              },
                              child: Image.asset(
                                'assets/delete-Outline.png',
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(color: kGreyColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Services: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: serviceNames,
                                style: TextStyle(
                                  color: kGreyColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isShow == true) ...[
                          const SizedBox(height: 6),
                          Text(
                            booking['status'] ?? 'Unknown Status',
                            style: TextStyle(
                              color: kPrimaryColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(
                      () => QRScannerScreen(
                        qrCode: '${booking['qrCode']}',
                        userId: booking['_id'],
                      ),
                    );
                    if (result != null) {
                      print('Scanned QR Code: $result');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: kPrimaryColor),
                  ),
                  icon: Icon(Icons.qr_code, color: kPrimaryColor),
                  label: Text(
                    'Show QR',
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
