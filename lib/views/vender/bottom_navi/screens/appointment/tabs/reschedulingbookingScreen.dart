import 'package:beautician_app/controllers/vendors/booking/bookingPendingController.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

class ReschedulingBookingScreen extends StatefulWidget {
  final String bookingId;
  ReschedulingBookingScreen({super.key, required this.bookingId});

  @override
  State<ReschedulingBookingScreen> createState() =>
      _ReschedulingBookingScreenState();
}

class _ReschedulingBookingScreenState extends State<ReschedulingBookingScreen> {
  final PendingBookingController controller = Get.put(
    PendingBookingController(),
  );

  int selectedDate = 21;
  String selectedTime = "01:00 pm";
  bool isDayNight = false;
  List<int> dates = [18, 19, 20, 21, 22, 23, 24];
  int activeStep = 0;
  DateTime currentMonth = DateTime.now();

  List<String> times = [
    "01:00 pm",
    "02:00 pm",
    "03:00 pm",
    "04:00 pm",
    "05:00 pm",
    "06:00 pm",
    "07:00 pm",
    "08:00 pm",
    "09:00 pm",
  ];

  List<Map<String, String>> specialists = [
    {
      "name": "Jane Cooper",
      "role": "Hair specialist",
      "image": "assets/specialist1.png",
    },
    {
      "name": "Jenny Wilson",
      "role": "Face specialist",
      "image": "assets/specialist2.png",
    },
    {
      "name": "Kristin Watson",
      "role": "Hair specialist",
      "image": "assets/specialist3.png",
    },
    {
      "name": "Jacob Jones",
      "role": "Skin specialist",
      "image": "assets/specialist4.png",
    },
  ];

