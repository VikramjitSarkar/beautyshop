import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/auth/genralController.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:geolocator/geolocator.dart';

import '../../../widgets/saloon_card_three.dart';

class SalonListScreen extends StatefulWidget {
  const SalonListScreen({
    super.key,
    required this.title,
    required this.categoryId,
  });
  final String title;
  final String categoryId;

  @override
  State<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends State<SalonListScreen> {
  final GenralController _generalController = Get.put(GenralController());
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  bool onlineNow = false;
  bool nearby = false;
  bool homeVisitAvailable = false;
  bool hasSalonLocation = false;
  RangeValues priceRange = const RangeValues(0, 300);
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isAvailableNow = true;

  @override
  void initState() {
    super.initState();
    _loadAllVendors(); // Load all vendors by default
  }

  // Load all vendors without filters
  void _loadAllVendors() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, load without location
        final result = await _generalController.fetchFilteredSubcategories(
          categoryId: widget.categoryId,
        );
        print(result);
        _generalController.filteredSubcategories.assignAll(result);
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, load without location
          final result = await _generalController.fetchFilteredSubcategories(
            categoryId: widget.categoryId,
          );
          _generalController.filteredSubcategories.assignAll(result);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, load without location
        final result = await _generalController.fetchFilteredSubcategories(
          categoryId: widget.categoryId,
        );
        _generalController.filteredSubcategories.assignAll(result);
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Load vendors with location
      final result = await _generalController.fetchFilteredSubcategories(
        userLat: position.latitude.toString(),
        userLong: position.longitude.toString(),
        categoryId: widget.categoryId,
      );
      print(result);
      _generalController.filteredSubcategories.assignAll(result);
    } catch (e) {
      // Fallback if any error occurs
      final result = await _generalController.fetchFilteredSubcategories(
        categoryId: widget.categoryId,
      );
      _generalController.filteredSubcategories.assignAll(result);
      Get.snackbar('Location Error', 'Using default location: ${e.toString()}');
    }
  }

  // apply filter
  void _applyFilters() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _generalController.fetchFilteredsSubcategories(
        categoryId: widget.categoryId,
        status: onlineNow ? "online" : null,
        homeVisit:
            homeVisitAvailable
                ? "on"
                : null, // or true if backend expects boolean
        hasSalon: hasSalonLocation ? "on" : null, // or true if boolean expected
        minPrice: priceRange.start.toInt(),
        maxPrice: priceRange.end.toInt(),
        onlineNow: onlineNow,
        nearby: nearby,
        selectedTime: isAvailableNow ? null : selectedTime,
        isAvailableNow: isAvailableNow,
        userLat: position.latitude.toString(),
        userLong: position.longitude.toString(),
      );
      print('Home Visit Available: $homeVisitAvailable');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadAllVendors();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
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
            titleSpacing: 0,
            title: Container(
              height: 50,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Image.asset('assets/search_Icon.png', scale: 4),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  hintText: 'Search',
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  filled: true,
                  fillColor: const Color(0xffFFFFFF),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFFC0C0C0), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFFC0C0C0), width: 1.5),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  final query = value.trim().toLowerCase();
                  if (query.isEmpty) {
                    _loadAllVendors();
                  } else {
                    final filtered = _generalController.filteredSubcategories.where((vendor) {
                      final name = (vendor['shopName'] ?? vendor['title'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(query);
                    }).toList();
                    _generalController.filteredSubcategories.assignAll(filtered);
                  }
                },
              ),
            ),
          ),
        ),
      ),

      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            // Search Bar
            // TextField(
            //   controller: _searchController,
            //   decoration: InputDecoration(
            //     prefixIcon: Image.asset('assets/search_Icon.png', scale: 4),
            //     hintText: 'Search',
            //     contentPadding: const EdgeInsets.symmetric(
            //       vertical: 16,
            //       horizontal: 20,
            //     ),
            //     filled: true,
            //     fillColor: const Color(0xffFFFFFF),
            //     enabledBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(40),
            //       borderSide: const BorderSide(
            //         color: Color(0xFFC0C0C0),
            //         width: 1,
            //       ),
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(40),
            //       borderSide: const BorderSide(
            //         color: Color(0xFFC0C0C0),
            //         width: 1.5,
            //       ),
            //     ),
            //   ),
            //   style: const TextStyle(color: Colors.black),
            //   onChanged: (value) {
            //     final query = value.trim().toLowerCase();
            //     if (query.isEmpty) {
            //       _loadAllVendors(); // Reset to all vendors when search is cleared
            //     } else {
            //       final filtered =
            //           _genralController.filteredSubcategories.where((vendor) {
            //             final name =
            //                 (vendor['shopName'] ?? vendor['title'] ?? '')
            //                     .toString()
            //                     .toLowerCase();
            //             return name.contains(query);
            //           }).toList();
            //       _genralController.filteredSubcategories.assignAll(filtered);
            //     }
            //   },
            // ),

            // Header and Filter Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: kHeadingStyle.copyWith(fontSize: 18),
                ),
                GestureDetector(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/filter1.png'),
                        scale: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Salon List
            Expanded(
              child: Obx(() {
                if (_generalController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_generalController.filteredSubcategories.isEmpty) {
                  return const Center(child: Text("No salons found"));
                }

                return ListView.builder(
                  itemCount: _generalController.filteredSubcategories.length,
                  itemBuilder: (context, index) {
                    final vendor =
                        _generalController.filteredSubcategories[index];

                    final rating =
                        double.tryParse(vendor['shopRating']?.toString() ?? '0') ?? 0;

                    final openingTime = Map<String, dynamic>.from(
                      vendor['openingTime'] ??
                          {
                            "weekdays": {"from": "", "to": ""},
                            "weekends": {"from": "", "to": ""},
                          },
                    );

                    final galleryImages =
                    vendor['gallery'] is List
                        ? List<String>.from(vendor['gallery'])
                        : [];
                    final shopName =
                    (vendor['shopName']?.toString().trim().isNotEmpty ?? false)
                        ? vendor['shopName']
                        : 'Unnamed Salon';

                    final shopBanner =
                    (vendor['shopBanner']?.toString().isNotEmpty ?? false)
                        ? vendor['shopBanner']
                        : '';
                    return SizedBox(
                      height: 210,
                      child: SaloonCardThree(
                        distanceKm: vendor['distance'],

                        rating: rating,
                        imageUrl: shopBanner,
                        shopeName: shopName,
                        location: vendor['locationAddres'],
                        onTap: () {
                          Get.to(
                                () => SaloonDetailPageScreen(
                              phoneNumber: vendor['phone'] ?? '',
                              rating: rating,
                              longitude: vendor['vendorLong'] ?? '',
                              latitude: vendor["vendorLat"] ?? '',
                              galleryImage: galleryImages,
                              vendorId: vendor["_id"] ?? '',
                              desc: vendor["description"] ?? '',
                              imageUrl: vendor["shopBanner"] ?? '',
                              location: vendor["locationAddres"] ?? '',
                              openingTime: openingTime,
                              shopName: vendor["shopName"] ?? '',
                              status: vendor["status"] ?? '',
                              title: vendor["title"] ?? '',
                              userName: vendor["userName"] ?? '',
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonCard(Map<String, dynamic> vendor) {
    final rating =
      double.tryParse(vendor['shopRating']?.toString() ?? '0') ?? 0;

  final openingTime = Map<String, dynamic>.from(
    vendor['openingTime'] ??
        {
          "weekdays": {"from": "", "to": ""},
          "weekends": {"from": "", "to": ""},
        },
  );

  final galleryImages =
  vendor['gallery'] is List
      ? List<String>.from(vendor['gallery'])
      : [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          Get.to(() => SaloonDetailPageScreen(
            phoneNumber: vendor['phone'] ?? '',
            rating: rating,
            longitude: vendor['vendorLong'] ?? '',
            latitude: vendor["vendorLat"] ?? '',
            galleryImage: galleryImages,
            vendorId: vendor["_id"] ?? '',
            desc: vendor["description"] ?? '',
            imageUrl: vendor["shopBanner"] ?? '',
            location: vendor["locationAddres"] ?? '',
            openingTime: openingTime,
            shopName: vendor["shopName"] ?? '',
            status: vendor["status"] ?? '',
            title: vendor["title"] ?? '',
            userName: vendor["userName"] ?? '',
          ));
        },
        child: Row(
          children: [
            Container(
              width: 130,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                border: vendor['shopBanner'] != null &&
                    vendor['shopBanner'].toString().isNotEmpty? null : Border.all(color: Colors.lightGreen, width: 0.5),

              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:
                    vendor['shopBanner'] != null &&
                            vendor['shopBanner'].toString().isNotEmpty
                        ? Image.network(
                          vendor['shopBanner'],
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/app icon 2.png',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                        )
                        : Image.asset(
                      'assets/app icon 2.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        vendor['avgRating'] ?? '0.0',
                        style: kHeadingStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (vendor['status'] == "online")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Online',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor['shopName'] ?? '',
                    style: kHeadingStyle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    vendor['locationAddres'] ?? 'No Address',
                    style: kSubheadingStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${vendor['distance'] ?? 'N/A'} km',
                          style: kSubheadingStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        height: 27,
                        width: 58,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: () {
                            Get.to(
                              () => SaloonDetailPageScreen(
                                phoneNumber: vendor['phone'] ?? '',
                                rating: rating,
                                longitude: vendor['vendorLong'] ?? '',
                                latitude: vendor["vendorLat"] ?? '',
                                galleryImage: galleryImages,
                                vendorId: vendor["_id"] ?? '',
                                desc: vendor["description"] ?? '',
                                imageUrl: vendor["shopBanner"] ?? '',
                                location: vendor["locationAddres"] ?? '',
                                openingTime: openingTime,
                                shopName: vendor["shopName"] ?? '',
                                status: vendor["status"] ?? '',
                                title: vendor["title"] ?? '',
                                userName: vendor["userName"] ?? '',
                              ),
                            );
                          },
                          child: const FittedBox(
                            child: Text(
                              'Book',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: kHeadingStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter options...
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Online Now'),
                    subtitle: const Text(
                      'Show specialists available for instant booking',
                    ),
                    value: onlineNow,
                    activeColor: Colors.white,
                    activeTrackColor: kPrimaryColor,
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    inactiveTrackColor: kGreyColor2,
                    inactiveThumbColor: Colors.white,
                    onChanged: (value) => setState(() => onlineNow = value),
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Home Visit Available'),
                    subtitle: const Text('Specialists who can come to you'),
                    value: homeVisitAvailable,
                    activeColor: Colors.white,
                    activeTrackColor: kPrimaryColor,
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    inactiveTrackColor: kGreyColor2,
                    inactiveThumbColor: Colors.white,
                    onChanged:
                        (value) => setState(() => homeVisitAvailable = value),
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Nearby'),
                    subtitle: const Text('Sort by closest distance'),
                    value: nearby,
                    activeColor: Colors.white,
                    activeTrackColor: kPrimaryColor,
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    inactiveTrackColor: kGreyColor2,
                    inactiveThumbColor: Colors.white,
                    onChanged: (value) => setState(() => nearby = value),
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Has Salon/Location'),
                    subtitle: const Text('Specialists with their own location'),
                    value: hasSalonLocation,
                    activeColor: Colors.white,
                    activeTrackColor: kPrimaryColor,
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    inactiveTrackColor: kGreyColor2,
                    inactiveThumbColor: Colors.white,
                    onChanged:
                        (value) => setState(() => hasSalonLocation = value),
                  ),

                  const SizedBox(height: 16),
                  Text('Price Range', style: TextStyle(color: kBlackColor)),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: priceRange,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    activeColor: kPrimaryColor,
                    inactiveColor: kGreyColor2,
                    labels: RangeLabels(
                      '\$${priceRange.start.toInt()}',
                      '\$${priceRange.end.toInt()}',
                    ),
                    onChanged: (values) => setState(() => priceRange = values),
                  ),

                  const SizedBox(height: 16),
                  // Text(
                  //   'Time Availability',
                  //   style: TextStyle(color: kBlackColor),
                  // ),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: GestureDetector(
                  //         onTap: () => setState(() => isAvailableNow = true),
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           decoration: BoxDecoration(
                  //             color:
                  //                 isAvailableNow
                  //                     ? kPrimaryColor
                  //                     : Colors.transparent,
                  //             border: Border.all(
                  //               color:
                  //                   isAvailableNow
                  //                       ? kPrimaryColor
                  //                       : kBlackColor,
                  //             ),
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: Center(
                  //             child: Text(
                  //               'Available Now',
                  //               style: TextStyle(
                  //                 color:
                  //                     isAvailableNow
                  //                         ? Colors.black
                  //                         : kBlackColor,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: GestureDetector(
                  //         onTap: () async {
                  //           final TimeOfDay? time = await showTimePicker(
                  //             context: context,
                  //             initialTime: selectedTime,
                  //           );
                  //           if (time != null) {
                  //             setState(() {
                  //               selectedTime = time;
                  //               isAvailableNow = false;
                  //             });
                  //           }
                  //         },
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           decoration: BoxDecoration(
                  //             color:
                  //                 !isAvailableNow
                  //                     ? kPrimaryColor
                  //                     : Colors.transparent,
                  //             border: Border.all(
                  //               color:
                  //                   !isAvailableNow
                  //                       ? kPrimaryColor
                  //                       : kBlackColor,
                  //             ),
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: Center(
                  //             child: Text(
                  //               !isAvailableNow
                  //                   ? 'After ${selectedTime.format(context)}'
                  //                   : 'Choose Time',
                  //               style: TextStyle(
                  //                 color:
                  //                     !isAvailableNow
                  //                         ? Colors.white
                  //                         : kBlackColor,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Apply and Reset Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              // Reset all filters
                              onlineNow = false;
                              nearby = false;
                              homeVisitAvailable = false;
                              hasSalonLocation = false;
                              priceRange = const RangeValues(0, 500);
                              isAvailableNow = true;
                              selectedTime = TimeOfDay.now();
                            });
                            _loadAllVendors(); // Load all vendors
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: kPrimaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
