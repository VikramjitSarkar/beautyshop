// ignore_for_file: use_key_in_widget_constructors, avoid_print

import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/chatRoomCreateController.dart';
import 'package:beautician_app/controllers/users/auth/genralController.dart';
import 'package:beautician_app/controllers/users/home/home_controller.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/users/home/userSalonReviewController.dart';

class SalonSpecialistDetailScreen extends StatefulWidget {
  final String vendorId;
  const SalonSpecialistDetailScreen({required this.vendorId});

  @override
  State<SalonSpecialistDetailScreen> createState() =>
      _SalonSpecialistDetailScreenState();
}

class _SalonSpecialistDetailScreenState
    extends State<SalonSpecialistDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatRoomCreateController chatRoomCreateController = Get.put(
    ChatRoomCreateController(),
  );
  final GenralController genralController = Get.put(GenralController());
  final HomeController homeController = Get.put(HomeController());
  final UserReviewController controller = Get.put(UserReviewController());

  @override
  void initState() {
    super.initState();
    controller.fetchUserReviews(widget.vendorId);
    homeController.fetchVendorById(widget.vendorId);
    genralController.checkFavoriteStatus(widget.vendorId);
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _openPhoneDialer(String phone) async {
    final url = 'tel:$phone';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch phone dialer';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not make phone call: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        final vendor = homeController.vendorData;
        final userRevew = controller.reviews;
        final List<String> smileys = ["😡", "🙁", "🙂", "😃"];
        final profileImage =
            vendor['profileImage']?.toString() ?? 'assets/layers.png';
        final userName = vendor['userName']?.toString() ?? 'Bessie Cooper';
        final status = vendor['status']?.toString() ?? '';
        // final shopName = vendor['shopName']?.toString() ?? 'Lotus Salon';
        // final description = vendor['description']?.toString() ?? "";
        final vendorId = vendor['_id'];
        final phoneNumber = vendor['phone']?.toString() ?? '';
        final galleyImages = vendor['gallery'] is List ? vendor['gallery'] : [];
        final listing = vendor['listingPlan']?.toString() ?? '';
        final isVerified = vendor['isIDVerified'] ?? false;
        final isCertified = vendor['isCertificateVerified'] ?? false;
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                surfaceTintColor: Colors.transparent,
                expandedHeight: 210,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipPath(
                        clipper: CustomClipPath(),
                        child:
                            profileImage.isEmpty
                                ? Container(
                                  width: double.infinity,
                                  height: 250,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                )
                                : Image.network(
                                  profileImage,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: double.infinity,
                                        height: 250,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(profileImage),
                                ),
                              ),
                            ),
                            isVerified == true && isCertified == true
                                ? Positioned(
                                  top: 75,
                                  left: 40,
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                  ),
                                )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: padding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Get.back(),
                              child: Image.asset('assets/arrow.png'),
                            ),
                            Obx(
                              () => InkWell(
                                onTap: () {
                                  if (GlobalsVariables.token == null) {
                                    Get.to(() => UserVendorScreen());
                                  } else {
                                    genralController.toggleFavorite(
                                      widget.vendorId,
                                    );
                                  }
                                },
                                child: Icon(
                                  genralController.isFavorite.value
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      genralController.isFavorite.value
                                          ? Colors.red
                                          : Colors.grey,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            calculateAverageRating(
                              userRevew,
                            ).toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(width: 10),
                          RatingBarIndicator(
                            rating: calculateAverageRating(userRevew),
                            itemBuilder:
                                (context, index) => Text(smileys[index]),
                            itemCount: 4,
                            itemSize: 20.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text(
                              //   "Hair Stylist at $shopName",
                              //   style: TextStyle(color: kGreyColor),
                              // ),
                            ],
                          ),
                          Row(
                            children: [
                              if (listing == 'paid')
                                GestureDetector(
                                  onTap: () {
                                    if (GlobalsVariables.token != null) {
                                      _openPhoneDialer(phoneNumber);
                                    } else {
                                      Get.to(() => UserVendorScreen());
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/phone.png',
                                    height: 44,
                                  ),
                                ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  if (GlobalsVariables.token == null) {
                                    Get.to(() => UserVendorScreen());
                                  } else {
                                    final chatData =
                                        await chatRoomCreateController
                                            .createChatRoom(
                                              userId: GlobalsVariables.userId!,
                                              vendorId: vendorId,
                                            );
                                    if (chatData != null) {
                                      Get.to(
                                        () => UserChatScreen(
                                          vendorName: userName,
                                          chatId: chatData['_id'],
                                          currentUser: chatData['user'],
                                          reciverId: chatData['other'],
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Image.asset(
                                  'assets/message2.png',
                                  height: 44,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // ReadMoreText(
                      //   description,
                      //   trimLines: 2,
                      //   colorClickableText: Colors.blue,
                      //   trimMode: TrimMode.Line,
                      //   trimCollapsedText: " Read More",
                      //   trimExpandedText: " Show Less",
                      //   style: TextStyle(color: kGreyColor),
                      //   moreStyle: const TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black,
                      //   ),
                      //   lessStyle: const TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  indicatorColor: Colors.transparent,
                  unselectedLabelColor: kGreyColor,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Gallery"),
                    Tab(text: "Services"),
                    Tab(text: "Reviews"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SalonGalleryCard(galleryMedia: galleyImages),
                      SalonServicesCard(
                        vendorId: widget.vendorId,
                        status: status,
                      ),
                      SalonReviewCard(vendorId: widget.vendorId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  double calculateAverageRating(List reviews) {
    if (reviews.isEmpty) return 0.0;
    double total = 0.0;
    for (var review in reviews) {
      total += double.tryParse(review['rating'].toString()) ?? 0.0;
    }
    return total / reviews.length;
  }
}

final List<QuiltedGridTile> basePattern = [
  QuiltedGridTile(2, 2),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
];

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
