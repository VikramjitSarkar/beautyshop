import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
class NearestSalonScreen extends StatelessWidget {
  const NearestSalonScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ///custom app bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: SvgPicture.asset('assets/back icon.svg')),
                          SizedBox(width: 12),
                          Text(
                            'Nearest Salon',
                            style: kHeadingStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(()=> NearestSalonSearchScreen());
                            },
                            child: Container(
                              height: 44,
                              width: 44,
                              padding: EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                  border: Border.all(color: Color(0xffC0C0C0)),
                                  shape: BoxShape.circle
                              ),
                
                              child: SvgPicture.asset('assets/search-Outline.svg'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    /// Horizontal List of Salon Cards
                    SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: salonImagesHor.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Salon Image
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.5,

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 260,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          image: DecorationImage(
                                            image: AssetImage(salonImagesHor[index]),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      /// Salon Name + Rating
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            salonName[index],
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          Row(
                                            children: [
                                              for (int i = 0; i < 4; i++)
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                                  child: Image.asset('assets/star.png', height: 16),
                                                ),
                                              Image.asset('assets/star2.png', height: 16),
                                              SizedBox(width: 5),
                                              Text('4.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      /// Salon Address
                                      Text(
                                        '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      SizedBox(height: 5),
                                      /// Distance & Time
                                      Container(
                                        height: 30,
                                        width: 140,
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Color(0xffC0C0C0)),
                                        ),
                                        child: Row(
                                          children: [
                                            Image(image: AssetImage('assets/timer.png'),height: 14,),
                                            SizedBox(width: 5),
                                            Text(
                                              '8.5 min (4.5 km)',
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    ///map
                    SizedBox(height: 20),
                    Container(
                      height: 700,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage('assets/map.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              ///custom app bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                        child: SvgPicture.asset('assets/back icon.svg')),
                    SizedBox(width: 12),
                    Text(
                      'Nearest Salon',
                      style: kHeadingStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.to(()=> NearestSalonSearchScreen());
                      },
                      child: Container(
                        height: 44,
                        width: 44,
                        padding: EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          // color: Colors.white,
                            border: Border.all(color: Color(0xffC0C0C0)),
                            shape: BoxShape.circle
                        ),

                        child: SvgPicture.asset('assets/search-Outline.svg'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              /// Horizontal List of Salon Cards
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: salonImagesHor.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Salon Image
                          Container(
                            width: MediaQuery.of(context).size.width * 0.86,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: AssetImage(salonImagesHor[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                /// Salon Name + Rating
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      salonName[index],
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        for (int i = 0; i < 4; i++)
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2),
                                            child: Image.asset('assets/star.png', height: 16),
                                          ),
                                        Image.asset('assets/star2.png', height: 16),
                                        SizedBox(width: 5),
                                        Text('4.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                /// Salon Address
                                Text(
                                  '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                /// Distance & Time
                                Container(
                                  height: 30,
                                  width: 140,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Color(0xffC0C0C0)),
                                  ),
                                  child: Row(
                                    children: [
                                      Image(image: AssetImage('assets/timer.png'),height: 14,),
                                      SizedBox(width: 5),
                                      Text(
                                        '8.5 min (4.5 km)',
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ///map
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('assets/map.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}