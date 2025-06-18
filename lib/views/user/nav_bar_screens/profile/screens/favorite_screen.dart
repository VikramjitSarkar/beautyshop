import 'package:beautician_app/controllers/users/profile/getfavourieController.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:beautician_app/utils/libs.dart';

final FavoriteController favoriteController = Get.put(FavoriteController());

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    favoriteController.fetchFavoriteVendors();
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset('assets/back icon.svg', height: 44),
            ),
            title: Text(
              'Favorite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          body: Obx(() {
            if (favoriteController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (favoriteController.favorites.isEmpty) {
              return Center(child: Text('No favorites found.'));
            }

            if (sizingInformation.deviceScreenType ==
                DeviceScreenType.desktop) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 400,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: favoriteController.favorites.length,
                itemBuilder: (context, index) {
                  final vendor = favoriteController.favorites[index];
                  return GestureDetector(
                    onTap: () {
                      // TODO: Navigate to vendor detail
                    },
                    child: SalonCard(
                      rating: (vendor['avgRating'] ?? '').toString(),

                      sopeLocation: vendor['locationAddres'] ?? '',
                      height: 250,
                      image: vendor['profileImage'] ?? '',
                      name: vendor['shopName'] ?? 'No Name',
                    ),
                  );
                },
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: favoriteController.favorites.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final vendor = favoriteController.favorites[index];
                  return GestureDetector(
                    onTap: () {
                      // TODO: Navigate to vendor detail
                    },
                    child: SalonCard(
                      rating: (vendor['avgRating'] ?? '').toString(),

                      sopeLocation: vendor['locationAddres'] ?? '',
                      image: vendor['profileImage'] ?? '',
                      name: vendor['shopName'] ?? 'No Name',
                    ),
                  );
                },
              );
            }
          }),
        );
      },
    );
  }
}
