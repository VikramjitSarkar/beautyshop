import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/home/userSalonReviewController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautician_app/utils/libs.dart';

class ReviewScreen extends StatefulWidget {
  final String bookingId;
  final String vendorId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.vendorId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final UserReviewController _reviewController = Get.put(
    UserReviewController(),
  );
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool _canExit = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    GlobalsVariables.saveBookingId(widget.bookingId);
    GlobalsVariables.saveVendorBookingId(widget.vendorId);
    super.initState();

    _canExit =
        GlobalsVariables.bookingIdUser == null ||
        GlobalsVariables.bookingIdUser == '';

    reviewController.addListener(() {
      setState(() {}); // update button state
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Vendor Id : ${widget.vendorId}');
    return WillPopScope(
      onWillPop: () async => _handleExit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text('Leave a Review'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleClose(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking #${widget.bookingId}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Text('Tap to rate', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    StarRating(
                      rating: rating,
                      isEnabled: !_isSubmitting,
                      onRatingChanged: (newRating) {
                        setState(() {
                          rating =
                              (rating == newRating)
                                  ? 0
                                  : newRating; // toggle same rating
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    Text(
                      _getRatingText(rating),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tell us more (required)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'What did you like or dislike?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      (_isSubmitting ||
                              rating == 0 ||
                              reviewController.text.trim().isEmpty)
                          ? null
                          : _submitReview,
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'SUBMIT REVIEW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handleExit() async {
    if (_canExit) return true;

    if (rating > 0 || reviewController.text.trim().isNotEmpty) {
      return await _showExitConfirmation();
    }

    Get.snackbar('Required', 'Please give a rating and enter your review');
    return false;
  }

  Future<void> _handleClose() async {
    if (_canExit) {
      Get.back();
      return;
    }

    if (rating > 0 || reviewController.text.trim().isNotEmpty) {
      final shouldExit = await _showExitConfirmation();
      if (shouldExit) {
        Get.back();
      }
    } else {
      Get.snackbar('Required', 'Please give a rating and enter your review');
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Incomplete Review'),
            content: const Text(
              'You have not submitted your rating and comment. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('STAY'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('LEAVE'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Not Good';
      case 3:
        return 'Okay';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent';
      default:
        return 'Tap stars to rate';
    }
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    try {
      await _reviewController.createReview(
        widget.vendorId,
        rating,
        reviewController.text.trim(),
      );

      await GlobalsVariables.clearbookingId();
      setState(() => _canExit = true);
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// -------------------------------------------------------------------------
// ⭐ Custom Emoji Rating Widget
// -------------------------------------------------------------------------
class StarRating extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final bool isEnabled;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.isEnabled = true,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  final List<String> labels = ['Very Bad', 'Bad', 'Good', 'Great', 'Excellent'];
  final int totalStars = 5;

  void _handleGesture(Offset localPosition, double width) {
    final itemWidth = width / totalStars;
    final index = (localPosition.dx / itemWidth).floor().clamp(
      0,
      totalStars - 1,
    );
    widget.onRatingChanged(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown:
          widget.isEnabled
              ? (details) {
                final box = context.findRenderObject() as RenderBox;
                _handleGesture(
                  box.globalToLocal(details.globalPosition),
                  box.size.width,
                );
              }
              : null,
      onPanUpdate:
          widget.isEnabled
              ? (details) {
                final box = context.findRenderObject() as RenderBox;
                _handleGesture(
                  box.globalToLocal(details.globalPosition),
                  box.size.width,
                );
              }
              : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(totalStars, (index) {
          final isFilled = index < widget.rating;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFilled ? Colors.orange : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: isFilled ? Colors.orange.shade50 : Colors.white,
                  boxShadow:
                      isFilled
                          ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                          : [],
                ),
                alignment: Alignment.center,
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled ? Colors.orange : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isFilled ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
