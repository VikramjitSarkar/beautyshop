import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import '../../../../../../controllers/vendors/dashboard/vendorReviewController.dart';

class ReviewTabScreen extends StatelessWidget {
  const ReviewTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VendorReviewController controller = Get.put(VendorReviewController());

    final String vendorId = GlobalsVariables.vendorId!;
    controller.fetchVendorReviews(vendorId);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.reviews.isEmpty) {
        return const Center(child: Text("No reviews found."));
      }

      return ListView.builder(
        itemCount: controller.reviews.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final review = controller.reviews[index];
          final user = review['user'];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${review['rating'] ?? 0.0}",
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(width: 10),
                    _buildEmojiRating(
                      double.tryParse(review['rating'].toString()) ?? 0.0,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"${review['comment'] ?? 'No comment'}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/booking.png'),
                      height: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(review['createdAt']),
                      style: TextStyle(
                        color: kGreyColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Image(
                      image: AssetImage('assets/discover.png'),
                      height: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      review['location'] ?? 'Unknown',
                      style: TextStyle(
                        color: kGreyColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  review['description'] ?? "",
                  style: TextStyle(color: kGreyColor),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child:
                          user != null && user['profileImage'] != null
                              ? Image.network(
                                user['profileImage'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                height: 50,
                                width: 50,
                                color: Colors.black,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null && user['userName'] != null
                              ? user['userName']
                              : 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user != null && user['userName'] != null
                              ? "@${user['userName'].toLowerCase().replaceAll(' ', '')}"
                              : "@anonymous",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(),
              ],
            ),
          );
        },
      );
    });
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return 'Unknown Date';
    try {
      final dateTime = DateTime.parse(isoDate);
      return "${dateTime.day.toString().padLeft(2, '0')} ${_monthName(dateTime.month)}, ${dateTime.year}";
    } catch (_) {
      return 'Invalid Date';
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  List<String> _getEmojiSet(double rating) {
    final fullSet = ['😡', '😐', '🙂', '😊', '😍'];

    if (rating >= 4.0) {
      return fullSet; // all 5 emojis
    } else if (rating >= 3.0) {
      return fullSet.sublist(0, 4); // 4 emojis
    } else if (rating >= 2.0) {
      return fullSet.sublist(0, 3); // 3 emojis
    } else if (rating >= 1.0) {
      return fullSet.sublist(0, 2); // 2 emojis
    } else {
      return fullSet.sublist(0, 1); // 1 emoji
    }
  }

  Widget _buildEmojiRating(double rating) {
    final emojiSet = _getEmojiSet(rating);
    return Row(
      children: [
        for (final emoji in emojiSet)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
      ],
    );
  }
}
