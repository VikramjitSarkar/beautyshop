import 'package:beautician_app/utils/text_styles.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

Future<String?> showForgotPasswordDialog(BuildContext context) async {
  int selectedIndex = -1;

  return await showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.8), // Blur effect
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.all(16), // Control the padding of the dialog
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.white,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: MediaQuery.of(context).size.width, // Max width
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    'Forgot Password',
                    style: kHeadingStyle.copyWith(
                      fontSize: 18
                    )
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Select which contact details should we use to reset your password',
                    style: kSubheadingStyle
                  ),
                  const SizedBox(height: 24),

                  // Options Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Option 1: Email
                      GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = 0);
                          Navigator.pop(context, 'Via Email');
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width / 2) - 40, // Half width
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: selectedIndex == 0
                                  ? kPrimaryColor
                                  : const Color(0xFFC0C0C0),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/via email.png',
                                width: 64,
                                height: 64,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Via Email',
                                style: kHeadingStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Option 2: SMS
                      GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = 1);
                          Navigator.pop(context, 'Via SMS');
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width / 2) - 40, // Half width
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: selectedIndex == 1
                                  ? kPrimaryColor
                                  : const Color(0xFFC0C0C0),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/via sms.png',
                                width: 64,
                                height: 64,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Via SMS',
                                style: kSubheadingStyle.copyWith(fontSize: 16)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
