import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautician_app/utils/colors.dart'; // use your own color theme
import 'package:beautician_app/utils/text_styles.dart'; // optional: or use TextStyle directly

class AboutUsScreens extends StatelessWidget {
  const AboutUsScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "About Us",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to TheBeautyShop",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "At TheBeautyShop, we're redefining how people experience beauty services—by making them more accessible, flexible, and secure.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 12),
            Text(
              "Our platform bridges the gap between clients and beauty professionals in real time, offering a smart, map-based system where you can instantly discover, connect with, and book top-rated experts around you.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            Text(
              "For Clients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Whether you're in need of a last-minute blowout, a manicure at home, or a late-night makeup session before an event, TheBeautyShop has you covered. With a few taps, clients can browse verified professionals nearby, check their services and pricing, see who’s online, and book appointments directly. You can even filter by availability, home service options, ratings, and more.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            Text(
              "For Professionals",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We designed TheBeautyShop to be just as powerful for beauty professionals as it is for clients. Professionals can easily showcase their skills, upload service menus and photos, manage bookings, and control their working hours. With a simple flat-rate subscription and no commission fees, professionals keep more of what they earn while growing their presence on a trusted, global platform.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            Text(
              "Safety & Support",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Safety is central to our mission. Our check-in system uses QR codes and location verification to ensure that both parties are present at the agreed location, offering peace of mind during every appointment. And in case of any issues, our dedicated support team is just a tap away.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            Text(
              "Why TheBeautyShop?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Whether you're a client looking for convenience and quality, or a professional seeking growth and visibility, TheBeautyShop is your go-to beauty ecosystem.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            Text(
              "On-demand. On your terms. Always beautiful.",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
