import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

import '../../../../../controllers/users/profile/getfavourieController.dart';



final favFromUserCtrl = Get.put(FavoriteFromUserController());

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  static const double _pad = 16;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (_, sizing) {
        final isDesktop = sizing.deviceScreenType == DeviceScreenType.desktop;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pad),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.white,
                leading: Row(children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg', height: 50),
                  ),
                ]),
                title: const Text(
                  'Favorite',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          body: Obx(() {
            if (favFromUserCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = favFromUserCtrl.vendors;
            if (items.isEmpty) {
              return const Center(child: Text('No favorites found.'));
            }

            if (isDesktop) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: _pad, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 220,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _VendorCard(items[i]),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: _pad, vertical: 10),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _VendorCard(items[i]),
            );
          }),
        );
      },
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard(this.v);
  final Map<String, dynamic> v;

  @override
  Widget build(BuildContext context) {
    // Map field names defensively
    final id     = (v['_id'] ?? v['id'] ?? '').toString();
    final name   = (v['shopName'] ?? v['userName'] ?? v['name'] ?? 'No Name').toString();
    final image  = (v['profileImage'] ?? v['cover'] ?? v['image'] ?? '').toString();
    final where  = (v['locationAdress'] ?? v['locationAddres'] ?? v['address'] ?? '').toString();

    // rating may be num/string/null
    double? rating;
    final rawRating = v['avgRating'] ?? v['rating'];
    if (rawRating is num) rating = rawRating.toDouble();
    if (rawRating is String) {
      final parsed = double.tryParse(rawRating);
      if (parsed != null) rating = parsed;
    }

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to vendor detail screen
        // Get.to(() => VendorDetailPage(vendorId: id));
      },
      child: SalonCard(
        name: name,
        imageUrl: image,
        location: where,
        rating: rating,
      ),
    );
  }
}



class SalonCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final double? rating;

  const SalonCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: imageUrl.isEmpty ? Border.all(color: const Color(0xFFE8E8E8)) : null,
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 120,
            width: double.infinity,
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
                : _placeholder(),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location.isEmpty ? '—' : location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (rating != null) _RatingStars(rating: (rating!).clamp(0, 5).toDouble()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: const Icon(Icons.storefront_rounded, size: 36, color: Color(0xFFBDBDBD)),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;

    return Row(
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star_rounded, size: 16, color: Colors.amber);
        if (i == full && hasHalf) return const Icon(Icons.star_half_rounded, size: 16, color: Colors.amber);
        return const Icon(Icons.star_outline_rounded, size: 16, color: Colors.amber);
      }),
    );
  }
}
