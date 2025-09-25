// lib/views/user/nav_bar_screens/profile/screens/favorite_screen.dart
// import 'package:beautician_app/controllers/users/profile/favorite_from_user_controller.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

import '../../../../../controllers/users/profile/getfavourieController.dart';

final favFromUserCtrl = Get.put(FavoriteFromUserController());

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (_, sizing) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.white,
                leading: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset('assets/back icon.svg', height: 50),
                    ),
                  ],
                ),
                title: const Text('Favorite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          body: Obx(() {
            if (favFromUserCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = favFromUserCtrl.vendors;
            if (items.isEmpty) return const Center(child: Text('No favorites found.'));

            final isDesktop = sizing.deviceScreenType == DeviceScreenType.desktop;

            if (isDesktop) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 400,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final v = items[i];
                  return _VendorCard(v);
                },
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final v = items[i];
                return _VendorCard(v);
              },
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
    // Graceful field mapping for different backend shapes
    final name   = (v['shopName'] ?? v['userName'] ?? v['name'] ?? 'No Name').toString();
    final image  = (v['profileImage'] ?? v['cover'] ?? '').toString();
    final where  = (v['locationAdress'] ?? v['locationAddres'] ?? v['address'] ?? '').toString();
    final rating = (v['avgRating'] ?? v['rating'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to vendor detail with v['_id']
      },
      child: SalonCard(
        rating: rating,
        sopeLocation: where,
        image: image,
        name: name,
        // height: optional for grid variant
      ),
    );
  }
}
