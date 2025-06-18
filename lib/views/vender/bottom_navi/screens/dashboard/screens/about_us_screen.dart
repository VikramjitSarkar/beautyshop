import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/edit_about_us_screen.dart';
import 'package:beautician_app/views/widgets/premium_feature_dialogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../controllers/vendors/dashboard/dashboardController.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late GoogleMapController mapController;
  final dashCtrl = Get.put(DashBoardController());
  @override
  void initState() {
    super.initState();
    dashCtrl.fetchVendor();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  dashCtrl.listing.value == 'paid'
                      ? Get.to(() => EditAboutUsScreen())
                      : showPremiumFeatureDialog(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: kSubheadingStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Text(
                dashCtrl.shopeDes.value.isNotEmpty
                    ? dashCtrl.shopeDes.value
                    : '',
                style: kSubheadingStyle,
                softWrap: true,
                maxLines: 8,
              ),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGreyColor2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/timer2.png'),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opening Hours',
                              style: kHeadingStyle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            // Text(
                            //   'Lorem ipsum dolor sit amet consectetur',
                            //   style: kSubheadingStyle,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: kGreyColor2),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Monday - Friday : ', style: kSubheadingStyle),
                      Obx(
                        () => Text(
                          dashCtrl.weekdaysFrom.value.isNotEmpty &&
                                  dashCtrl.weekdaysTo.value.isNotEmpty
                              ? '${dashCtrl.weekdaysFrom.value} - ${dashCtrl.weekdaysTo.value}'
                              : '—',
                          style: kHeadingStyle.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Saturday - Sunday:', style: kSubheadingStyle),
                      Obx(
                        () => Text(
                          dashCtrl.weekendsTo.value.isNotEmpty &&
                                  dashCtrl.weekendsFrom.value.isNotEmpty
                              ? '${dashCtrl.weekendsFrom.value} - ${dashCtrl.weekendsTo.value}'
                              : '—',
                          style: kHeadingStyle.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Google Map
            Container(
              height:
                  250, // fixed height instead of Expanded to avoid layout issues
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Obx(() {
                  final lat = double.tryParse(dashCtrl.vendorLate.value) ?? 0.0;
                  final lon = double.tryParse(dashCtrl.vendorLong.value) ?? 0.0;
                  final vendorPosition = LatLng(lat, lon);

                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: vendorPosition,
                      zoom: 14.5,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('vendor_location'),
                        position: vendorPosition,
                        infoWindow: InfoWindow(title: dashCtrl.shopeName.value),
                      ),
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
