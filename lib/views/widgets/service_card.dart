import 'package:beautician_app/utils/text_styles.dart';
import 'package:flutter/material.dart';

import '../../utils/libs.dart';
import '../user/nav_bar_screens/home/salon_list_screen.dart';

class ServicesCard extends StatelessWidget {
  final String categoryId;
  final String title;
  final String image;
  const ServicesCard({
    super.key,
    required this.title,
    required this.image,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    print('categoryId :');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              print('title : $title');
              print('Category id : $categoryId');
              Get.to(
                () => SalonListScreen(title: title, categoryId: categoryId),
              );
            },
            child: SizedBox(
              height: 40,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 60, // wider to support 2 lines better
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
              ), // slightly smaller for tight fit
            ),
          ),
        ],
      ),
    );
  }
}
