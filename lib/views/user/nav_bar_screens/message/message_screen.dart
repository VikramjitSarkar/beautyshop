import 'package:flutter/material.dart';
import 'package:beautician_app/utils/libs.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Messages',
          style: kHeadingStyle.copyWith(
            fontSize: 18, // Slightly larger for better visibility
            fontWeight: FontWeight.w700,
            color: Colors.black, // Ensure good contrast
          ),
        ),
        centerTitle: true, // Center the title for better balance
        iconTheme: IconThemeData(color: Colors.black), // Make back button black
      ),
      body: Column(
        children: [
          // Search bar at the top

          // Divider for visual separation
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          // Expanded area for messages
          Expanded(
            child: UserMessageTabScreen(), // Your existing message list
          ),
        ],
      ),

      // Floating action button for new messages
    );
  }
}
