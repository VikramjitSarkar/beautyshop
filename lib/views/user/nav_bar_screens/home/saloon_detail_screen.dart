import 'package:beautician_app/utils/libs.dart';

class SaloonDetailScreen extends StatefulWidget {
  SaloonDetailScreen({super.key});

  @override
  State<SaloonDetailScreen> createState() => _SaloonDetailScreenState();
}

class _SaloonDetailScreenState extends State<SaloonDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> images = [
    'assets/package1.png',
    'assets/package2.png',
    'assets/package1.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🖼️ Image Slider with PageView
                Container(
                  height: 300,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
            
                      /// 🔙 Back Button
                      Positioned(
                        top: 20,
                        left: 10,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Image.asset('assets/arrow.png'),
                        ),
                      ),
            
                      /// 📍 Page Indicator
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CustomPageIndicator(
                            currentIndex: _currentPage,
                            itemCount: images.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📝 Bridal Beauty Makeup Section
                      Text(
                        "Bridal Beauty Makeup",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Completed package offer till ",
                            style: kHeadingStyle.copyWith(
                              fontSize: 14,
                              color: kGreyColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Jun 06, 2024",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
                        style: TextStyle(color: kGreyColor, fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 20),
                      /// ✔️ Services List
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage('assets/services.png')),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Services",
                                style: kHeadingStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "Lorem ipsum dolor sit amet consectetur",
                                style: kSubheadingStyle.copyWith(fontSize: 14, color: kGreyColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildServiceItem("Hairstyling"),
                              _buildServiceItem("Nail"),
                              _buildServiceItem("Hair color"),
                              _buildServiceItem("Body Glowing"),
                              _buildServiceItem("Facial"),
                            ],
                          )),
                          Expanded(child: Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildServiceItem("Spa"),
                              _buildServiceItem("Eyebrows"),
                              _buildServiceItem("Make up"),
                              _buildServiceItem("Retouch"),
                              _buildServiceItem("Corner Lashes"),
                            ],
                          ))
                        ],
                      ),
                      SizedBox(height: 30),
                      /// 📌 Book Now Button
                      Center(
                        child: MaterialButton(
                          height: 50,
                          elevation: 0,
                          minWidth: double.maxFinite,
                          color: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Book now",
                            style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Service Item Widget
  Widget _buildServiceItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 15,
          width: 15,
          padding: EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            border: Border.all(color: kPrimaryColor),
            shape: BoxShape.circle
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryColor,
                  shape: BoxShape.circle
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}