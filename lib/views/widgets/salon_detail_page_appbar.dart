import 'dart:ui';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/chatRoomCreateController.dart';
import 'package:beautician_app/controllers/users/auth/genralController.dart';
import 'package:beautician_app/controllers/users/profile/profile_controller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin, sin, pi;

class SaloonDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String vendorId;
  final String vendorLat;
  final String vendorLong;
  final String title;
  final String shopeName;
  final String desc;
  final String userName;
  final String imageUrl;
  final String status;
  final String locaion;
  final Map<String, dynamic> openingTime;
  final double rating;

  const SaloonDetailPageAppBar({
    super.key,
    required this.rating,
    required this.vendorLat,
    required this.vendorLong,
    required this.vendorId,
    required this.desc,
    required this.imageUrl,
    required this.locaion,
    required this.openingTime,
    required this.shopeName,
    required this.status,
    required this.title,
    required this.userName,
  });

  // Calculate distance using Haversine formula
  String calculateDistance(String userLat, String userLong) {
    try {
      final double? lat1 = double.tryParse(userLat);
      final double? lon1 = double.tryParse(userLong);
      final double? lat2 = double.tryParse(vendorLat);
      final double? lon2 = double.tryParse(vendorLong);

      if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
        return 'Unknown';
      }

      const double earthRadius = 6371; // km
      final double dLat = _toRadians(lat2 - lat1);
      final double dLon = _toRadians(lon2 - lon1);

      final double a = (sin(dLat / 2) * sin(dLat / 2)) +
          (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
              sin(dLon / 2) * sin(dLon / 2));

      final double c = 2 * asin(sqrt(a));
      final double distance = earthRadius * c;

      return distance.toStringAsFixed(2);
    } catch (e) {
      return 'Unknown';
    }
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomCreateController());
    final genralController = Get.put(GenralController());
    final profileController = Get.put(UserProfileController());
    genralController.checkFavoriteStatus(vendorId);
    
    final distance = calculateDistance(
      profileController.userLat.value,
      profileController.userLong.value,
    );

    void openGoogleMaps(String latitude, String longitude) async {
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        Get.snackbar(
          'Error',
          'Could not open Google Maps',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    return Stack(
      children: [
        /// Background image
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            height: 380,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackImage(),
          )
              : _buildFallbackImage(),
        ),

        /// Top Row (Back, Share, Favorite)
        Positioned(
          top: 30,
          left: 12,
          right: 12,
          child: Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  final shareText =
                      '$shopeName\n\n$desc\n\n📍 Location: https://www.google.com/maps/search/?api=1&query=$vendorLat,$vendorLong';
                  await Share.share(shareText);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                    () => InkWell(
                  onTap: () => genralController.toggleFavorite(vendorId),
                  child: Icon(
                    genralController.isFavorite.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: genralController.isFavorite.value
                        ? Colors.red
                        : Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Bottom Blur Overlay
        Positioned(
          left: 0,
          right: 0,
          bottom: 25,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 500, sigmaY: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF5F3EF), // soft beige white
                      Color(0xFFFEFEFE),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 0.6,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Status + Rating + Distance
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: status == "offline"? Colors.grey : Color(0xff15B007),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildRatingStars(rating),
                        if (distance != 'Unknown') ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$distance km',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Name and Actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            shopeName,
                            style: kHeadingStyle.copyWith(
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              if (GlobalsVariables.token != null) {
                                final chatData =
                                await controller.createChatRoom(
                                  userId: GlobalsVariables.userId!,
                                  vendorId: vendorId,
                                );
                                if (chatData != null) {
                                  Get.to(
                                        () => UserChatScreen(
                                      vendorName: shopeName,
                                      chatId: chatData['_id'],
                                      currentUser: chatData['user'],
                                      reciverId: chatData['other'],
                                    ),
                                  );
                                }
                              } else {
                                Get.to(() => UserVendorScreen());
                              }
                            },
                            icon: const Icon(Icons.chat, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: IconButton(
                            onPressed: () {
                              openGoogleMaps(vendorLat, vendorLong);
                            },
                            icon: const Icon(Icons.directions, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor().clamp(0, 5);

    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              Icons.star_rounded,  // rounded star
              size: 15,
              color: i <= rating.floor()
                  ? CupertinoColors.systemYellow
                  : Colors.grey.shade400,
            ),
          ),

        const SizedBox(width: 6),

        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(380);
}

Widget _buildFallbackImage() {
  return Container(
    height: 380,
    width: double.infinity,
    color: Colors.grey.shade300,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
  );
}
