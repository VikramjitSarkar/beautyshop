import 'package:beautician_app/views/user/nav_bar_screens/home/salon_list_screen.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: ()=> Get.to(()=> SalonListScreen(title: title, categoryId: categoryId)),
                child: Text(
                  "View all",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          )
        ),
        const SizedBox(height: 10),

        /// Horizontal List of Vendors
        vendors.isEmpty? Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text("No Specialists Found")),
        ) : SizedBox(
          height: 210,
          child: ListView.builder(
            itemCount: vendors.length<=4? vendors.length : 4,
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
                  width: 250,
                  child: SaloonCardThree(
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
  }
}
