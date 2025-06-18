import 'package:flutter/material.dart';

class CustomPageIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const CustomPageIndicator({
    Key? key,
    required this.currentIndex,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (index) {
          bool isActive = index == currentIndex;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: isActive ? 20 : 6, // Active dot is longer
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}
