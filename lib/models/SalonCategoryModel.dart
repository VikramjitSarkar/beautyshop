import '../utils/libs.dart';
import '../views/widgets/saloon_card_three.dart';

class SalonCategoryWidget extends StatelessWidget {
  final String title;
  final List vendors;
  final Widget screen;

  const SalonCategoryWidget({
    required this.title,
    required this.vendors,
    required this.screen,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vendors.isNotEmpty) {
      final rawRating = vendors[0]['shopRating']?.toString() ?? '0';
      print('Parsed Rating: ${double.tryParse(rawRating) ?? 'Invalid'}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        /// Horizontal List of Vendors
        SizedBox(
          height: 210,
          child: ListView.builder(
            itemCount: vendors.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final vendor = vendors[index];

              if (vendor == null || vendor is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }

              final rating =
                  double.tryParse(vendor['shopRating']?.toString() ?? '0') ?? 0;

              final openingTime = Map<String, dynamic>.from(
                vendor['openingTime'] ??
                    {
                      "weekdays": {"from": "", "to": ""},
                      "weekends": {"from": "", "to": ""},
                    },
              );

              final galleryImages =
                  vendor['gallery'] is List
                      ? List<String>.from(vendor['gallery'])
                      : [];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: 150,
                  child: SaloonCardThree(
                    rating: rating,
                    location: vendor['locationAddres'],
                    imageUrl: vendor['shopBanner'] ?? '',
                    shopeName: vendor['shopName'] ?? 'No Name',
                    onTap: () {
                      Get.to(
                        () => SaloonDetailPageScreen(phoneNumber: vendor['phone'] ?? '',
                          rating: rating,
                          longitude: vendor['vendorLong'] ?? '',
                          latitude: vendor["vendorLat"] ?? '',
                          galleryImage: galleryImages,
                          vendorId: vendor["_id"] ?? '',
                          desc: vendor["description"] ?? '',
                          imageUrl: vendor["shopBanner"] ?? '',
                          locaion: vendor["locationAddres"] ?? '',
                          openingTime: openingTime,
                          shopeName: vendor["shopName"] ?? '',
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
  }
}
