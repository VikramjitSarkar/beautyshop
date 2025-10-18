import '../utils/libs.dart';
import '../views/widgets/saloon_card_three.dart';

class SalonCategoryWidget2 extends StatelessWidget {
  final String title;
  final List vendors;
  final Widget screen;

  const SalonCategoryWidget2({
    required this.title,
    required this.vendors,
    required this.screen,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(vendors);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header with title and "View all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: kHeadingStyle.copyWith(fontSize: 16)),
            InkWell(
              onTap: () => Get.to(() => screen),
              child: Text('View all', style: kSubheadingStyle),
            ),
          ],
        ),
        const SizedBox(height: 10),

        /// Vertical vendor list
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: vendors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final vendor = vendors[index];

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

            return SaloonCardThree(
              distanceKm: vendor['distance'],
              rating: rating,
              location: vendor['locationAddres'],
              imageUrl: vendor['profileImage'] ?? '',
              shopeName: vendor['shopName'] ?? 'No Name',
              onTap: () {
                print('galleryImages: ---------$galleyImages');
                Get.to(
                  () => SaloonDetailPageScreen(phoneNumber: vendor['phone'] ?? '',
                    rating: rating,
                    longitude: vendor['vendorLong'] ?? '',
                    latitude: vendor["vendorLat"] ?? '',
                    vendorId: vendor["_id"] ?? '',
                    desc: vendor["description"] ?? '',
                    imageUrl: vendor["shopBanner"] ?? '',
                    location: vendor["locationAddres"] ?? '',
                    galleryImage: galleyImages,
                    openingTime: Map<String, dynamic>.from(openingTime),
                    shopName: vendor["shopName"] ?? '',
                    status: vendor["status"] ?? '',
                    title: vendor["title"] ?? '',
                    userName: vendor["userName"] ?? '',
                  ),
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
