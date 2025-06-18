import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<Map<String, dynamic>> onboardingData = [
    {
      "imagePath": "assets/salon1.png",
      "heading": "Discover Your Perfect Style with Our Expert Stylists",
      "subheading":
          "Transform your look with our curated salon services, designed to bring out your unique beauty.",
    },
    {
      "imagePath": "assets/salon2.png",
      "heading": "Elevate Your Beauty Routine with Premium Services",
      "subheading":
          "Experience top-notch salon services tailored to your needs, ensuring you leave feeling fabulous.",
    },
    {
      "imagePath": "assets/salon3.png",
      "heading": "Unleash Your Inner Glam with Luxury Treatments",
      "subheading":
          "Step into a world of luxury and let our expert stylists craft the perfect look just for you.",
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Top image section
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    // Images
                    PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  onboardingData[index]["imagePath"]),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                            ),
                          ),
                        );
                      },
                    ),

                    // Dots indicator
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(onboardingData.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom content section
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            onboardingData[_currentIndex]["heading"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            onboardingData[_currentIndex]["subheading"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: _currentIndex == onboardingData.length - 1
                            ? CustomButton(
                                isEnabled: true,
                                title: "Get Started",
                                onPressed: () {
                                  Get.offAll(() => UserVendorScreen());
                                },
                              )
                            : GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    _currentIndex + 1,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
