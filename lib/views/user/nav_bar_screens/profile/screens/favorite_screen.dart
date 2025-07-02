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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.white,
                leading: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                    ),
                  ],
                ),
                title: Text(
                  'Favorite',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
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
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 5),
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