  void changeMonth(bool isNext) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + (isNext ? 1 : -1),
      );
    });
  }

  TimeOfDay _parseTimeTo24Hour(String timeString) {
    try {
      // Clean the string by removing all non-standard whitespace and trimming
      final cleaned =
          timeString
              .replaceAll(
                RegExp(r'[^\x20-\x7E]'),
                ' ',
              ) // Replace non-ASCII spaces
              .replaceAll(RegExp(r'\s+'), ' ') // Collapse multiple spaces
              .trim();

      // Try parsing with different formats
      final formats = [
        DateFormat.jm(), // 1:00 PM
        DateFormat.Hm(), // 13:00 (24-hour)
        DateFormat('h:mm a'), // explicit format
        DateFormat('HH:mm'), // 24-hour format
      ];

      for (final format in formats) {
        try {
          final dateTime = format.parse(cleaned);
          return TimeOfDay.fromDateTime(dateTime);
        } catch (e) {
          // Try next format
          continue;
        }
      }

      // Fallback for simple time strings like "13:00"
      final parts = cleaned.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }

      throw FormatException('Unable to parse time: $timeString');
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return const TimeOfDay(hour: 0, minute: 0); // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title:
                  activeStep == 0
                      ? Text(
                        "Book Appointment",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : Text(
                        "Booking successfully",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              leading: IconButton(
                icon: SvgPicture.asset('assets/back icon.svg'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kGretLiteColor.withOpacity(0),
                            kGretLiteColor,
                            kGretLiteColor,
                            kGretLiteColor.withOpacity(0),
                          ],
                        ),
                      ),
                      child: CustomStepper(
                        listStep: ["Book Appointment", "Booking successfully"],
                        step: activeStep,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (activeStep == 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select date",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 15),
                          // Month & Year Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: kGreyColor,
                                ),
                                onPressed: () => changeMonth(false),
                              ),
                              Text(
                                DateFormat('MMMM, yyyy').format(currentMonth),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: kGreyColor,
                                ),
                                onPressed: () => changeMonth(true),
                              ),
                            ],
                          ),

                          // Date Selection
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  dates.map((date) {
                                    bool isSelected = date == selectedDate;
                                    DateTime dateTime = DateTime(
                                      currentMonth.year,
                                      currentMonth.month,
                                      date,
                                    );
                                    String dayName = DateFormat('E').format(
                                      dateTime,
                                    ); // Get short day name (Sun, Mon, Tue...)

                                    return GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => selectedDate = date,
                                          ),
                                      child: Column(
                                        children: [
                                          Text(
                                            dayName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: kGreyColor,
                                            ),
                                          ),
                                          // Show weekday
                                          const SizedBox(height: 5),
                                          Container(
                                            width: 50,
                                            height: 50,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? Colors.green
                                                      : Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              date.toString(),
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Divider(color: kGreyColor, thickness: 0.5),
                          const SizedBox(height: 25),

                          // Time Selection
                          Row(
                            children: [
                              const Text(
                                "Select time",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              CustomCheckBox(
                                title: 'AM',
                                isSelected: isDayNight,
                                onTap: () => setState(() => isDayNight = true),
                              ),
                              CustomCheckBox(
                                title: 'PM',
                                isSelected: !isDayNight,
                                onTap: () => setState(() => isDayNight = false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                times.map((time) {
                                  bool isSelected = time == selectedTime;
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => selectedTime = time),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.black
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : kGreyColor,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 20),
                          // const Text("Top specialists",
                          //     style: TextStyle(
                          //         fontSize: 16, fontWeight: FontWeight.w700)),

                          // // Specialist Grid
                          // GridView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   padding: const EdgeInsets.only(top: 10),
                          //   gridDelegate:
                          //       SliverGridDelegateWithFixedCrossAxisCount(
                          //           crossAxisCount: 3,
                          //           mainAxisSpacing: 10,
                          //           crossAxisSpacing: 10,
                          //           mainAxisExtent: 400),
                          //   itemCount: specialists.length,
                          //   itemBuilder: (context, index) {
                          //     return Container(
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(20),
                          //         border: Border.all(color: kGreyColor),
                          //       ),
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Container(
                          //             height: 300, // Fixed height
                          //             margin: EdgeInsets.symmetric(
                          //                 horizontal: 5, vertical: 5),
                          //             decoration: BoxDecoration(
                          //               borderRadius: BorderRadius.circular(20),
                          //               image: DecorationImage(
                          //                 image: AssetImage(
                          //                     specialists[index]['image']!),
                          //                 fit: BoxFit.fill,
                          //               ),
                          //             ),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.symmetric(
                          //                 horizontal: 10),
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 Row(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.spaceBetween,
                          //                   children: [
                          //                     Text(
                          //                       specialists[index]['name']!,
                          //                       style: const TextStyle(
                          //                         fontSize: 14,
                          //                         fontWeight: FontWeight.w700,
                          //                       ),
                          //                     ),
                          //                     Row(
                          //                       children: [
                          //                         Image(
                          //                             image: AssetImage(
                          //                                 'assets/star.png')),
                          //                         Text(
                          //                           '4.0',
                          //                           style: TextStyle(
                          //                             color: kGreyColor,
                          //                             fontWeight:
                          //                                 FontWeight.w400,
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ],
                          //                 ),
                          //                 Text(
                          //                   specialists[index]['role']!,
                          //                   style: TextStyle(
                          //                     fontSize: 14,
                          //                     color: kGreyColor,
                          //                     fontWeight: FontWeight.w400,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                    if (activeStep == 1)
                      Column(
                        children: [
                          Image(
                            image: AssetImage('assets/sucessfully.png'),
                            height: 64,
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              "Your appointment\nbooking is successfully.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: Text(
                              "You can view the appointment booking info in the “Appointment” section.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 93),
                          Container(
                            height: 210,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kGreyColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'ID: ',
                                      style: TextStyle(
                                        color: kGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '#654321',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Lotus Salon',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kGreyColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Divider(color: kGreyColor2),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Image(
                                      image: AssetImage('assets/cutter.png'),
                                      height: 54,
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Hair Cut',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                '\$5.00',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Image(
                                                image: AssetImage(
                                                  'assets/timer.png',
                                                ),
                                                height: 14,
                                              ),
                                              SizedBox(width: 3),
                                              Text(
                                                '02:30 pm - 05 Jun, 2024',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 50,
                onPressed: () async {
                  if (activeStep == 0) {
                    // Validate date and time selection
                    final selectedDateTime = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      selectedDate,
                      _parseTimeTo24Hour(selectedTime).hour,
                      _parseTimeTo24Hour(selectedTime).minute,
                    );
                    
                    // Prevent past date selection
                    if (selectedDateTime.isBefore(DateTime.now())) {
                      Get.snackbar(
                        'Invalid Date',
                        'Cannot reschedule to a past date',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // Move to confirmation step
                    setState(() {
                      activeStep = 1;
                    });
                  }
                },
                color: kPrimaryColor,
                child:
                    activeStep == 0
                        ? Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                        : Text(
                          "Continue booking",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title:
                activeStep == 0
                    ? Text(
                      "Book Appointment",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : Text(
                      "Booking successfully",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            leading: IconButton(
              icon: SvgPicture.asset('assets/back icon.svg'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kGretLiteColor.withOpacity(0),
                          kGretLiteColor,
                          kGretLiteColor,
                          kGretLiteColor.withOpacity(0),
                        ],
                      ),
                    ),
                    child: CustomStepper(
                      listStep: ["Book Appointment", "Booking successfully"],
                      step: activeStep,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (activeStep == 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select date",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 15),
                        // Month & Year Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left, color: kGreyColor),
                              onPressed: () => changeMonth(false),
                            ),
                            Text(
                              DateFormat('MMMM, yyyy').format(currentMonth),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: kGreyColor,
                              ),
                              onPressed: () => changeMonth(true),
                            ),
                          ],
                        ),

                        // Date Selection
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                dates.map((date) {
                                  bool isSelected = date == selectedDate;
                                  DateTime dateTime = DateTime(
                                    currentMonth.year,
                                    currentMonth.month,
                                    date,
                                  );
                                  String dayName = DateFormat('E').format(
                                    dateTime,
                                  ); // Get short day name (Sun, Mon, Tue...)

                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => selectedDate = date),
                                    child: Column(
                                      children: [
                                        Text(
                                          dayName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kGreyColor,
                                          ),
                                        ),
                                        // Show weekday
                                        const SizedBox(height: 5),
                                        Container(
                                          width: 50,
                                          height: 50,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Colors.green
                                                    : Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            date.toString(),
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Divider(color: kGreyColor, thickness: 0.5),
                        const SizedBox(height: 25),

                        // Time Selection
                        Row(
                          children: [
                            const Text(
                              "Select time",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            CustomCheckBox(
                              title: 'AM',
                              isSelected: isDayNight,
                              onTap: () => setState(() => isDayNight = true),
                            ),
                            CustomCheckBox(
                              title: 'PM',
                              isSelected: !isDayNight,
                              onTap: () => setState(() => isDayNight = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              times.map((time) {
                                bool isSelected = time == selectedTime;
                                return GestureDetector(
                                  onTap:
                                      () => setState(() => selectedTime = time),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.black
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : kGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 20),
                        // const Text(
                        //   "Top specialists",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),

                        // // Specialist Grid
                        // GridView.builder(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   padding: const EdgeInsets.only(top: 10),
                        //   gridDelegate:
                        //       SliverGridDelegateWithFixedCrossAxisCount(
                        //         crossAxisCount: 2,
                        //         mainAxisSpacing: 10,
                        //         crossAxisSpacing: 10,
                        //         mainAxisExtent: 220,
                        //       ),
                        //   itemCount: specialists.length,
                        //   itemBuilder: (context, index) {
                        //     return Container(
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(20),
                        //         border: Border.all(color: kGreyColor),
                        //       ),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Container(
                        //             height: 150,
                        //             margin: EdgeInsets.symmetric(
                        //               horizontal: 5,
                        //               vertical: 5,
                        //             ),
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(20),
                        //               image: DecorationImage(
                        //                 image: AssetImage(
                        //                   specialists[index]['image']!,
                        //                 ),
                        //                 fit: BoxFit.fill,
                        //               ),
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //               horizontal: 10,
                        //             ),
                        //             child: Column(
                        //               spacing: 4,
                        //               crossAxisAlignment:
                        //                   CrossAxisAlignment.start,
                        //               children: [
                        //                 Row(
                        //                   mainAxisAlignment:
                        //                       MainAxisAlignment.spaceBetween,
                        //                   children: [
                        //                     Text(
                        //                       specialists[index]['name']!,
                        //                       style: const TextStyle(
                        //                         fontSize: 14,
                        //                         fontWeight: FontWeight.w700,
                        //                       ),
                        //                     ),
                        //                     Row(
                        //                       children: [
                        //                         Image(
                        //                           image: AssetImage(
                        //                             'assets/star.png',
                        //                           ),
                        //                         ),
                        //                         Text(
                        //                           '4.0',
                        //                           style: TextStyle(
                        //                             color: kGreyColor,
                        //                             fontWeight: FontWeight.w400,
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 Text(
                        //                   specialists[index]['role']!,
                        //                   style: TextStyle(
                        //                     fontSize: 14,
                        //                     color: kGreyColor,
                        //                     fontWeight: FontWeight.w400,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // ),
                        SizedBox(height: 60),
                      ],
                    ),
                  if (activeStep == 1)
                    Column(
                      children: [
                        Image(
                          image: AssetImage('assets/sucessfully.png'),
                          height: 64,
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Your appointment\nbooking is successfully.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            "You can view the appointment booking info in the “Appointment” section.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: kGreyColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 75),
                        Container(
                          height: 210,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kGreyColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ID: ',
                                    style: TextStyle(
                                      color: kGreyColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '#654321',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Lotus Salon',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kGreyColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(color: kGreyColor2),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Image(
                                    image: AssetImage('assets/cutter.png'),
                                    height: 54,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Hair Cut',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Image(
                                              image: AssetImage(
                                                'assets/timer.png',
                                              ),
                                              height: 14,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              '${DateFormat('d MMMM, yyyy').format(DateTime(currentMonth.year, currentMonth.month, selectedDate))} at $selectedTime',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: MaterialButton(
              elevation: 0,
              minWidth: double.maxFinite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              height: 50,
              onPressed: () async {
                if (activeStep == 0) {
                  // Just go to next step without rescheduling
                  setState(() {
                    activeStep = 1;
                  });
                } else {
                  // Ask for confirmation before rescheduling
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            'Confirm Rescheduling',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to reschedule this booking?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Yes, Reschedule',
                                style: TextStyle(color: kPrimaryColor1),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirmed == true) {
                    final selectedDateTime = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      selectedDate,
                      _parseTimeTo24Hour(selectedTime).hour,
                      _parseTimeTo24Hour(selectedTime).minute,
                    );

                    final success = await controller.rescheduleBooking(
                      bookingId: widget.bookingId,
                      newDate: selectedDateTime,
                    );

                    if (success) {
                      Get.snackbar(
                        "Success",
                        "Booking rescheduled successfully",
                        backgroundColor: Colors.green.shade100,
                        snackPosition: SnackPosition.BOTTOM,
                      );

                      Navigator.pop(context); // Go back to the previous screen
                    }
                  }
                }
              },
              color: kPrimaryColor,
              child:
                  activeStep == 0
                      ? Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                      : Text(
                        "Continue booking",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}
