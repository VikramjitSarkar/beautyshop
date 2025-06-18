import 'package:flutter/material.dart';
import '../../utils/text_styles.dart';

class SalonCard extends StatelessWidget {
  final String image;
  final String name;
  final double height;
  final String sopeLocation;
  final String rating;
  const SalonCard({
    super.key,
    required this.rating,
    required this.sopeLocation,
    required this.image,

    required this.name,
    this.height = 180,
  });

  bool isNetworkImage(String url) {
    return url.startsWith('http') || url.startsWith('https');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                image:
                    isNetworkImage(image)
                        ? NetworkImage(image)
                        : AssetImage('assets/$image.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: kHeadingStyle.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    rating,
                    style: kHeadingStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            sopeLocation,
            style: kSubheadingStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          SizedBox(height: 10),
          // Row(
          //   children: [
          //     Container(
          //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(30),
          //         border: Border.all(color: Color(0xffC0C0C0)),
          //       ),
          //       child: Row(
          //         children: [
          //           Image.asset(
          //             'assets/timer.png',
          //             height: 14,
          //           ),
          //           SizedBox(width: 5),
          //           Text(
          //             shopeDistance,
          //             style: kSubheadingStyle,
          //           )
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
