import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopSpecialistCardTwo extends StatelessWidget {
  final String imagePath;
  final String specialistName;
  final VoidCallback onBook;

  const TopSpecialistCardTwo({
    Key? key,
    required this.imagePath,
    required this.specialistName,
    required this.onBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: kGreyColor2,

        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 157,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[200],
              boxShadow: kCardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/$imagePath.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    specialistName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 15,),
              Row(
                children: [
                  Image.asset('assets/star.png'),
                  Text(
                    '4.0',
                    style: kSubheadingStyle,
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hair spec...',
                style: kSubheadingStyle
              ),
              SizedBox(width: 10,),
              Container(
                height: 27,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  onPressed: (){},
                  child: FittedBox(
                    child: Text('Book',style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                    ),),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
