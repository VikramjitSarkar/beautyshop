import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

import '../../../../controllers/users/home/userBookingController.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String vendorId;
  final List<Map<String, dynamic>> services;
  BookAppointmentScreen({
    super.key,
    required this.services,
    required this.vendorId,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final bookingController = Get.put(UserBookingController());
  bool isAmSelected = false; // false for PM, true for AM
  int selectedDate = 21;
  String selectedTime = "01:00 pm";
  bool isDayNight = false;
  List<int> get dates {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    return List.generate(lastDay.day - firstDay.day + 1, (i) => i + 1);
  }

  int activeStep = 0;
  DateTime currentMonth = DateTime.now();

  List<String> get times {
    if (isAmSelected) {
      return ["08:00 am", "09:00 am", "10:00 am", "11:00 am", "12:00 pm"];
    } else {
      return [
        "01:00 pm",
        "02:00 pm",
        "03:00 pm",
        "04:00 pm",
        "05:00 pm",
        "06:00 pm",
        "07:00 pm",
        "08:00 pm",
        "09:00 pm",
        "10:00 pm",
        "11:00 pm",
      ];
    }
  }

  // List<Map<String, String>> specialists = [
  //   {
  //     "name": "Jane Cooper",
  //     "role": "Hair specialist",
  //     "image": "assets/specialist1.png",
  //   },
  //   {
  //     "name": "Jenny Wilson",
  //     "role": "Face specialist",
  //     "image": "assets/specialist2.png",
  //   },
  //   {
  //     "name": "Kristin Watson",
  //     "role": "Hair specialist",
  //     "image": "assets/specialist3.png",
  //   },
  //   {
  //     "name": "Jacob Jones",
  //     "role": "Skin specialist",
  //     "image": "assets/specialist4.png",
  //   },
  // ];

  void changeMonth(bool isNext) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + (isNext ? 1 : -1),
      );
      selectedDate = 1; // Reset to first day when month changes
    });
  }

  TimeOfDay _parseTimeTo24Hour(String timeString) {
    try {
      final cleaned =
          timeString
              .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

      final formats = [
        DateFormat.jm(), // 1:00 PM
        DateFormat('h:mm a'), // explicit format
      ];

      for (final format in formats) {
        try {
          final dateTime = format.parse(cleaned);
          return TimeOfDay.fromDateTime(dateTime);
        } catch (e) {
          continue;
        }
      }

      // Fallback for simple time strings
      final parts = cleaned.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minuteParts = parts[1].split(' ');
        final minute = int.tryParse(minuteParts[0]) ?? 0;
        final period =
            minuteParts.length > 1 ? minuteParts[1].toLowerCase() : 'am';

        var hour24 = hour;
        if (period == 'pm' && hour != 12) hour24 = hour + 12;
        if (period == 'am' && hour == 12) hour24 = 0;

        return TimeOfDay(hour: hour24, minute: minute);
      }

      throw FormatException('Unable to parse time: $timeString');
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('vendorId: ${widget.vendorId}');
    print('Service: ${widget.services}');
    final List<Map<String, dynamic>> subcategories = widget.services;
    final totalPrice = subcategories.fold<double>(
      0.0,
      (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0),
    );

    final servicesId =
        subcategories.map((item) => item['serviceId'].toString()).toList();
    final serviceName =
        subcategories.map((item) => item['serviceId'].toString()).toList();
    print(servicesId);
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

                          // Time Selection
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
                                isSelected: isAmSelected,
                                onTap:
                                    () => setState(() {
                                      isAmSelected = true;
                                      selectedTime = times.first;
                                    }),
                              ),
                              CustomCheckBox(
                                title: 'PM',
                                isSelected: !isAmSelected,
                                onTap:
                                    () => setState(() {
                                      isAmSelected = false;
                                      selectedTime = times.first;
                                    }),
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
                          // const Text(
                          //   "Top specialists",
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),

                          // Specialist Grid
                          // GridView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   padding: const EdgeInsets.only(top: 10),
                          //   gridDelegate:
                          //       SliverGridDelegateWithFixedCrossAxisCount(
                          //         crossAxisCount: 3,
                          //         mainAxisSpacing: 10,
                          //         crossAxisSpacing: 10,
                          //         mainAxisExtent: 400,
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
                          //           // Container(
                          //           //   height: 300, // Fixed height
                          //           //   margin: EdgeInsets.symmetric(
                          //           //     horizontal: 5,
                          //           //     vertical: 5,
                          //           //   ),
                          //           //   decoration: BoxDecoration(
                          //           //     borderRadius: BorderRadius.circular(20),
                          //           //     image: DecorationImage(
                          //           //       image: AssetImage(
                          //           //         specialists[index]['image']!,
                          //           //       ),
                          //           //       fit: BoxFit.fill,
                          //           //     ),
                          //           //   ),
                          //           // ),
                          //           Padding(
                          //             padding: const EdgeInsets.symmetric(
                          //               horizontal: 10,
                          //             ),
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
                          //                           image: AssetImage(
                          //                             'assets/star.png',
                          //                           ),
                          //                         ),
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
                                                serviceName[0],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                '',
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
                  print('vendorId: ${widget.vendorId}');
                  print('Service: $servicesId');
                  if (activeStep == 0) {
                    final selectedDateTime = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      selectedDate,
                      _parseTimeTo24Hour(selectedTime).hour,
                      _parseTimeTo24Hour(selectedTime).minute,
                    );
                    print('vendorId: ${widget.vendorId}');

                    final success = await bookingController.createBooking(
                      vendorId: widget.vendorId,
                      serviceIds: servicesId,
                      bookingDate: selectedDateTime,
                    );
                    // await Get.offAll(() => CustomNavBar());

                    if (success) {
                      setState(() => activeStep = 1);
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

                        // Date Selection
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
                                  String dayName = DateFormat(
                                    'E',
                                  ).format(dateTime);

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
                            // In your time selection row, replace the CustomCheckBox widgets with:
                            CustomCheckBox(
                              title: 'AM',
                              isSelected: isAmSelected,
                              onTap:
                                  () => setState(() {
                                    isAmSelected = true;
                                    selectedTime =
                                        times.first; // Reset to first AM time
                                  }),
                            ),
                            CustomCheckBox(
                              title: 'PM',
                              isSelected: !isAmSelected,
                              onTap:
                                  () => setState(() {
                                    isAmSelected = false;
                                    selectedTime =
                                        times.first; // Reset to first PM time
                                  }),
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
                                            Text(
                                              '\$$totalPrice',
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
                if (activeStep < 1) {
                  setState(() {
                    activeStep++;
                  });
                } else {
                  // print(widget.subcategoryId);

                  final selectedDateTime = DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    selectedDate,
                    _parseTimeTo24Hour(selectedTime).hour,
                    _parseTimeTo24Hour(selectedTime).minute,
                  );

                  final success = await bookingController.createBooking(
                    vendorId: widget.vendorId.toString(),
                    serviceIds: widget.services,
                    bookingDate: selectedDateTime,
                  );

                  if (success) {
                    setState(() {
                      activeStep = 1;
                    });
                    await Get.offAll(() => CustomerBottomNavBarScreen());
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
