import 'package:flutter/material.dart';
import 'package:beautician_app/utils/libs.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> _allFaqs = [
    {
      'question': 'What is BeautyShop?',
      'answer':
          'BeautyShop is a smart platform connecting beauty professionals (hairdressers, nail techs, makeup artists, etc.) with clients in real time through a map and booking system.',
    },
    {
      'question': 'How does BeautyShop work?',
      'answer':
          'Clients can search for beauty experts nearby, check who is online, view their services and prices, and book appointments directly.',
    },
    {
      'question': 'Is BeautyShop available internationally?',
      'answer':
          'Yes, BeautyShop works globally. Whether you\'re traveling or moving, you can find beauty professionals wherever you are.',
    },
    {
      'question': 'Is BeautyShop free for clients?',
      'answer':
          'Yes, the app is free to use for clients. You only pay for the services you book.',
    },
    {
      'question': 'How can I find beauty experts near me?',
      'answer':
          'Open the app, check the map view, and see who is online and nearby. Use filters to specify your needs (service, price, availability).',
    },
    {
      'question': 'Can I book a home visit?',
      'answer':
          'Yes, many professionals offer home services. Use the "Home Service" filter to find them.',
    },
    {
      'question': 'How do I know if a beauty professional is reliable?',
      'answer':
          'Check their profile for reviews, ratings, certifications, and verification badges.',
    },
    {
      'question': 'Can I book a beauty service at night?',
      'answer':
          'Yes, use the "Available Late" filter to find experts who work during evening or night hours.',
    },
    {
      'question': 'How do I pay for the service?',
      'answer':
          'You can pay directly to the beautician as per their preferred method (cash, card, or through the app if enabled).',
    },
    {
      'question': 'What if the beauty expert doesn\'t show up?',
      'answer':
          'If the expert doesn\'t arrive, report it through the app. Our support team will assist you.',
    },
    {
      'question': 'What is the check-in process when the expert arrives?',
      'answer':
          'When you meet the expert, one of you opens the app, goes to the appointment, and generates a QR code. The other scans it.\n\n'
          'The app checks your locations to ensure you are both at the same place.\n\n'
          'Once verified, the timer starts, tracking the duration of the service.\n\n'
          'If one or both leave the location, the service ends automatically.\n\n'
          'After completion, both can rate each other.',
    },
    {
      'question': 'Why is the location check important?',
      'answer':
          'It\'s crucial for security reasons. If an issue arises, the app records the meeting point, providing a safety measure.',
    },
    {
      'question': 'Can I cancel or reschedule my appointment?',
      'answer':
          'Yes, you can do so through the app, but cancellation policies vary by professional.',
    },
    {
      'question': 'Can I contact the professional before booking?',
      'answer':
          'Yes, use the chat feature to discuss availability or any special requests.',
    },
    {
      'question': 'What should I do if I\'m not happy with the service?',
      'answer':
          'Rate the professional honestly and leave feedback. You can also file a complaint if the issue is serious.',
    },
    {
      'question':
          'What happens if I forget to complete the service in the app?',
      'answer':
          'If neither party clicks "Complete," the service will automatically end when one or both leave the location.',
    },
    {
      'question': 'Can I book multiple services at once?',
      'answer':
          'Yes, if the expert offers multiple services, you can book them together.',
    },
    {
      'question': 'How do I sign up as a beauty professional?',
      'answer':
          'Download the app, register as a professional, and complete your profile with services, pricing, and availability.',
    },
    {
      'question': 'How much does it cost to list my services?',
      'answer':
          'Subscription plans are:\n\n'
          'Weekly: \$10\n'
          'Monthly: \$20\n'
          'Yearly: \$99',
    },
    {
      'question': 'Can I change my subscription plan later?',
      'answer':
          'Yes, you can upgrade or downgrade your plan through your profile settings.',
    },
    {
      'question': 'How do I appear on the map?',
      'answer':
          'Enable your location and set your status to "Online" in the app.',
    },
    {
      'question': 'How does the check-in process work for professionals?',
      'answer':
          'When meeting the client, one of you opens the app and goes to the appointment.\n\n'
          'Generate the QR code and let the other scan it.\n\n'
          'The app verifies your locations to make sure you are at the same spot.\n\n'
          'The service timer starts automatically.\n\n'
          'If one or both leave the location, the service ends automatically.\n\n'
          'After completion, both can rate the experience.',
    },
    {
      'question': 'Why is the location verification necessary?',
      'answer':
          'This check ensures both parties are present and provides a security measure. If anything goes wrong, we know where you were.',
    },
    {
      'question': 'Can I set my own working hours?',
      'answer':
          'Yes, you can customize your availability or simply toggle your status between "Online" and "Offline."',
    },
    {
      'question': 'What if the client cancels at the last minute?',
      'answer':
          'You can set your own cancellation policy, including fees for late cancellations.',
    },
    {
      'question': 'Can I block problematic clients?',
      'answer':
          'Yes, you can block users who violate terms or behave inappropriately.',
    },
    {
      'question': 'Can I rate my clients?',
      'answer':
          'Yes, you can leave a review and rate the client after the service.',
    },
    {
      'question': 'What should I do if I feel unsafe during a service?',
      'answer':
          'End the appointment via the app and leave the location. The app will automatically complete the session and log the details. Report the issue immediately.',
    },
    {
      'question': 'Do I have to pay a commission on each booking?',
      'answer':
          'No, you only pay a flat subscription fee. No commission is taken from your earnings.',
    },
    {
      'question': 'Can I update my profile photos and service list?',
      'answer':
          'Yes, you can update your gallery and service list anytime to reflect your latest work.',
    },
    {
      'question': 'How does BeautyShop ensure safety during appointments?',
      'answer':
          'The QR code check-in process verifies both parties are at the same location, and the timer tracks the session. If a problem arises, the app logs the location and time.',
    },
    {
      'question': 'What if the QR code doesn\'t work?',
      'answer':
          'Ensure both devices have location services enabled and are connected to the internet. If the issue persists, contact support.',
    },
    {
      'question': 'Can I report a security incident?',
      'answer':
          'Yes, you can file a report directly from the app after the service or contact customer support for urgent issues.',
    },
    {
      'question': 'What happens if one party leaves before ending the service?',
      'answer':
          'The app will automatically complete the service once either party leaves the designated location.',
    },
    {
      'question': 'Can I see a record of completed services?',
      'answer':
          'Yes, both clients and professionals can view their service history in the app.',
    },
    {
      'question': 'Is my personal data safe on BeautyShop?',
      'answer':
          'Yes, we use encryption and secure servers to protect your data. Your exact location is never shared publicly.',
    },
  ];

  List<Map<String, String>> _filteredFaqs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _filteredFaqs = _allFaqs;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchFaqs(String query) {
    setState(() {
      _filteredFaqs =
          _allFaqs
              .where(
                (faq) =>
                    faq['question']!.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    faq['answer']!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                ),
              ],
            ),
            title: Text(
              'FAQs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 15),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchFaqs,
              decoration: InputDecoration(
                prefixIcon: Image.asset('assets/search_Icon.png', scale: 4),
                hintText: 'Search FAQs...',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                filled: true,
                fillColor: const Color(0xffFFFFFF),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: Color(0xFFC0C0C0),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: Color(0xFFC0C0C0),
                    width: 1.5,
                  ),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 30),
            Expanded(
              child:
                  _filteredFaqs.isEmpty
                      ? Center(
                        child: Text(
                          'No FAQs found matching your search',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredFaqs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: CustomExpansionTile(
                              title: _filteredFaqs[index]['question']!,
                              content: _filteredFaqs[index]['answer']!,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
