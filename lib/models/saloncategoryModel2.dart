import 'package:beautician_app/views/user/nav_bar_screens/home/salon_detail_page.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/libs.dart';
import '../views/widgets/saloon_card_three.dart';
import '../data/db_helper.dart';
import '../controllers/users/profile/profile_controller.dart';

class SalonCategoryWidget2 extends StatefulWidget {
  final String title;
  final List vendors;
  final Widget screen;

  const SalonCategoryWidget2({
    required this.title,
    required this.vendors,
    required this.screen,
    super.key,
  });

  @override
  _SalonCategoryWidget2State createState() => _SalonCategoryWidget2State();
}

class _SalonCategoryWidget2State extends State<SalonCategoryWidget2> {
  @override
  Widget build(BuildContext context) {
    print(widget.vendors);
    
    // Get shared location from profile controller
    final profileController = Get.find<UserProfileController>();
    final userLat = double.tryParse(profileController.userLat.value);
    final userLong = double.tryParse(profileController.userLong.value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header with title and "View all"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: kHeadingStyle.copyWith(fontSize: 16)),
                InkWell(
                  onTap: () => Get.to(() => widget.screen),
                  child: Text('View all', style: kSubheadingStyle),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// Vertical vendor list
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.vendors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final vendor = widget.vendors[index];

                if (vendor == null || vendor is! Map<String, dynamic>) {
                  return const SizedBox.shrink();
                }

                final openingTime =
                    vendor['openingTime'] ??
                    {
                      "weekdays": {"from": "", "to": ""},
                      "weekends": {"from": "", "to": ""},
                    };

                final double rating =
                    double.tryParse(vendor['shopRating']?.toString() ?? '0') ?? 0;

                final galleyImages =
                    vendor['gallery'] is List ? vendor['gallery'] : [];

                final vendorId = vendor['_id'] ?? '';

                // Calculate distance
                String distanceKm = "Unknown";
                if (userLat != null && userLong != null &&
                    vendor['vendorLat'] != null &&
                    vendor['vendorLong'] != null) {
                  final vendorLat = double.tryParse(vendor['vendorLat'].toString());
                  final vendorLong = double.tryParse(vendor['vendorLong'].toString());

                  if (vendorLat != null && vendorLong != null) {
                    final meters = Geolocator.distanceBetween(
                      userLat,
                      userLong,
                      vendorLat,
                      vendorLong,
                    );
                    distanceKm = (meters / 1000).toStringAsFixed(1); // km
                  }
                }

                return FutureBuilder<bool>(
                  future: DBHelper.isFavorite(vendorId),
                  builder: (context, favSnapshot) {
                    final isFav = favSnapshot.data ?? false;
                    
                    return SaloonCardThree(
                      distanceKm: distanceKm,
                      rating: rating,
                      location: (vendor['locationAddress'] ?? vendor['locationAddres'])?.toString() ?? '',
                      imageUrl: vendor['profileImage']?.toString() ?? '',
                      shopName: vendor['shopName']?.toString() ?? 'No Name',
                      isFavorite: isFav,
                      onFavoriteTap: () async {
                        final isFavorited = await DBHelper.isFavorite(vendorId);
                        if (isFavorited) {
                          await DBHelper.deleteFavorite(vendorId);
                        } else {
                          await DBHelper.insertFavorite(vendorId);
                        }
                        setState(() {});
                      },
                      onTap: () {
                        print('galleryImages: ---------$galleyImages');
                        Get.to(
                          () => SaloonDetailPageScreen(
                            phoneNumber: vendor['phone']?.toString() ?? '',
                            rating: rating,
                            longitude: vendor['vendorLong']?.toString() ?? '',
                            latitude: vendor["vendorLat"]?.toString() ?? '',
                            vendorId: vendor["_id"]?.toString() ?? '',
                            desc: vendor["description"]?.toString() ?? '',
                            imageUrl: vendor["shopBanner"]?.toString() ?? '',
                            location: (vendor["locationAddress"] ?? vendor["locationAddres"])?.toString() ?? '',
                            galleryImage: galleyImages,
                            openingTime: Map<String, dynamic>.from(openingTime),
                            shopName: vendor["shopName"]?.toString() ?? '',
                            status: vendor["status"]?.toString() ?? '',
                            title: vendor["title"]?.toString() ?? '',
                            userName: vendor["userName"]?.toString() ?? '',
                            hasPhysicalShop: vendor["hasPhysicalShop"] ?? false,
                            homeServiceAvailable: vendor["homeServiceAvailable"] ?? false,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        );
  }
}
