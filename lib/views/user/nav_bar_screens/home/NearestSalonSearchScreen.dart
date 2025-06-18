import 'package:beautician_app/utils/libs.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearestSalonSearchScreen extends StatefulWidget {
  const NearestSalonSearchScreen({super.key});

  @override
  State<NearestSalonSearchScreen> createState() => _NearestSalonSearchScreenState();
}

class _NearestSalonSearchScreenState extends State<NearestSalonSearchScreen> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Custom App Bar with Search Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset('assets/back icon.svg'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Color(0xffC0C0C0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage('assets/search_Icon.png'), scale: 4),
                                  ),
                                ),
                                hintText: "Lotus Salon",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // Make it fullscreen
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  String selectedService = "Haircuts";
                                  double distance = 2.5;
                                  int selectedRating = 5;
                                  String selectedGender = "All";
                                  bool verifiedOnly = false;
                                  List<String> selectedLanguages = [];
                                  String experienceLevel = "Any";

                                  final List<String> languages = ["English", "Arabic", "Hindi", "Bengali"];
                                  final List<String> experienceLevels = [
                                    "Any",
                                    "1+ years",
                                    "3+ years",
                                    "5+ years",
                                    "10+ years"
                                  ];

                                  return StatefulBuilder(
                                    // To update state within the bottom sheet
                                    builder: (context, setState) {
                                      void updateGender(String gender) {
                                        setState(() {
                                          selectedGender = gender;
                                        });
                                      }

                                      return Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Header
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Advanced Filters",
                                                      style: kHeadingStyle.copyWith(
                                                          fontWeight: FontWeight.w700, fontSize: 18),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.close),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 24),

                                                // Services Section (Your existing code)
                                                Text("Services", style: kHeadingStyle.copyWith(fontSize: 18)),
                                                SizedBox(height: 4),
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    spacing: 15,
                                                    children: [
                                                      CustomServiceButton(
                                                        serviceName: "Hair",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/Haircuts1.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Hair"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Nails",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/Make up1.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Nails"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Brows and Lashese",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/Manicure1.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Brows and Lashes"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Make up",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/Hairstyling1.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Make up"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Waxing",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/piercing.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Waxing"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Skin care",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/tattoo.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Skin care"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Tanning",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/laser_hair_removal.png',
                                                        onTap: () => setState(
                                                            () => selectedService = "Tanning"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Tatoos",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/tattoo_removal.png',
                                                        onTap: () => setState(
                                                            () => selectedService = "Tatoos"),
                                                      ),
                                                      CustomServiceButton(
                                                        serviceName: "Piercings",
                                                        selectedService: selectedService,
                                                        imagePath: 'assets/ice_sculpture.png',
                                                        onTap: () =>
                                                            setState(() => selectedService = "Piercings"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 15),

                                                // Rating Section (Modified to include minimum rating)
                                                Text("Minimum Rating",
                                                    style: kHeadingStyle.copyWith(fontSize: 18)),
                                                SizedBox(height: 4),
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: List.generate(5, (index) {
                                                      final rating = 5 - index;
                                                      return Padding(
                                                        padding: EdgeInsets.only(right: 8),
                                                        child: CustomRatingButton(
                                                          rating: rating,
                                                          selectedRating: selectedRating,
                                                          onTap: () =>
                                                              setState(() => selectedRating = rating),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                                SizedBox(height: 15),

                                                // Distance Section
                                                Text("Travel Radius",
                                                    style: kHeadingStyle.copyWith(fontSize: 18)),
                                                SliderTheme(
                                                  data: SliderTheme.of(context).copyWith(
                                                    thumbColor: kPrimaryColor,
                                                    activeTrackColor: kPrimaryColor,
                                                    inactiveTrackColor: Colors.grey.shade300,
                                                    valueIndicatorColor: Colors.black,
                                                    valueIndicatorTextStyle: TextStyle(color: Colors.white),
                                                    activeTickMarkColor: Colors.transparent,
                                                    // Hide active tick marks
                                                    inactiveTickMarkColor:
                                                        Colors.transparent, // Hide inactive tick marks
                                                  ),
                                                  child: Slider(
                                                    value: distance,
                                                    min: 0,
                                                    max: 20,
                                                    divisions: 20,
                                                    label: "${distance.toStringAsFixed(1)} km",
                                                    onChanged: (value) => setState(() => distance = value),
                                                  ),
                                                ),
                                                SizedBox(height: 15),

                                                // Languages Section
                                                Text("Languages Spoken",
                                                    style: kHeadingStyle.copyWith(fontSize: 18)),
                                                SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: languages.map((language) {
                                                    final isSelected = selectedLanguages.contains(language);
                                                    return FilterChip(
                                                      backgroundColor: Colors.white,
                                                      label: Text(language),
                                                      selected: isSelected,
                                                      onSelected: (selected) {
                                                        setState(() {
                                                          if (selected) {
                                                            selectedLanguages.add(language);
                                                          } else {
                                                            selectedLanguages.remove(language);
                                                          }
                                                        });
                                                      },
                                                      selectedColor: kPrimaryColor.withOpacity(0.2),
                                                      checkmarkColor: kPrimaryColor,
                                                    );
                                                  }).toList(),
                                                ),
                                                SizedBox(height: 15),

                                                // Experience Level
                                                Text("Experience Level",
                                                    style:
                                                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                SizedBox(height: 4),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey.shade300),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<String>(
                                                      isExpanded: true,
                                                      value: experienceLevel,
                                                      items: experienceLevels.map((level) {
                                                        return DropdownMenuItem(
                                                          value: level,
                                                          child: Text(level),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          experienceLevel = value!;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 15),

                                                // Verified Profile Switch
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Verified Profiles Only",
                                                            style: kHeadingStyle.copyWith(fontSize: 18)),
                                                        Text("Show only verified professionals",
                                                            style: kSubheadingStyle),
                                                      ],
                                                    ),
                                                    Switch(
                                                      value: verifiedOnly,
                                                      activeColor: Colors.white,
                                                      activeTrackColor: kPrimaryColor,
                                                      trackOutlineColor:
                                                          WidgetStatePropertyAll(Colors.transparent),
                                                      inactiveTrackColor: kGreyColor2,
                                                      inactiveThumbColor: Colors.white,
                                                      onChanged: (value) =>
                                                          setState(() => verifiedOnly = value),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                // Apply Button
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: kPrimaryColor,
                                                    minimumSize: Size(double.infinity, 50),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    // Return filter data
                                                    Navigator.pop(context, {
                                                      'service': selectedService,
                                                      'rating': selectedRating,
                                                      'distance': distance,
                                                      'languages': selectedLanguages,
                                                      'experienceLevel': experienceLevel,
                                                      'verifiedOnly': verifiedOnly,
                                                    });
                                                  },
                                                  child: Text(
                                                    "Apply Filters",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                              ],
                                            ),
                                          ));
                                    },
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: Color(0xffF8F8F8),
                                shape: BoxShape.circle,
                                image: DecorationImage(image: AssetImage('assets/filter1.png'), scale: 4),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            /// Map Section with Route
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: const LatLng(37.42796133580664, -122.085749655962),
                            zoom: 14.4746,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5,
                      right: 5,
                      child: Container(
                        height: 138,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)]),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Color(0xffC0C0C0)),
                                    ),
                                    child: SvgPicture.asset('assets/location-Bold.svg'),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    child: Container(
                                      height: 39,
                                      width: 222,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Your location',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: kHeadingStyle.copyWith(
                                                  fontSize: 14, fontWeight: FontWeight.w700)),
                                          Text('4140 Parker Rd. Allentown, New Mexico...',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12, color: kGreyColor)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    height: 44,
                                    width: 44,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: AssetImage('assets/directions.png')),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 21,
                              top: 43,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  return Column(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: 5,
                                        color: Colors.black,
                                      ),
                                      SizedBox(height: 3),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white),
                                        image: DecorationImage(
                                            image: AssetImage('assets/salon3.png'), fit: BoxFit.fill)),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Lotus Salon',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: kHeadingStyle.copyWith(
                                              fontSize: 14, fontWeight: FontWeight.w700)),
                                      Text('1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12, color: kGreyColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
