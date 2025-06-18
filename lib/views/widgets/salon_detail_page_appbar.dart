// ignore_for_file: use_key_in_widget_constructors, avoid_print

import 'dart:ui';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/chatRoomCreateController.dart';
import 'package:beautician_app/controllers/users/auth/genralController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    print('rating: $rating');
    print('imageUrl: $imageUrl');
    final controller = Get.put(ChatRoomCreateController());
    final genralController = Get.put(GenralController());
    genralController.checkFavoriteStatus(vendorId);

    void openGoogleMaps(String latitude, String longitude) async {
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Could not launch Google Maps';
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not open Google Maps: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child:
              imageUrl.isNotEmpty
                  ? Image.network(
                    imageUrl,
                    height: 380,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackImage();
                    },
                  )
                  : _buildFallbackImage(),
        ),
        Container(
          height: 380,
          width: double.infinity,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Image.asset('assets/arrow.png'),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      final shareText =
                          '$shopeName\n\n$desc\n\n📍 Location: https://www.google.com/maps/search/?api=1&query=$vendorLat,$vendorLong';
                      await Share.share(shareText);
                    },
                    child: Image.asset('assets/share.png'),
                  ),
                  const SizedBox(width: 5),
                  Obx(
                    () => InkWell(
                      onTap: () => genralController.toggleFavorite(vendorId),
                      child: Icon(
                        genralController.isFavorite.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            genralController.isFavorite.value
                                ? Colors.red
                                : Colors.grey,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff15B007),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildRatingStars(rating),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopeName,
                          style: kHeadingStyle.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (GlobalsVariables.token != null) {
                              final chatData = await controller.createChatRoom(
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
                          icon: const Icon(Icons.chat, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => openGoogleMaps(vendorLat, vendorLong),
                        child: Image.asset('assets/directions.png'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    final smileys = ["😡", "🙁", "🙂", "😃"];

    int activeIndex = rating.floor().clamp(0, smileys.length - 1);

    return Row(
      children: [
        ...List.generate(
          smileys.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              smileys[index],
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(
                  index == activeIndex ? 1.0 : 0.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(180);
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
