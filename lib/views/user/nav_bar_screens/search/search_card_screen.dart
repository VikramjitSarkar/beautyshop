import 'package:beautician_app/views/widgets/saloon_card_three.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/auth/genralController.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../data/db_helper.dart';

class SearchCardScreen extends StatefulWidget {
  SearchCardScreen({
    super.key,
    required this.title,
    required this.categoryId,
    required this.searchQuery,
  });

  final String title;
  final String categoryId;
  final String searchQuery;

  @override
  State<SearchCardScreen> createState() => _SearchCardScreenState();
}

class _SearchCardScreenState extends State<SearchCardScreen> {
  final GenralController _generalController = Get.put(GenralController());
  // Cache for vendor categories
  final Map<String, List<String>> _vendorCategoriesCache = {};
  bool onlineNow = false;
  bool nearby = false;
  bool homeVisitAvailable = false;
  bool hasSalonLocation = false;
  RangeValues priceRange = const RangeValues(0, 500);
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isAvailableNow = true;
  
  // Payment method filter
  List<String> selectedPaymentMethods = [];
  final List<Map<String, dynamic>> availablePaymentMethods = [
    {'name': 'PayPal', 'icon': Icons.account_balance_wallet, 'color': Colors.blue},
    {'name': 'Stripe', 'icon': Icons.credit_card, 'color': Colors.purple},
    {'name': 'Razorpay', 'icon': Icons.payment, 'color': Colors.indigo},
    {'name': 'Cash', 'icon': Icons.money, 'color': Colors.green},
    {'name': 'Card', 'icon': Icons.credit_card, 'color': Colors.orange},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance, 'color': Colors.teal},
  ];

  int activeButtonIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllVendors(); // Load all vendors by default
  }

  // Fetch vendor's categories from their services
  Future<List<String>> _fetchVendorCategories(String vendorId) async {
    // Check cache first
    if (_vendorCategoriesCache.containsKey(vendorId)) {
      return _vendorCategoriesCache[vendorId]!;
    }

    try {
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/service/byVendorId/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GlobalsVariables.token}',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final List<dynamic> services = body['data'] ?? [];
          
          // Extract unique category names
          final categories = services
              .where((s) => s != null && s['categoryId'] != null)
              .map((s) => s['categoryId']['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();
          
          // Cache the result
          _vendorCategoriesCache[vendorId] = categories;
          return categories;
        }
      }
    } catch (e) {
      print('Error fetching vendor categories: $e');
    }

    return []; // Return empty if no categories found
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
        homeVisit: homeVisitAvailable ? "on" : null,
        hasSalon: hasSalonLocation ? "on" : null,
        minPrice: priceRange.start.toInt(),
        maxPrice: priceRange.end.toInt(),
        onlineNow: onlineNow,
        nearby: nearby,
        selectedTime: isAvailableNow ? null : selectedTime,
        isAvailableNow: isAvailableNow,
        userLat: position.latitude.toString(),
        userLong: position.longitude.toString(),
        paymentMethods: selectedPaymentMethods.isNotEmpty ? selectedPaymentMethods : null,
      );

      if(activeButtonIndex == 1){
        //sort by distance
        sortVendorsByDistanceNearestFirst(_generalController.filteredSubcategories);

      }else if(activeButtonIndex == 2){
        //sort by popularity
        sortVendorsByPopularity(_generalController.filteredSubcategories);

      }else if(activeButtonIndex == 3){
        //sort by rating
        sortVendorsByRatingHighFirst(_generalController.filteredSubcategories);

      }

    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
          child: Column(
            children: [
              // Search Bar
              const SizedBox(height: 15),

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
                        color: kPrimaryColor,
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

                  final searchQuery = widget.searchQuery.trim().toLowerCase();
                  final se =
                      searchQuery.isEmpty
                          ? _generalController.filteredSubcategories
                          : _generalController.filteredSubcategories.where((
                            vendor,
                          ) {
                            final name =
                                (vendor['shopName'] ?? '')
                                    .toString()
                                    .toLowerCase();
                            return name.contains(searchQuery);
                          }).toList();
                  print(se);
                  return Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: ListView.builder(
                      itemCount: se.length,
                      itemBuilder: (context, index) {
                        final vendor = se[index]; // ✅ use filtered list


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
                          height: 230,
                          child: FutureBuilder<List<String>>(
                            future: _fetchVendorCategories(vendor['_id'] ?? ''),
                            builder: (context, snapshot) {
                              final categories = snapshot.data ?? [];
                              final vendorId = vendor['_id'] ?? '';
                              
                              return FutureBuilder<bool>(
                                future: DBHelper.isFavorite(vendorId),
                                builder: (context, favSnapshot) {
                                  final isFav = favSnapshot.data ?? false;
                                  
                                  return SaloonCardThree(
                                    distanceKm: vendor['distance']?.toString() ?? 'Unknown',
                                    rating: rating,
                                    imageUrl: shopBanner,
                                    shopName: shopName,
                                    location: (vendor['locationAddress'] ?? vendor['locationAddres'])?.toString() ?? '',
                                    categories: categories.take(3).toList(),
                                    hasPhysicalShop: parseBool(vendor["hasPhysicalShop"]),
                                    homeServiceAvailable: parseBool(vendor["homeServiceAvailable"]),
                                    isFavorite: isFav,
                                    onFavoriteTap: () {
                                      final genCtrl = Get.find<GenralController>();
                                      genCtrl.toggleFavorite(vendorId);
                                      setState(() {}); // Refresh UI
                                    },
                                    onTap: () {
                              Get.to(
                                    () => SaloonDetailPageScreen(
                                  phoneNumber: vendor['phone']?.toString() ?? '',
                                  rating: rating,
                                  longitude: vendor['vendorLong']?.toString() ?? '',
                                  latitude: vendor["vendorLat"]?.toString() ?? '',
                                  galleryImage: galleryImages,
                                  vendorId: vendor["_id"]?.toString() ?? '',
                                  desc: vendor["description"]?.toString() ?? '',
                                  imageUrl: vendor["shopBanner"]?.toString() ?? '',
                                  location: (vendor["locationAddress"] ?? vendor["locationAddres"])?.toString() ?? '',
                                  openingTime: openingTime,
                                  shopName: vendor["shopName"]?.toString() ?? '',
                                  status: vendor["status"]?.toString() ?? '',
                                  title: vendor["title"]?.toString() ?? '',
                                  userName: vendor["userName"]?.toString() ?? '',
                                  hasPhysicalShop: parseBool(vendor["hasPhysicalShop"]),
                                  homeServiceAvailable: parseBool(vendor["homeServiceAvailable"]),
                                ),
                              );
                            },
                          );
                                },
                              );
                        },
                      ),
                    );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
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
            return SafeArea(
              child: Container(
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
                  SizedBox(height: 15,),
                  Text(
                    'Sort by',
                    style: kHeadingStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => activeButtonIndex = 1);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: activeButtonIndex==1? kPrimaryColor : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: activeButtonIndex==1? BorderSide.none : BorderSide(color: kPrimaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Near by',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => activeButtonIndex = 2);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: activeButtonIndex==2? kPrimaryColor : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: activeButtonIndex==2? BorderSide.none : BorderSide(color: kPrimaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => activeButtonIndex = 3);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: activeButtonIndex==3? kPrimaryColor : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: activeButtonIndex==3? BorderSide.none : BorderSide(color: kPrimaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Rating',
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
                  const SizedBox(height: 15),

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

                  const SizedBox(height: 20),
                  Text('Payment Methods', style: TextStyle(color: kBlackColor, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availablePaymentMethods.map((method) {
                      final isSelected = selectedPaymentMethods.contains(method['name']);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedPaymentMethods.remove(method['name']);
                            } else {
                              selectedPaymentMethods.add(method['name']);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? method['color'].withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? method['color']
                                  : kGreyColor2,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                method['icon'],
                                size: 18,
                                color: isSelected
                                    ? method['color']
                                    : kGreyColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                method['name'],
                                style: TextStyle(
                                  color: isSelected
                                      ? method['color']
                                      : kGreyColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
                  // const SizedBox(height: 16),
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
                  //                         ? Colors.black
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
                  const SizedBox(height: 24),

                  // Apply and Reset Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            this.setState(() {
                              // Reset all filters
                              onlineNow = false;
                              nearby = false;
                              homeVisitAvailable = false;
                              hasSalonLocation = false;
                              priceRange = const RangeValues(0, 500);
                              isAvailableNow = true;
                              selectedTime = TimeOfDay.now();
                              activeButtonIndex = 0;
                              selectedPaymentMethods.clear();
                            });
                            setState(() {
                              // Also update dialog state
                              onlineNow = false;
                              nearby = false;
                              homeVisitAvailable = false;
                              hasSalonLocation = false;
                              priceRange = const RangeValues(0, 500);
                              isAvailableNow = true;
                              selectedTime = TimeOfDay.now();
                              activeButtonIndex = 0;
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
            ),
            );
          },
        );
      },
    );
  }

  void sortVendorsByRatingHighFirst(List<Map<String, dynamic>> fetchedVendors) {
    fetchedVendors.sort((a, b) {
      double ratingA = _toDouble(a['shopRating']);
      double ratingB = _toDouble(b['shopRating']);

      return ratingB.compareTo(ratingA); // high → low
    });
  }

  void sortVendorsByPopularity(List<Map<String, dynamic>> fetchedVendors) {
    fetchedVendors.sort((a, b) {
      int countA = (a['favoriteCount'] is int) ? a['favoriteCount'] : (int.tryParse(a['favoriteCount']?.toString() ?? '0') ?? 0);
      int countB = (b['favoriteCount'] is int) ? b['favoriteCount'] : (int.tryParse(b['favoriteCount']?.toString() ?? '0') ?? 0);

      return countB.compareTo(countA); // high → low (most popular first)
    });
  }

  void sortVendorsByDistanceNearestFirst(List<Map<String, dynamic>> fetchedVendors) {
    fetchedVendors.sort((a, b) {
      double distanceA = _toDouble(a['distance']);
      double distanceB = _toDouble(b['distance']);

      return distanceA.compareTo(distanceB); // far → near
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
