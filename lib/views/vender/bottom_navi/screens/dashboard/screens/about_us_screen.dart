import 'dart:convert';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/edit_about_us_screen.dart';
import 'package:beautician_app/views/widgets/premium_feature_dialogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:beautician_app/constants/globals.dart';

import '../../../../../../controllers/vendors/dashboard/dashboardController.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late GoogleMapController mapController;
  
  DashBoardController get dashCtrl => Get.find<DashBoardController>();
  
  @override
  void initState() {
    super.initState();
  }

  Future<LatLng> _getLocationFromAddress() async {
    try {
      print('🔍 Starting _getLocationFromAddress...');
      
      // Fetch vendor data directly from API to get the address
      final token = GlobalsVariables.vendorLoginToken;
      final resp = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          final data = body['data'] as Map<String, dynamic>;
          final address = (data['locationAddress'] ?? '').toString().trim();
          
          print('📍 Got address from API: "$address"');
          
          if (address.isNotEmpty && address.length > 5) {
            print('🔍 Geocoding address: $address');
            try {
              List<Location> locations = await locationFromAddress(address);
              if (locations.isNotEmpty) {
                final location = locations.first;
                print('✅ SUCCESS - Geocoded to Lat: ${location.latitude}, Long: ${location.longitude}');
                return LatLng(location.latitude, location.longitude);
              } else {
                print('⚠️ Geocoding returned no results');
              }
            } catch (geocodeError) {
              print('❌ Geocoding error: $geocodeError');
            }
          } else {
            print('⚠️ No valid address: "$address"');
          }
        }
      }
      
      print('❌ Returning default LatLng(0, 0)');
      return LatLng(0, 0);
    } catch (e) {
      print('❌ Error in _getLocationFromAddress: $e');
      return LatLng(0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
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
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGreyColor2),
              ),

              child: Obx(
                () => Text(
                  dashCtrl.shopeDes.value.isNotEmpty
                      ? dashCtrl.shopeDes.value
                      : '',
                  style: kSubheadingStyle,
                  softWrap: true,
                  maxLines: 8,
                ),
              ),
            ),
            // const SizedBox(height: 10),

            const SizedBox(height: 15),
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
                child: FutureBuilder<LatLng>(
                  future: _getLocationFromAddress(),
                  builder: (context, snapshot) {
                    print('🗺️ FutureBuilder state: ${snapshot.connectionState}');
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('⏳ Map is loading...');
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      print('❌ MAP ERROR: ${snapshot.error}');
                      print('❌ MAP ERROR STACK: ${snapshot.stackTrace}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final vendorPosition = snapshot.data ?? LatLng(0, 0);
                    print('📍 Map position: Lat=${vendorPosition.latitude}, Long=${vendorPosition.longitude}');
                    
                    if (vendorPosition.latitude == 0 && vendorPosition.longitude == 0) {
                      print('⚠️ No valid location coordinates');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No location available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    print('✅ Creating GoogleMap widget');
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: vendorPosition,
                        zoom: 14.5,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('vendor_location'),
                          position: vendorPosition,
                          infoWindow: InfoWindow(
                            title: dashCtrl.shopeName.value.isNotEmpty 
                                ? dashCtrl.shopeName.value 
                                : 'Shop Location',
                            snippet: dashCtrl.locationAddress.value,
                          ),
                        ),
                      },
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        print('✅ Map controller created');
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
