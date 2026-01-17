import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';

import '../../../../controllers/users/home/userBookingController.dart';
import '../../../../controllers/users/profile/profile_controller.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String vendorId;
  final List<Map<String, dynamic>> services;
  final String shopName;
  final String shopAddress;
  final bool hasPhysicalShop;
  final bool homeServiceAvailable;
  final String? vendorPhone;
  BookAppointmentScreen({
    super.key,
    required this.services,
    required this.vendorId, required this.shopName, required this.shopAddress, required this.hasPhysicalShop, required this.homeServiceAvailable, this.vendorPhone,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final bookingController = Get.put(UserBookingController());
  final profileController = Get.put(UserProfileController());
  bool isAmSelected = false; // false for PM, true for AM
  DateTime now = DateTime.now();
  late DateTime currentMonth;
  late int selectedDate;
  final TextEditingController specialRequestsController = TextEditingController();



  String selectedTime = "01:00 pm";
  bool isDayNight = false;
  String? serviceLocationType; // 'salon' or 'home'
  
  // Determine what options are available based on vendor settings
  bool get canVisitSalon => widget.hasPhysicalShop;
  bool get canGetHomeService => widget.homeServiceAvailable;
  
  // Show location selection ONLY if both options are available
  bool get showLocationSelection => canVisitSalon && canGetHomeService;
  
  // Check if we have at least one valid option
  bool get hasValidOption => canVisitSalon || canGetHomeService;
  
  // For legacy vendors (both false), default to salon
  bool get isLegacyVendor => !widget.hasPhysicalShop && !widget.homeServiceAvailable;
  
  List<int> get dates {
    final now = DateTime.now();
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // If the current month is the same as today's month,
    // start from today's date; otherwise start from 1
    final startDay = (currentMonth.year == now.year && currentMonth.month == now.month)
        ? now.day
        : 1;

    return List.generate(lastDay.day - startDay + 1, (i) => i + startDay);
  }



  String id = "";

  String generateRandomNumericId() {
    final rand = Random();
    int length = rand.nextInt(5) + 6; // 6 to 10 digits
    String id = '';
    for (int i = 0; i < length; i++) {
      id += rand.nextInt(10).toString(); // digits 0–9
    }
    return id;
  }



  int activeStep = 0;
  // DateTime currentMonth = DateTime.now();

  List<String> get times {
    if (isAmSelected) {
      return ["01:00 am",
        "02:00 am",
        "03:00 am",
        "04:00 am",
        "05:00 am",
        "06:00 am",
        "07:00 am",
        "08:00 am",
        "09:00 am",
        "10:00 am",
        "11:00 am",
        "12:00 pm",];
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
        "12:00 am",
      ];
    }
  }


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
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month);
    selectedDate = now.day;
    id = generateRandomNumericId();
    
    // DEBUG: Print what values we received
    print('=== BookAppointmentScreen initState ===');
    print('Shop: ${widget.shopName}');
    print('widget.hasPhysicalShop: ${widget.hasPhysicalShop} (${widget.hasPhysicalShop.runtimeType})');
    print('widget.homeServiceAvailable: ${widget.homeServiceAvailable} (${widget.homeServiceAvailable.runtimeType})');
    print('showLocationSelection will be: $showLocationSelection');
    
    // Auto-select service location based on what's available
    if (widget.hasPhysicalShop && !widget.homeServiceAvailable) {
      // Only salon available - auto-select
      serviceLocationType = 'salon';
      print('✓ Selected: salon (only physical shop)');
    } else if (widget.homeServiceAvailable && !widget.hasPhysicalShop) {
      // Only home service available - auto-select
      serviceLocationType = 'home';
      print('✓ Selected: home (only home service)');
    } else if (!widget.hasPhysicalShop && !widget.homeServiceAvailable) {
      // Legacy vendor (both false) - default to salon
      serviceLocationType = 'salon';
      print('✓ Selected: salon (legacy vendor - both false)');
    } else {
      // Both options available - user must select
      serviceLocationType = null;
      print('✓ Both options available - user must select (serviceLocationType = null)');
    }
    print('Final serviceLocationType: $serviceLocationType');
    print('=====================================');
  }

  Future<void> _showAddressDialog() async {
    final addressLine1Controller = TextEditingController();
    final addressLine2Controller = TextEditingController();
    final pincodeController = TextEditingController();
    double? selectedLat;
    double? selectedLong;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Address',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: addressLine1Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 1',
                        hintText: 'Street, Building name',
                        hintStyle: TextStyle(color: kGreyColor.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreyColor2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreyColor2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: addressLine2Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 2',
                        hintText: 'Area, Landmark',
                        hintStyle: TextStyle(color: kGreyColor.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreyColor2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreyColor2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Pincode',
                        hintText: 'Enter pincode',
                        hintStyle: TextStyle(color: kGreyColor.withOpacity(0.6)),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreyColor2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kGreyColor2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        // TODO: Open map to select location
                        // For now, use current location
                        try {
                          Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                          );
                          setDialogState(() {
                            selectedLat = position.latitude;
                            selectedLong = position.longitude;
                          });
                          Get.snackbar(
                            'Location Selected',
                            'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: Duration(seconds: 2),
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to get location: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: kGreyColor2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on, 
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedLat != null && selectedLong != null
                                        ? 'Location: ${selectedLat!.toStringAsFixed(4)}, ${selectedLong!.toStringAsFixed(4)}'
                                        : 'Click here to select location',
                                    style: TextStyle(
                                      color: selectedLat != null ? Colors.black : kGreyColor,
                                      fontSize: 14,
                                      fontWeight: selectedLat != null ? FontWeight.w500 : FontWeight.w400,
                                    ),
                                  ),
                                  if (selectedLat == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Tap to get current location',
                                        style: TextStyle(
                                          color: kGreyColor.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: kGreyColor2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (addressLine1Controller.text.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter address line 1',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              if (pincodeController.text.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter pincode',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              if (selectedLat == null || selectedLong == null) {
                                Get.snackbar(
                                  'Error',
                                  'Please select location on map',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              // Combine address lines
                              String fullAddress = addressLine1Controller.text;
                              if (addressLine2Controller.text.isNotEmpty) {
                                fullAddress += ', ${addressLine2Controller.text}';
                              }
                              fullAddress += ', ${pincodeController.text}';

                              // Update profile controller
                              profileController.locationAddress.value = fullAddress;
                              profileController.userLat.value = selectedLat.toString();
                              profileController.userLong.value = selectedLong.toString();

                              try {
                                // Save to database
                                await profileController.updateUserProfile(
                                  locationAddress: fullAddress,
                                  userLat: selectedLat.toString(),
                                  userLong: selectedLong.toString(),
                                  userName: profileController.name.value,
                                  email: profileController.email.value,
                                  phoneNumber: profileController.phoneNumber.value,
                                  dateOfBirth: profileController.dateOfBirth.value,
                                  gender: profileController.gender.value,
                                );

                                Navigator.of(context).pop();
                                Get.snackbar(
                                  'Success',
                                  'Address saved successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: kPrimaryColor,
                                  colorText: Colors.black,
                                );
                              } catch (e) {
                                Navigator.of(context).pop();
                                Get.snackbar(
                                  'Error',
                                  'Failed to save address: ${e.toString()}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: kPrimaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) =>
          '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

      int _calculateTotalDuration() {
        // Calculate total duration from all services
        // Default to 30 minutes per service if no duration specified
        return widget.services.fold<int>(0, (sum, service) {
          return sum + 30; // Default 30 minutes per service
        });
      }

      @override
      Widget build(BuildContext context) {
        print('vendorId: ${widget.vendorId}');
        print('hasPhysicalShop: ${widget.hasPhysicalShop}');
        print('homeServiceAvailable: ${widget.homeServiceAvailable}');
        print('showLocationSelection: $showLocationSelection');
        print('serviceLocationType: $serviceLocationType');
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
                            "Review Booking",
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
                            listStep: ["Book Appointment", "Review Booking"],
                            step: activeStep,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (activeStep == 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // DEBUG INFO
                              Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(bottom: 10),
                                color: Colors.yellow.shade100,
                                child: Text(
                                  'DEBUG: Shop=${widget.shopName}, hasPhysical=${widget.hasPhysicalShop}, homeService=${widget.homeServiceAvailable}, showSelection=$showLocationSelection, locationType=$serviceLocationType',
                                  style: TextStyle(fontSize: 10, color: Colors.black),
                                ),
                              ),
                              // Show info banner when only one option is available (auto-selected)
                              if (!showLocationSelection && serviceLocationType != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: serviceLocationType == 'home' 
                                        ? Colors.orange.shade50 
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: serviceLocationType == 'home' 
                                          ? Colors.orange.shade200 
                                          : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        serviceLocationType == 'home' 
                                            ? Icons.home_rounded 
                                            : Icons.store_rounded,
                                        color: serviceLocationType == 'home' 
                                            ? Colors.orange.shade700 
                                            : Colors.green.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          serviceLocationType == 'home'
                                              ? "This vendor offers home service only"
                                              : "This service will be at the salon",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: serviceLocationType == 'home' 
                                                ? Colors.orange.shade700 
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 25),
                              ],
                              // Show selection buttons ONLY when both options are available
                              if (showLocationSelection) ...[
                                const Text(
                                  "Select service location",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => serviceLocationType = 'salon'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          decoration: BoxDecoration(
                                            color: serviceLocationType == 'salon' ? kPrimaryColor : Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: serviceLocationType == 'salon' ? kPrimaryColor : kGreyColor2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Visit Salon",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => serviceLocationType = 'home'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          decoration: BoxDecoration(
                                            color: serviceLocationType == 'home' ? kPrimaryColor : Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: serviceLocationType == 'home' ? kPrimaryColor : kGreyColor2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Home Service",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                              ],
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
                                SizedBox(width: 10,),
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

                            const SizedBox(height: 25),
                            
                            // Buffer Time Info Banner
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Note: We automatically add 1-hour buffer between appointments to account for delays and travel time.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Special Requests Section
                            const Text(
                              "Special requests (Optional)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: specialRequestsController,
                              maxLines: 3,
                              maxLength: 500,
                              decoration: InputDecoration(
                                hintText: 'Any specific requirements, preferences, or notes for the vendor...',
                                hintStyle: TextStyle(color: kGreyColor.withOpacity(0.6), fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: kGreyColor2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: kGreyColor2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: kPrimaryColor, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
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
                                    fontWeight: FontWeight.w100, // Reduced font weight
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "You can view the appointment booking info in the “Appointment” section.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100, // Reduced font weight
                                    color: kGreyColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
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
                                            fontWeight: FontWeight.w100, // Reduced font weight
                                          ),
                                        ),
                                        Text(
                                          '#$id',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100, // Reduced font weight
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.shopName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.shopAddress,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 15),
                                    Divider(color: kGreyColor2),
                                    SizedBox(height: 15),
                                    ...widget.services.map((service) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
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
                                                      Expanded(
                                                        child: Text(
                                                          service['serviceName'] ?? '',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 13,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        '\$${service['price']}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    service['categoryName'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: kGreyColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Image(
                                          image: AssetImage(
                                            'assets/timer.png',
                                          ),
                                          height: 14,
                                        ),
                                        SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            '${DateFormat('d MMMM, yyyy').format(DateTime(currentMonth.year, currentMonth.month, selectedDate))} at $selectedTime',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, size: 14, color: kGreyColor),
                                        SizedBox(width: 3),
                                        Text(
                                          'Estimated duration: ${_calculateTotalDuration()} minutes',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: kGreyColor,
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
                        
                        // Validate past date
                        if (selectedDateTime.isBefore(DateTime.now())) {
                          Get.snackbar(
                            'Invalid Date',
                            'Cannot book appointments in the past',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        
                        // Validate service location selection if needed
                        if (showLocationSelection && serviceLocationType == null) {
                          Get.snackbar(
                            'Selection Required',
                            'Please select service location (Salon or Home)',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        
                        print('vendorId: ${widget.vendorId}');

                        final success = await bookingController.createBooking(
                          vendorId: widget.vendorId,
                          serviceIds: servicesId,
                          bookingDate: selectedDateTime,
                          userName: profileController.name.value,
                          userAddress: profileController.locationAddress.value,
                          userLat: profileController.userLat.value,
                          userLong: profileController.userLong.value,
                          specialRequests: specialRequestsController.text.trim(),
                          serviceLocationType: serviceLocationType,
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
                      "Review Booking",
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
                      listStep: ["Book Appointment", "Review Booking"],
                      step: activeStep,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (activeStep == 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show info banner when only one option is available (auto-selected)
                        if (!showLocationSelection && serviceLocationType != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: serviceLocationType == 'home' 
                                  ? Colors.orange.shade50 
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: serviceLocationType == 'home' 
                                    ? Colors.orange.shade200 
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  serviceLocationType == 'home' 
                                      ? Icons.home_rounded 
                                      : Icons.store_rounded,
                                  color: serviceLocationType == 'home' 
                                      ? Colors.orange.shade700 
                                      : Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    serviceLocationType == 'home'
                                        ? "This vendor offers home service only"
                                        : "This service will be at the salon",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: serviceLocationType == 'home' 
                                          ? Colors.orange.shade700 
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                        // Show selection buttons ONLY when both options are available
                        if (showLocationSelection) ...[
                          const Text(
                            "Select service location",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => serviceLocationType = 'salon'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      color: serviceLocationType == 'salon' ? kPrimaryColor : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: serviceLocationType == 'salon' ? kPrimaryColor : kGreyColor2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Visit Salon",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => serviceLocationType = 'home'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      color: serviceLocationType == 'home' ? kPrimaryColor : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: serviceLocationType == 'home' ? kPrimaryColor : kGreyColor2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Home Service",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                        ],
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
                                    onTap: () {
                                      final now = DateTime.now();
                                      final tappedDate = DateTime(currentMonth.year, currentMonth.month, date);

                                      // Block past dates (but allow today)
                                      if (tappedDate.isBefore(DateTime(now.year, now.month, now.day))) return;

                                      setState(() => selectedDate = date);
                                    },
                                    child: Opacity(
                                      opacity: DateTime(currentMonth.year, currentMonth.month, date)
                                          .isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                          ? 0.4 // Dim past dates
                                          : 1,
                                      child: Column(
                                        children: [
                                          Text(
                                            DateFormat('E').format(DateTime(currentMonth.year, currentMonth.month, date)),
                                            style: TextStyle(fontSize: 14, color: kGreyColor),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            width: 50,
                                            height: 50,
                                            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: date == selectedDate ? Colors.green : Colors.white,
                                              shape: BoxShape.circle,
                                              border: DateTime(currentMonth.year, currentMonth.month, date)
                                                  .isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                                  ? Border.all(color: Colors.grey.shade300)
                                                  : null,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              date.toString(),
                                              style: TextStyle(
                                                color: date == selectedDate ? Colors.white : Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                            SizedBox(width: 10,),
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

                        // Buffer Time Info Banner for mobile view
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Note: We automatically add 1-hour buffer between appointments for delays.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: times.map((time) {
                            bool isSelected = time == selectedTime;
                            return GestureDetector(
                              onTap: () => setState(() => selectedTime = time),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : kGreyColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 25),
                        
                        // Special Requests Section
                        const Text(
                          "Special requests (Optional)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: specialRequestsController,
                          maxLines: 3,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Any specific requirements, preferences, or notes for the vendor...',
                            hintStyle: TextStyle(color: kGreyColor.withOpacity(0.6), fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: kGreyColor2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: kGreyColor2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: kPrimaryColor, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
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
                            "Review Your\nBooking Details",
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
                              fontWeight: FontWeight.w100, // Reduced font weight
                              color: kGreyColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
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
                                      fontWeight: FontWeight.w100, // Reduced font weight
                                    ),
                                  ),
                                  Text(
                                    '#$id',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w100, // Reduced font weight
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.shopName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.shopAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kGreyColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.vendorPhone != null && widget.vendorPhone!.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  'Vendor Phone: ${widget.vendorPhone}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kGreyColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                              SizedBox(height: 15),
                              Divider(color: kGreyColor2),
                              SizedBox(height: 15),
                              Text(
                                'Your Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (serviceLocationType == 'home' && profileController.locationAddress.value.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            profileController.locationAddress.value,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: kGreyColor,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        InkWell(
                                          onTap: () async {
                                            await _showAddressDialog();
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              if (profileController.phoneNumber.value.isNotEmpty)
                                Text(
                                  'Phone: ${profileController.phoneNumber.value}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kGreyColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              SizedBox(height: 15),
                              Divider(color: kGreyColor2),
                              SizedBox(height: 15),
                              ...widget.services.map((service) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
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
                                                Expanded(
                                                  child: Text(
                                                    service['serviceName'] ?? '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  '\$${service['price']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              service['categoryName'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              SizedBox(height: 4),
                              Divider(color: kGreyColor2),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Image(
                                    image: AssetImage(
                                      'assets/timer.png',
                                    ),
                                    height: 14,
                                  ),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      '${DateFormat('d MMMM, yyyy').format(DateTime(currentMonth.year, currentMonth.month, selectedDate))} at $selectedTime',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 14, color: kGreyColor),
                                  SizedBox(width: 3),
                                  Text(
                                    'Estimated duration: ${_calculateTotalDuration()} minutes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: kGreyColor,
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
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 50,
                onPressed: () async {
                  if (activeStep < 1) {
                    // Validate before moving to next step
                    final selectedDateTime = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      selectedDate,
                      _parseTimeTo24Hour(selectedTime).hour,
                      _parseTimeTo24Hour(selectedTime).minute,
                    );
                    
                    // Validate past date
                    if (selectedDateTime.isBefore(DateTime.now())) {
                      Get.snackbar(
                        'Invalid Date',
                        'Cannot book appointments in the past',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // Validate service location selection if needed
                    if (showLocationSelection && serviceLocationType == null) {
                      Get.snackbar(
                        'Selection Required',
                        'Please select service location (Salon or Home)',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    setState(() {
                      activeStep++;
                    });
                  } else {
                    // print(widget.subcategoryId);

                    // Validate address if home service is selected
                    if (serviceLocationType == 'home' && 
                        (profileController.locationAddress.value.isEmpty || 
                         profileController.locationAddress.value == '')) {
                      await _showAddressDialog();
                      return;
                    }

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
                      userName: profileController.name.value,
                      userAddress: profileController.locationAddress.value,
                      userLat: profileController.userLat.value,
                      userLong: profileController.userLong.value,
                      specialRequests: specialRequestsController.text.trim(),
                      serviceLocationType: serviceLocationType,
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
                          "Finish booking",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}
