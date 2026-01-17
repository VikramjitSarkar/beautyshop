import 'package:beautician_app/controllers/users/home/userSalonReviewController.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:beautician_app/utils/libs.dart';

class SalonReviewCard extends StatefulWidget {
  final String vendorId;
  const SalonReviewCard({super.key, required this.vendorId});

  @override
  State<SalonReviewCard> createState() => _SalonReviewCardState();
}

class _SalonReviewCardState extends State<SalonReviewCard> {
  final UserReviewController controller = Get.put(UserReviewController());

  @override
  void initState() {
    super.initState();
    controller.fetchUserReviews(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      } else if (controller.errorMessage.value.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      } else if (controller.reviews.isEmpty) {
        return Center(child: Text("No reviews yet."));
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: controller.reviews.length,
        itemBuilder: (context, index) {
          final review = controller.reviews[index];
          final user = review['user'] ?? {};
          final userName = user['userName'] ?? 'User';
          final userProfile =
              user['profileImage'] ??
              'https://via.placeholder.com/150'; // fallback image
          final createdDate =
              DateTime.tryParse(review['createdAt'] ?? '') ?? DateTime.now();
          final formattedDate = DateFormat("dd MMM, yyyy").format(createdDate);
          final rating = (double.tryParse(review['rating'].toString()) ?? 1.0)
              .clamp(1, 4);
          final comment = review['comment'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: kCardShadow,
                border: Border.all(color: kGreyColor2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userProfile),
                        radius: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 10),
                                RatingBarIndicator(
                                  rating: rating.toDouble(),
                                  itemCount: 5,
                                  itemSize: 20,
                                  itemBuilder:
                                      (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset('assets/booking.png', height: 14),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: kGreyColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: TextStyle(fontSize: 14, color: kGreyColor),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
