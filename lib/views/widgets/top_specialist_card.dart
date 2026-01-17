import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';

class TopSpecialistCard extends StatelessWidget {
  final String imagePath;
  final String specialistName;
  final VoidCallback onBook;
  final void Function()? onTap;

  const TopSpecialistCard({
    Key? key,
    required this.imagePath,
    required this.specialistName,
    required this.onBook,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 135,
            width: 120,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200],
                      boxShadow: kCardShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported,
                              color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                ),
                // Book Button (Positioned outside container)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 27,
                    width: 58,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      onPressed: onBook,
                      child: FittedBox(
                        child: Text(
                          'Book',
                          style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Space for button overflow
          // Specialist Name
          Text(
            specialistName,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
