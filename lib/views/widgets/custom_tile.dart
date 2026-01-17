import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final String imagePath;
  final String text;
  final void Function()? onPressed;
  const CustomTile({super.key, required this.imagePath, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGreyColor2),
        boxShadow: kCardShadow,
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
          child: Row(
            children: [
              Image(image: AssetImage(imagePath),height: 24,),
              SizedBox(width: 12),
              Expanded(
                child: Text(text,style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: kGreyColor
                ),),
              ),
              Icon(Icons.arrow_forward_ios,size: 14,)
            ],
          ),
        ),
      ),
    );
  }
}
