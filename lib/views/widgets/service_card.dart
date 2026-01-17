import 'package:beautician_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xffC0C0C0), width: 1),
                boxShadow: kCardShadow,
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover, // fills the container
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 70, // wider to support 2 lines better
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12,
              ), // slightly smaller for tight fit
            ),
          ),
        ],
      ),
    );
  }
}
