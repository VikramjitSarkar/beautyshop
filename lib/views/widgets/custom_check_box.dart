import 'package:beautician_app/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap; // Callback to update state in the parent

  const CustomCheckBox({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Calls the parent function to update state
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFB0FF79) : Colors.transparent, // Light green for selected
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? Color(0xFFB0FF79) : kGreyColor, // Grey border for unselected
                width: 1.5,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : SizedBox.shrink(),
          ),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : kGreyColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
           // Space between checkboxes
        ],
      ),
    );
  }
}
