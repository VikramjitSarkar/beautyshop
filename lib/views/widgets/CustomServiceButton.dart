import 'package:beautician_app/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomServiceButton extends StatelessWidget {
  final String serviceName;
  final String selectedService;
  final String imagePath;
  final VoidCallback onTap;

  const CustomServiceButton({
    Key? key,
    required this.serviceName,
    required this.selectedService,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = serviceName == selectedService;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.lightGreenAccent : Colors.transparent,
              image: DecorationImage(image: AssetImage(imagePath),scale: 4),
              border: Border.all(
                color: isSelected? Colors.transparent: kGreyColor
              )
            ),),
          SizedBox(height: 4),
          Text(
            serviceName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
