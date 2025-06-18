import 'package:flutter/material.dart';

class CustomRatingButton extends StatelessWidget {
  final int rating;
  final int selectedRating;
  final VoidCallback onTap;

  const CustomRatingButton({
    Key? key,
    required this.rating,
    required this.selectedRating,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = rating == selectedRating;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightGreenAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/start_bold.png',
              height: 14,
              width: 14,
            ),
            SizedBox(width: 5), // Space between icon and text
            Text(
              "$rating.0 - ${rating - 1}.0",
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
