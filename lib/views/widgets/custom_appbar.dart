import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/services/location_service.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:geolocator/geolocator.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final UserProfileController profileController = Get.put(
    UserProfileController(),
  );

  final controller = Get.put(HomeController());
  final RxString currentLocation = 'Locating...'.obs;
  final RxBool isLocationLoading = false.obs;
  double lat = 0;
  double long = 0;

  CustomAppBar({super.key, required this.title}) {
    _getCurrentLocation();
  }

  // Gets just the street name and city
  String _getShortAddress(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.length >= 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return fullAddress.length > 20
        ? '${fullAddress.substring(0, 20)}...'
        : fullAddress;
  }

  Future<void> _getCurrentLocation() async {
    isLocationLoading.value = true;
    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = 'Enable location';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = 'Allow location';
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      lat = position.latitude;
      long = position.longitude;

      print("latitude and longitude are $lat $long");

      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );


      controller.filterVendorsWithin30Km(userLat: position.latitude,
        userLong: position.longitude,);
      controller.filterVendorsInCategoryByLocation(userLat: position.latitude,
        userLong: position.longitude,);

      currentLocation.value =
          address.isNotEmpty ? _getShortAddress(address) : 'Near you';

      // Save full location to controller
      profileController.locationAddress.value = address;
      profileController.userLat.value = position.latitude.toString();
      profileController.userLong.value = position.longitude.toString();
    } catch (e) {
      currentLocation.value = 'Location off';
    } finally {
      isLocationLoading.value = false;
    }
  }


  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Get.dialog(
        AlertDialog(
          title: Text("Permission Required"),
          content: Text("Location permission is permanently denied. Please enable it in app settings."),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
                Get.back();
              },
              child: Text("Open Settings"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return false;
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Widget build(BuildContext context) {
    print("lat and long are $lat $long");
    return Obx(() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Top row with temperature and notification
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //   "$greetings,",
                //   style: kHeadingStyle.copyWith(fontSize: 22),
                // ),
                // SizedBox(width: 5,),
                // Text(
                //   profileController.name.value.isNotEmpty
                //       ? profileController.name.value
                //       : 'Guest',
                //   style: kHeadingStyle.copyWith(
                //     fontWeight: FontWeight.w400,
                //     fontSize: 23,
                //   ),
                // ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    profileController.name.value.isNotEmpty? CircleAvatar(
                      radius: 30,
                      backgroundImage: profileController.imageUrl.value!=""? NetworkImage(profileController.imageUrl.value,) :

                      AssetImage("assets/empty pic.jpg", ),
                    ) : Container(),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [



                        Row(
                          children: [


                            Text(
                              'Hi,',
                              style: kHeadingStyle.copyWith(fontSize: 23),
                            ),
                            Text(
                              profileController.name.value.isNotEmpty
                                  ? profileController.name.value
                                  : 'Guest',
                              style: kHeadingStyle.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset('assets/location.svg'),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 200, // Fixed width for consistent layout
                              child:
                              isLocationLoading.value
                                  ? const LinearProgressIndicator()
                                  : Text(
                                currentLocation.value,
                                style: kSubheadingStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => SearchScreen()),
                      child: SvgPicture.asset('assets/search.svg'),
                    ),
                  ],
                ),

              ],
            ),
            // const SizedBox(height: 15),
            // Profile info row

            SizedBox(height: 30),
          ],
        ),
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(180);
}
