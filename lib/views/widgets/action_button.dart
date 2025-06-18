import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final String icon;

  const ActionButton({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Max width
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            // padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: kBlackColor,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ListTile(
              leading: Image.asset('assets/$icon.png'),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
            // child: Row(
            //   children: [
            //     Image.asset('assets/$icon.png'),
            //     SizedBox(width: 10,),
            //     Text(
            //       title,
            //       style: const TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.white,
            //         fontFamily: 'Manrope',
            //       ),
            //     ),
            //   ],
            // ),
          )),
    );
  }
}
