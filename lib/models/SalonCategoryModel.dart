import 'package:beautician_app/views/user/nav_bar_screens/home/salon_list_screen.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/libs.dart';
import '../views/widgets/saloon_card_three.dart';

class SalonCategoryWidget extends StatelessWidget {
  final String title;
  final String categoryId;
  final List vendors;
  final Widget screen;

  const SalonCategoryWidget({
    required this.title,
    required this.vendors,
    required this.screen,
    super.key, required this.categoryId,
  });
  @override
  Widget build(BuildContext context) {
    if (vendors.isNotEmpty) {
      final rawRating = vendors[0]['shopRating']?.toString() ?? '0';
      print('Parsed Rating: ${double.tryParse(rawRating) ?? 'Invalid'}');
    }

    if(vendors.isEmpty){
      return Container();
    }

    return FutureBuilder<Position?>(
      future: _getUserLocation(),
      builder: (context, snapshot) {
        final userPosition = snapshot.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(
                          () => SalonListScreen(title: title, categoryId: categoryId),
                    ),
                    child: const Text(
                      "View all",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /// Horizontal List of Vendors
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vendors.length <= 4 ? vendors.length : 4,
                itemBuilder: (context, index) {
                  final vendor = vendors[index];

                  if (vendor == null || vendor is! Map<String, dynamic>) {
                    return const SizedBox.shrink();
                  }

                  final rating = double.tryParse(vendor['shopRating']?.toString() ?? '0') ?? 0;

                  final openingTimeRaw = vendor['openingTime'];
                  final openingTime = (openingTimeRaw == null ||
                      (openingTimeRaw is Map && openingTimeRaw.isEmpty))
                      ? {
                    "weekdays": {"from": "", "to": ""},
                    "weekends": {"from": "", "to": ""},
                  }
                      : Map<String, dynamic>.from(openingTimeRaw);

                  final galleryImages = vendor['gallery'] is List
                      ? List<String>.from(vendor['gallery'])
                      : [];

                  // calculate distance
                  String distanceKm = "Unknown";
                  if (userPosition != null &&
                      vendor['vendorLat'] != null &&
                      vendor['vendorLong'] != null) {
                    final vendorLat = double.tryParse(vendor['vendorLat'].toString());
                    final vendorLong = double.tryParse(vendor['vendorLong'].toString());

                    if (vendorLat != null && vendorLong != null) {
                      final meters = Geolocator.distanceBetween(
                        userPosition.latitude,
                        userPosition.longitude,
                        vendorLat,
                        vendorLong,
                      );
                      distanceKm = (meters / 1000).toStringAsFixed(1); // km
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 250,
                      child: SaloonCardThree(
                        distanceKm: distanceKm,
                        rating: rating,
                        location: vendor['locationAddres'],
                        imageUrl: vendor['shopBanner'] ?? '',
                        shopeName: vendor['shopName'] ?? 'No Name',
                        onTap: () {
                          Get.to(
                                () => SaloonDetailPageScreen(
                              phoneNumber: vendor['phone'] ?? '',
                              rating: rating,
                              longitude: vendor['vendorLong'] ?? '',
                              latitude: vendor["vendorLat"] ?? '',
                              galleryImage: galleryImages,
                              vendorId: vendor["_id"] ?? '',
                              desc: vendor["description"] ?? '',
                              imageUrl: vendor["shopBanner"] ?? '',
                              location: vendor["locationAddres"] ?? '',
                              openingTime: openingTime,
                              shopName: vendor["shopName"] ?? '',
                              status: vendor["status"] ?? '',
                              title: vendor["title"] ?? '',
                              userName: vendor["userName"] ?? '',
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Helper function
  Future<Position?> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

}
