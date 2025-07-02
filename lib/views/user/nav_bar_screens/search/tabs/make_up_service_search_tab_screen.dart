// import 'package:responsive_builder/responsive_builder.dart';
// import 'package:beautician_app/utils/libs.dart';
//
// class MakeUpServiceSearchTabScreen extends StatelessWidget {
//   const MakeUpServiceSearchTabScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, sizingInformation) {
//         if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: padding),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Top specialist',
//                         style: kHeadingStyle.copyWith(fontSize: 16),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           showModalBottomSheet(
//                             context: context,
//                             isScrollControlled: true, // Make it fullscreen
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(20)),
//                             ),
//                             builder: (context) {
//                               String selectedService = "Haircuts";
//                               double distance = 2.5;
//                               int selectedRating = 5;
//                               String selectedGender = "All";
//
//                               // New filter variables
//                               bool onlineNow = false;
//                               bool nearby = false;
//                               bool homeVisitAvailable = false;
//                               bool hasSalonLocation = false;
//                               RangeValues priceRange = RangeValues(0, 100);
//                               TimeOfDay availableFrom = TimeOfDay.now();
//                               TimeOfDay availableTo = TimeOfDay.now();
//                               List<String> languagesSpoken = [];
//                               double travelRadius = 5.0;
//                               int experienceLevel = 0;
//                               bool verifiedProfileOnly = false;
//
//                               return StatefulBuilder(
//                                 // To update state within the bottom sheet
//                                 builder: (context, setState) {
//                                   void _updateGender(String gender) {
//                                     setState(() {
//                                       selectedGender = gender;
//                                     });
//                                   }
//
//                                   return Container(
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.vertical(
//                                           top: Radius.circular(20)),
//                                     ),
//                                     child: SingleChildScrollView(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           /// Close Button
//                                           Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text("Advanced Filters",
//                                                   style: kHeadingStyle.copyWith(
//                                                       fontWeight:
//                                                       FontWeight.w700,
//                                                       fontSize: 18)),
//                                               IconButton(
//                                                 icon: Icon(Icons.close),
//                                                 onPressed: () =>
//                                                     Navigator.pop(context),
//                                               ),
//                                             ],
//                                           ),
//
//                                           /// Core Filters
//                                           Text("Core Filters",
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 18)),
//                                           SwitchListTile(
//                                             title: Text("Online Now"),
//                                             value: onlineNow,
//                                             activeColor: Colors.white,
//                                             activeTrackColor: kPrimaryColor,
//                                             trackOutlineColor:
//                                             WidgetStatePropertyAll(
//                                                 Colors.transparent),
//                                             inactiveTrackColor: kGreyColor2,
//                                             inactiveThumbColor: Colors.white,
//                                             onChanged: (value) => setState(
//                                                     () => onlineNow = value),
//                                           ),
//                                           SwitchListTile(
//                                             title: Text("Nearby"),
//                                             value: nearby,
//                                             activeColor: Colors.white,
//                                             activeTrackColor: kPrimaryColor,
//                                             trackOutlineColor:
//                                             WidgetStatePropertyAll(
//                                                 Colors.transparent),
//                                             inactiveTrackColor: kGreyColor2,
//                                             inactiveThumbColor: Colors.white,
//                                             onChanged: (value) =>
//                                                 setState(() => nearby = value),
//                                           ),
//                                           SwitchListTile(
//                                             title: Text("Home Visit Available"),
//                                             value: homeVisitAvailable,
//                                             activeColor: Colors.white,
//                                             activeTrackColor: kPrimaryColor,
//                                             trackOutlineColor:
//                                             WidgetStatePropertyAll(
//                                                 Colors.transparent),
//                                             inactiveTrackColor: kGreyColor2,
//                                             inactiveThumbColor: Colors.white,
//                                             onChanged: (value) => setState(() =>
//                                             homeVisitAvailable = value),
//                                           ),
//                                           SwitchListTile(
//                                             title: Text(
//                                                 "Has Salon/Location to Visit"),
//                                             value: hasSalonLocation,
//                                             activeColor: Colors.white,
//                                             activeTrackColor: kPrimaryColor,
//                                             trackOutlineColor:
//                                             WidgetStatePropertyAll(
//                                                 Colors.transparent),
//                                             inactiveTrackColor: kGreyColor2,
//                                             inactiveThumbColor: Colors.white,
//                                             onChanged: (value) => setState(
//                                                     () => hasSalonLocation = value),
//                                           ),
//                                           RangeSlider(
//                                             values: priceRange,
//                                             min: 0,
//                                             max: 500,
//                                             divisions: 100,
//                                             activeColor: kPrimaryColor,
//                                             inactiveColor: kGretLiteColor,
//                                             overlayColor:
//                                             WidgetStatePropertyAll(
//                                                 kPrimaryColor),
//                                             labels: RangeLabels(
//                                                 '${priceRange.start}',
//                                                 '${priceRange.end}'),
//                                             onChanged: (values) => setState(
//                                                     () => priceRange = values),
//                                           ),
//
//                                           /// Advanced Filters
//                                           Text("Advanced Filters",
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.w700,
//                                                   fontSize: 18)),
//                                           SliderTheme(
//                                             data: SliderTheme.of(context)
//                                                 .copyWith(
//                                               thumbColor: kPrimaryColor,
//                                               activeTrackColor: kPrimaryColor,
//                                               inactiveTrackColor:
//                                               kGretLiteColor,
//                                               valueIndicatorColor: Colors.black,
//                                               valueIndicatorTextStyle:
//                                               TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 14),
//                                               thumbShape: RoundSliderThumbShape(
//                                                   enabledThumbRadius: 12),
//                                               activeTickMarkColor:
//                                               Colors.transparent,
//                                               inactiveTickMarkColor:
//                                               Colors.transparent,
//                                             ),
//                                             child: Slider(
//                                               value: travelRadius,
//                                               min: 0,
//                                               max: 50,
//                                               divisions: 10,
//                                               label:
//                                               "${travelRadius.toStringAsFixed(1)} km",
//                                               onChanged: (value) => setState(
//                                                       () => travelRadius = value),
//                                             ),
//                                           ),
//                                           SwitchListTile(
//                                             title:
//                                             Text("Verified Profile Only"),
//                                             value: verifiedProfileOnly,
//                                             activeColor: Colors.white,
//                                             activeTrackColor: kPrimaryColor,
//                                             trackOutlineColor:
//                                             WidgetStatePropertyAll(
//                                                 Colors.transparent),
//                                             inactiveTrackColor: kGreyColor2,
//                                             inactiveThumbColor: Colors.white,
//                                             onChanged: (value) => setState(() =>
//                                             verifiedProfileOnly = value),
//                                           ),
//
//                                           /// Done Button
//                                           ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: kPrimaryColor,
//                                               minimumSize:
//                                               Size(double.infinity, 50),
//                                             ),
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: Text("Done",
//                                                 style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 18)),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                         child: Container(
//                           height: 44,
//                           width: 44,
//                           decoration: BoxDecoration(
//                             color: Color(0xffF8F8F8),
//                             shape: BoxShape.circle,
//                             image: DecorationImage(
//                                 image: AssetImage('assets/filter1.png'),
//                                 scale: 4),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     height: 250,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: specialistImages2.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TopSpecialistCardTwo(
//                             imagePath: specialistImages2[index],
//                             onBook: () {},
//                             specialistName: specialistNames2[index],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Divider(
//                     color: kGreyColor2,
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: 5,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, // ہر صف میں دو آئٹمز ہوں گے
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         mainAxisExtent: 400
//                     ),
//                     itemBuilder: (context, index) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   image: DecorationImage(image: AssetImage('assets/saloon.png'),fit: BoxFit.fill)
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset('assets/star.png'),
//                                     SizedBox(width: 3),
//                                     Image.asset('assets/star.png'),
//                                     SizedBox(width: 3),
//                                     Image.asset('assets/star.png'),
//                                     SizedBox(width: 3),
//                                     Image.asset('assets/star.png'),
//                                     SizedBox(width: 3),
//                                     Image.asset('assets/star2.png'),
//                                     SizedBox(width: 3),
//                                     Text(
//                                       '4.0',
//                                       style: kHeadingStyle.copyWith(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   'Velvet Vanity',
//                                   style: kHeadingStyle.copyWith(fontSize: 16),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                 ),
//                                 Text(
//                                   '1901 Thornridge Cir. Shiloh, Hawaii 81063',
//                                   style: kSubheadingStyle,
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                 ),
//                                 SizedBox(height: 5),
//                                 Row(
//                                   children: [
//                                     Image(
//                                         image: AssetImage('assets/timer.png'),
//                                         height: 14),
//                                     SizedBox(width: 5),
//                                     Expanded(
//                                       child: Text(
//                                         '8.5 min (4.5 km)',
//                                         style: kSubheadingStyle,
//                                         overflow: TextOverflow.ellipsis,
//                                         maxLines: 1,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 5),
//                                 Align(
//                                   alignment: Alignment.bottomRight,
//                                   child: Container(
//                                     height: 27,
//                                     width: 58,
//                                     decoration: BoxDecoration(
//                                       color: Colors.black,
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     child: MaterialButton(
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                           BorderRadius.circular(30)),
//                                       onPressed: () {},
//                                       child: FittedBox(
//                                         child: Text(
//                                           'Book',
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w400,
//                                               color: Colors.white),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   )
//                 ],
//               ),
//             ),
//           );
//         }
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: padding),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Top specialist',
//                       style: kHeadingStyle.copyWith(fontSize: 16),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true, // Make it fullscreen
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.vertical(top: Radius.circular(20)),
//                           ),
//                           builder: (context) {
//                             String selectedService = "Haircuts";
//                             double distance = 2.5;
//                             int selectedRating = 5;
//                             String selectedGender = "All";
//
//                             // New filter variables
//                             bool onlineNow = false;
//                             bool nearby = false;
//                             bool homeVisitAvailable = false;
//                             bool hasSalonLocation = false;
//                             RangeValues priceRange = RangeValues(0, 100);
//                             TimeOfDay availableFrom = TimeOfDay.now();
//                             TimeOfDay availableTo = TimeOfDay.now();
//                             List<String> languagesSpoken = [];
//                             double travelRadius = 5.0;
//                             int experienceLevel = 0;
//                             bool verifiedProfileOnly = false;
//
//                             return StatefulBuilder(
//                               // To update state within the bottom sheet
//                               builder: (context, setState) {
//                                 void _updateGender(String gender) {
//                                   setState(() {
//                                     selectedGender = gender;
//                                   });
//                                 }
//
//                                 return Container(
//                                   padding: EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.vertical(
//                                         top: Radius.circular(20)),
//                                   ),
//                                   child: SingleChildScrollView(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         /// Close Button
//                                         Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text("Advanced Filters",
//                                                 style: kHeadingStyle.copyWith(
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize: 18)),
//                                             IconButton(
//                                               icon: Icon(Icons.close),
//                                               onPressed: () =>
//                                                   Navigator.pop(context),
//                                             ),
//                                           ],
//                                         ),
//
//                                         /// Core Filters
//                                         Text("Core Filters",
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 18)),
//                                         SwitchListTile(
//                                           title: Text("Online Now"),
//                                           value: onlineNow,
//                                           activeColor: Colors.white,
//                                           activeTrackColor: kPrimaryColor,
//                                           trackOutlineColor:
//                                           WidgetStatePropertyAll(
//                                               Colors.transparent),
//                                           inactiveTrackColor: kGreyColor2,
//                                           inactiveThumbColor: Colors.white,
//                                           onChanged: (value) =>
//                                               setState(() => onlineNow = value),
//                                         ),
//                                         SwitchListTile(
//                                           title: Text("Nearby"),
//                                           value: nearby,
//                                           activeColor: Colors.white,
//                                           activeTrackColor: kPrimaryColor,
//                                           trackOutlineColor:
//                                           WidgetStatePropertyAll(
//                                               Colors.transparent),
//                                           inactiveTrackColor: kGreyColor2,
//                                           inactiveThumbColor: Colors.white,
//                                           onChanged: (value) =>
//                                               setState(() => nearby = value),
//                                         ),
//                                         SwitchListTile(
//                                           title: Text("Home Visit Available"),
//                                           value: homeVisitAvailable,
//                                           activeColor: Colors.white,
//                                           activeTrackColor: kPrimaryColor,
//                                           trackOutlineColor:
//                                           WidgetStatePropertyAll(
//                                               Colors.transparent),
//                                           inactiveTrackColor: kGreyColor2,
//                                           inactiveThumbColor: Colors.white,
//                                           onChanged: (value) => setState(
//                                                   () => homeVisitAvailable = value),
//                                         ),
//                                         SwitchListTile(
//                                           title: Text(
//                                               "Has Salon/Location to Visit"),
//                                           value: hasSalonLocation,
//                                           activeColor: Colors.white,
//                                           activeTrackColor: kPrimaryColor,
//                                           trackOutlineColor:
//                                           WidgetStatePropertyAll(
//                                               Colors.transparent),
//                                           inactiveTrackColor: kGreyColor2,
//                                           inactiveThumbColor: Colors.white,
//                                           onChanged: (value) => setState(
//                                                   () => hasSalonLocation = value),
//                                         ),
//                                         RangeSlider(
//                                           values: priceRange,
//                                           min: 0,
//                                           max: 500,
//                                           divisions: 100,
//                                           activeColor: kPrimaryColor,
//                                           inactiveColor: kGretLiteColor,
//                                           overlayColor: WidgetStatePropertyAll(
//                                               kPrimaryColor),
//                                           labels: RangeLabels(
//                                               '${priceRange.start}',
//                                               '${priceRange.end}'),
//                                           onChanged: (values) => setState(
//                                                   () => priceRange = values),
//                                         ),
//
//                                         /// Advanced Filters
//                                         Text("Advanced Filters",
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.w700,
//                                                 fontSize: 18)),
//                                         SliderTheme(
//                                           data:
//                                           SliderTheme.of(context).copyWith(
//                                             thumbColor: kPrimaryColor,
//                                             activeTrackColor: kPrimaryColor,
//                                             inactiveTrackColor: kGretLiteColor,
//                                             valueIndicatorColor: Colors.black,
//                                             valueIndicatorTextStyle: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 14),
//                                             thumbShape: RoundSliderThumbShape(
//                                                 enabledThumbRadius: 12),
//                                             activeTickMarkColor:
//                                             Colors.transparent,
//                                             inactiveTickMarkColor:
//                                             Colors.transparent,
//                                           ),
//                                           child: Slider(
//                                             value: travelRadius,
//                                             min: 0,
//                                             max: 50,
//                                             divisions: 10,
//                                             label:
//                                             "${travelRadius.toStringAsFixed(1)} km",
//                                             onChanged: (value) => setState(
//                                                     () => travelRadius = value),
//                                           ),
//                                         ),
//                                         SwitchListTile(
//                                           title: Text("Verified Profile Only"),
//                                           value: verifiedProfileOnly,
//                                           activeColor: Colors.white,
//                                           activeTrackColor: kPrimaryColor,
//                                           trackOutlineColor:
//                                           WidgetStatePropertyAll(
//                                               Colors.transparent),
//                                           inactiveTrackColor: kGreyColor2,
//                                           inactiveThumbColor: Colors.white,
//                                           onChanged: (value) => setState(() =>
//                                           verifiedProfileOnly = value),
//                                         ),
//
//                                         /// Done Button
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: kPrimaryColor,
//                                             minimumSize:
//                                             Size(double.infinity, 50),
//                                           ),
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                           },
//                                           child: Text("Done",
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 18)),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                       child: Container(
//                         height: 44,
//                         width: 44,
//                         decoration: BoxDecoration(
//                           color: Color(0xffF8F8F8),
//                           shape: BoxShape.circle,
//                           image: DecorationImage(
//                               image: AssetImage('assets/filter1.png'),
//                               scale: 4),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 SizedBox(
//                   height: 250,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: specialistImages2.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TopSpecialistCardTwo(
//                           imagePath: specialistImages2[index],
//                           onBook: () {},
//                           specialistName: specialistNames2[index],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Divider(
//                   color: kGreyColor2,
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: 5,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       child: SaloonCardTwo(),
//                     );
//                   },
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
