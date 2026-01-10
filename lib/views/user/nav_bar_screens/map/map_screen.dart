import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/shopeController.dart';
import 'package:beautician_app/controllers/users/home/categoryController.dart';
import 'package:beautician_app/controllers/vendors/auth/add_services_controller.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/utils/text_styles.dart';
import 'package:beautician_app/views/widgets/saloon_card_four.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../../controllers/users/auth/genralController.dart';
import '../../../widgets/saloon_card_three.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin, WidgetsBindingObserver {


  final ShopController _shopController = Get.put(ShopController());
  final AddServicesController controller = Get.put(AddServicesController());
  final CategoryController categoryController = Get.put(CategoryController());
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<dynamic> _allVendors = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _originalVendors = [];
  List<dynamic> vendors = [];
  bool tabControllerInitialized = false;
  double lat = 0;
  double lng = 0;
  bool subCategorySelected = false;

  final double cardWidth = 180;


  final String _greyMapStyle = '''[
  {
    "featureType": "all",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e0e0e0"
      }
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4f4f4f"
      }
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#ffffff"
      },
      {
        "weight": 2
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#bfbfbf"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#a3a3a3"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#d6d6d6"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#cfd8dc"
      }
    ]
  }
]''';



  // Filter states
  bool onlineNow = false;
  bool nearby = false;
  bool homeVisitAvailable = false;
  bool hasSalonLocation = false;
  RangeValues priceRange = const RangeValues(0, 300);
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isAvailableNow = true;
  TabController? _subCategoryTabController;
  String? _selectedSubCategoryId;
  int activeButtonIndex = 0;



  final GenralController _generalController = Get.put(GenralController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    await _shopController.fetchCategories();
    if (_shopController.services.isNotEmpty) {
      _selectedCategoryId = _shopController.services[0]['_id'];
    }

    await controller.fetchSubcategories(_selectedCategoryId!);

    // Initialize tab controllers
    _tabController = TabController(length: _shopController.services.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // 👇 Create subcategory tab controller
    _subCategoryTabController = TabController(
      length: controller.subcategories.length,
      vsync: this,
    );

    _subCategoryTabController!.addListener(_handleSubCategoryTabChange);

    // ❌ No subcategory selected by default
    _selectedSubCategoryId = null;

    await _fetchNearbyVendors();

    setState(() {
      tabControllerInitialized = true;
    });
  }

  Future<void> _applySubcategoryFilter(String Id) async {
    _originalVendors.assignAll(vendors);
    if (_selectedSubCategoryId != null) {
      _allVendors = _originalVendors.where((vendor) {
        final services = vendor['services'] as List<dynamic>?;

        if (services == null) return false;

        return services.any((service) {
          final subCat = service['subcategoryId'];
          print("subId: $subCat");
          if (subCat is Map<String, dynamic>) {

            print("selected ${subCat['_id'] == Id}");
            print(Id);
            return subCat['_id'] == Id;
          }
          return false;
        });
      }).toList();
    } else {
      _allVendors = List.from(_originalVendors);
    }

    print("updatedd : $_allVendors");
    _originalVendors.assignAll(_allVendors);

    _filterVendors(); // your existing filtering logic (like search or distance etc.)
  }


  void _handleSubCategoryTabChange() {
    if (_subCategoryTabController!.indexIsChanging) return;

    setState(() {
      _selectedSubCategoryId =
      controller.subcategories[_subCategoryTabController!.index]['_id'];
    });

    _filterVendors(); // Only filter if user selects
  }


  void _handleTabChange() async {
    if (_tabController.indexIsChanging) return;

    setState(() {
      _selectedCategoryId = _shopController.services[_tabController.index]['_id'];
    });

    await controller.fetchSubcategories(_selectedCategoryId!);

    // 👇 Rebuild subcategory controller with new length
    _subCategoryTabController?.dispose();
    _subCategoryTabController = TabController(
      length: controller.subcategories.length,
      vsync: this,
    );

    _subCategoryTabController!.addListener(_handleSubCategoryTabChange);

    // ❌ Clear subcategory selection
    setState(() {
      _selectedSubCategoryId = null;
      subCategorySelected = false;
    });

    _fetchNearbyVendors();
  }




  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchNearbyVendors();
    }
  }

  Future<void> _fetchNearbyVendors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      lat = _currentPosition!.latitude;
      lng = _currentPosition!.longitude;

      await _generalController.fetchFilteredsSubcategories(
        userLat: _currentPosition!.latitude.toString(),
        userLong: _currentPosition!.longitude.toString(),
        categoryId: _selectedCategoryId!,
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

      );

      final result = _generalController.filteredSubcategories;

      print("Filtered Vendors: $result");

// // Assign result to controller and local list
//       _generalController.filteredSubcategories.assignAll(result);
      _originalVendors.clear();

      for (int i = 0; i < result.length; i++) {
        final vendor = result[i];
        final vendorId = vendor['_id'];

        // Fetch services for the current vendor
        await categoryController.fetchAndStoreServicesByVendorId(vendorId);

        // Create a new vendor map manually and attach a copy of the services list
        final updatedVendor = {
          ...vendor, // spreads the original map entries
          'services': List<dynamic>.from(categoryController.vendorServices), // ensures a fresh list
        };

        if(!(_originalVendors.contains(updatedVendor))){
          _originalVendors.add(updatedVendor);
        }
      }



      // controller.fetchSubcategories(_selectedCategoryId!);
      // print("subcategories of $_selectedCategoryId is: ${controller.subcategories}");
      // await _getLatLngFromAddress();
      vendors.assignAll(_originalVendors);
      _filterVendors();
      print("originall vendors: $_originalVendors");
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getLatLngFromAddress() async {
    print("outer for loop");
    for (int i = 0; i < _originalVendors.length; i++) {
      print("inner for loop");
      try {
        final address = _originalVendors[i]['locationAddress'];
        print("vendor address: $address");
        if (address == null || address.toString().isEmpty) continue;

        List<Location> locations = await locationFromAddress(address);
        print("location is: $locations");
        if (locations.isNotEmpty) {
          double lat = locations.first.latitude;
          double lng = locations.first.longitude;

          // Add lat/lng to the vendor map
          _originalVendors[i]['vendorLat'] = lat.toString();
          _originalVendors[i]['vendorLong'] = lng.toString();

          print('[$i] Converted "$address" → Lat: $lat, Lng: $lng');
        } else {
          print('[$i] No locations found for: $address');
        }
      } catch (e) {
        print('[$i] Error converting address: $e');
      }
    }

    print("after adding lat long: $_originalVendors");
  }


  void _updateMarkers(List<dynamic> vendors) async {
    print("updating markers");
    _markers.clear();
    for (var vendor in vendors) {
      final lat = double.tryParse(vendor['vendorLat'] ?? '0');
      final lng = double.tryParse(vendor['vendorLong'] ?? '0');
      // final imageUrl = vendor['profileImage'] ?? '';
      final rating = vendor['avgRating'] ?? '';
      final imageUrl = vendor['shopBanner'] ?? '';
      final shopName = vendor['shopName'] ?? '';
      double ratingValue = double.tryParse(rating.toString()) ?? 0.0;
      int index = ratingValue.floor();
      print("ratingss: $index");

      final openingTimeRaw = vendor['openingTime'];
      final openingTime = (openingTimeRaw == null ||
          (openingTimeRaw is Map && openingTimeRaw.isEmpty))
          ? {
        "weekdays": {"from": "", "to": ""},
        "weekends": {"from": "", "to": ""},
      }
          : Map<String, dynamic>.from(openingTimeRaw);


      final galleryImages =
      vendor['gallery'] is List
          ? List<String>.from(vendor['gallery'])
          : [];

      final List services = vendor['services'] ?? [];

// Look for a service where subcategoryId._id matches selectedSubCategoryId
      final serviceForSelected = services.firstWhere(
            (s) => s['subcategoryId']?['_id'] == _selectedSubCategoryId,
        orElse: () => null,
      );

// Get the charges
      final charges = serviceForSelected != null
          ? serviceForSelected['charges']?.toString() ?? '0'
          : '0';

      print("  $_selectedSubCategoryId: $charges");


      print("lat: ${lat == null}");
      print("lat: ${lng == null}");
      print("avgRatings: ${rating.isNotEmpty}");

      if (lat != null && lng != null && rating.isNotEmpty) {
        print("lat lng");
        final icon = await createTextMarker(text: "$rating", index: index, shopName: shopName, image: imageUrl, charges: charges);
        _markers.add(Marker(
          onTap: (){
            Get.to(() => SaloonDetailPageScreen(
              phoneNumber: vendor['phone'] ?? '',
              rating: ratingValue,
              longitude: vendor['vendorLong'] ?? '',
              latitude: vendor["vendorLat"] ?? '',
              galleryImage: galleryImages,
              vendorId: vendor["_id"] ?? '',
              desc: vendor["description"] ?? '',
              imageUrl: vendor["shopBanner"] ?? '',
              location: vendor["locationAddress"] ?? '',
              openingTime: openingTime,
              shopName: vendor["shopName"] ?? '',
              status: vendor["status"] ?? '',
              title: vendor["title"] ?? '',
              userName: vendor["userName"] ?? '',
              hasPhysicalShop: vendor["hasPhysicalShop"] ?? false,
              homeServiceAvailable: vendor["homeServiceAvailable"] ?? false,
            ));
          },
          markerId: MarkerId(vendor['_id']),
          position: LatLng(lat, lng),
          icon: icon,
        ));
      }
    }
    if (mounted) {
      print("mounted");
      setState(() {});
      print("map controller ${_mapController != null}");
      if (_markers.isNotEmpty && _mapController != null) {
        print("map controller is not null");
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(_getBounds(_markers.map((m) => m.position).toList()), 50));
      }
    }
    print("markers $_markers : ${_markers.length}");
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double x0 = points.first.latitude, x1 = x0;
    double y0 = points.first.longitude, y1 = y0;
    for (LatLng latLng in points) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  Future<BitmapDescriptor> createTextMarker({
    required String text,
    required int index,
    required String image,
    required String shopName,
    required String charges,
  }) async
  {
    const double width = 240;
    const double borderRadius = 20;
    const double imageWidth = 130;
    const double imageHeight = 120;
    const double imageCornerRadius = 15;
    const double spacing1 = 10;
    const double spacing2 = 6;
    const double sidePadding = 16;
    const double verticalPadding = 12; // <-- New vertical padding

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;

    final bool useFallback = image.isEmpty || image.trim().isEmpty;
    final ui.Image profileImage = useFallback
        ? await loadAssetImage('assets/app icon 2.png', imageWidth.toInt(), imageHeight.toInt())
        : await loadNetworkImage(image, imageWidth.toInt(), imageHeight.toInt());

    // ---- Shop Name Painter ----
    final shopNamePainter = TextPainter(
      text: TextSpan(
        text: shopName,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
    )..layout(maxWidth: width - 2 * sidePadding);

    // ---- Rating Painter ----
    final ratingPainter = TextPainter(
      text: TextSpan(
        text: subCategorySelected
            ? "\$${charges.replaceAll(RegExp(r"\.0+$"), "")}"
            : "⭐ $text",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),

      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
    )..layout(maxWidth: width - 2 * sidePadding);

    // ---- Total dynamic height with top & bottom padding ----
    final double contentHeight = imageHeight + spacing1 + shopNamePainter.height + spacing2 + ratingPainter.height;
    final double totalHeight = contentHeight + verticalPadding * 2;

    // Draw white rounded background
    final rect = Rect.fromLTWH(0, 0, width, totalHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);

    // ---- Draw Image ----
    final double imageX = (width - imageWidth) / 2;
    final double imageY = verticalPadding;
    final Rect imageRect = Rect.fromLTWH(imageX, imageY, imageWidth, imageHeight);
    final RRect imageRoundedRect = RRect.fromRectAndRadius(imageRect, Radius.circular(imageCornerRadius));

    canvas.save();
    canvas.clipRRect(imageRoundedRect);
    canvas.drawImageRect(
      profileImage,
      Rect.fromLTWH(0, 0, profileImage.width.toDouble(), profileImage.height.toDouble()),
      imageRect,
      Paint(),
    );
    canvas.restore();

    if (useFallback) {
      final borderPaint = Paint()
        ..color = Colors.lightGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(imageRoundedRect, borderPaint);
    }

    // ---- Draw Shop Name ----
    final double shopNameX = (width - shopNamePainter.width) / 2;
    final double shopNameY = imageRect.bottom + spacing1;
    shopNamePainter.paint(canvas, Offset(shopNameX, shopNameY));

    // ---- Draw Rating ----
    final double ratingX = (width - ratingPainter.width) / 2;
    final double ratingY = shopNameY + shopNamePainter.height + spacing2;
    ratingPainter.paint(canvas, Offset(ratingX, ratingY));

    // Final render
    final imageFinal = await recorder.endRecording().toImage(width.toInt(), totalHeight.toInt());
    final byteData = await imageFinal.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }






  Future<ui.Image> loadAssetImage(String assetPath, int width, int height) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }


  Future<ui.Image> loadNetworkImage(String url, int width, int height) async {
    final completer = Completer<ui.Image>();
    final NetworkImage networkImage = NetworkImage(url);
    final ImageStream stream = networkImage.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, _) {
      completer.complete(info.image);
    }, onError: (error, stackTrace) {
      completer.completeError(error, stackTrace);
    });
    stream.addListener(listener);
    return completer.future;
  }




  void _filterVendors() {
    if (_searchQuery.isEmpty) {
      _allVendors.assignAll(_originalVendors);
    } else {
      _allVendors = _originalVendors.where((vendor) {
        final name = vendor['shopName']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    print("after adding lat: all vendors$_allVendors");
    _updateMarkers(_allVendors); // also updates the map markers
    setState(() {});

  }


  void _applyFilters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
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
        categoryId: _selectedCategoryId!,
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

      _originalVendors.assignAll(_generalController.filteredSubcategories);
      // await _getLatLngFromAddress();
      _filterVendors();

      print('Home Visit Available: $homeVisitAvailable');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void applyLocalFilters({
    required List<dynamic> vendors,
    required String categoryId,
    required String userLat,
    required String userLong,
    String? status,
    String? homeVisit,
    String? hasSalon,
    int? minPrice,
    int? maxPrice,
    bool? onlineNow,
    bool? nearby,
    TimeOfDay? selectedTime,
    bool? isAvailableNow,
  }) {
    final now = TimeOfDay.now();

    final filtered = vendors.where((vendor) {
      final itemStatus = vendor['status']?.toLowerCase();
      final itemHomeVisit = vendor['homeServiceAvailable'] == true;
      final itemHasSalon = vendor['hasPhysicalShop'] == true;
      
      // Get minimum charge from all services
      final services = vendor['services'] as List<dynamic>?;
      int minServiceCharge = 999999;
      if (services != null && services.isNotEmpty) {
        for (var service in services) {
          final charges = int.tryParse(service['charges']?.toString() ?? '0') ?? 0;
          if (charges > 0 && charges < minServiceCharge) {
            minServiceCharge = charges;
          }
        }
      }
      if (minServiceCharge == 999999) minServiceCharge = 0;
      
      final itemOnline = itemStatus == 'online';
      final itemOpeningTime = vendor['openingTime'];

      if (status != null && itemStatus != status.toLowerCase()) return false;
      if (homeVisit == "on" && !itemHomeVisit) return false;
      if (hasSalon == "on" && !itemHasSalon) return false;
      if (minPrice != null && minServiceCharge < minPrice) return false;
      if (maxPrice != null && minServiceCharge > maxPrice) return false;
      if (onlineNow == true && !itemOnline) return false;

      if (isAvailableNow == true && itemOpeningTime is Map) {
        final openHour = int.tryParse(itemOpeningTime['hour']?.toString() ?? '0') ?? 0;
        final openMinute = int.tryParse(itemOpeningTime['minute']?.toString() ?? '0') ?? 0;
        if (now.hour < openHour || (now.hour == openHour && now.minute < openMinute)) {
          return false;
        }
      }

      if (selectedTime != null && itemOpeningTime is Map) {
        final openHour = int.tryParse(itemOpeningTime['hour']?.toString() ?? '0') ?? 0;
        final openMinute = int.tryParse(itemOpeningTime['minute']?.toString() ?? '0') ?? 0;
        if (selectedTime.hour < openHour ||
            (selectedTime.hour == openHour && selectedTime.minute < openMinute)) {
          return false;
        }
      }

      return true;
    }).toList();

    if(activeButtonIndex == 1){
      //sort by distance
      sortVendorsByDistanceNearestFirst(filtered);

    }else if(activeButtonIndex == 2){
      //sort by popularity
      sortVendorsByRatingHighFirst(filtered);

    }else if(activeButtonIndex == 3){
      //sort by rating
      sortVendorsByRatingHighFirst(filtered);

    }

    _originalVendors.assignAll(filtered);
    _filterVendors();

    print('Locally filtered vendors: ${_originalVendors.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: tabControllerInitialized? Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search shops...',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                              _filterVendors();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xffF8F8F8),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage('assets/filter1.png'),
                                scale: 3
                              // fit: BoxFit.fitWidth, // or BoxFit.contain depending on result you want
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  // SizedBox(height: 0),
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: kPrimaryColor,
                    tabs: _shopController.services.map((category) => Tab(text: category['name'])).toList(),
                  ),
                  if (controller.subcategories.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.subcategories.map((subcategory) {
                          final isSelected = _selectedSubCategoryId == subcategory['_id'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSubCategoryId = subcategory['_id'];
                                print('Selected Subcategory Name: ${subcategory['name']}');
                                print('Selected Subcategory Id: $_selectedSubCategoryId');
                                print(subcategory);
                                subCategorySelected = true;
                                // Reset all filters
                                onlineNow = false;
                                nearby = false;
                                homeVisitAvailable = false;
                                hasSalonLocation = false;
                                priceRange = const RangeValues(0, 500);
                                isAvailableNow = true;
                                selectedTime = TimeOfDay.now();

                              });
                              _applySubcategoryFilter(_selectedSubCategoryId!); // Apply filtering here if needed
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected ? kPrimaryColor : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                subcategory['name'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),


                ],
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _shopController.services.map((_) {
                  final filtered = _allVendors;
                  print("all vendorss: $_allVendors");
                  print("filtered vendors: $filtered");
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_currentPosition == null)
                          const SizedBox(
                            height: 400,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          Container(
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 14,
                              ),
                              markers: Set<Marker>.from(_markers),
                              onMapCreated: (controller) {
                                _mapController = controller;
                                _mapController!.setMapStyle(_greyMapStyle);
                                _updateMarkers(_allVendors);
                              },

                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                              },
                            ),
                          ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 210,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filtered.length,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            // optionally improve performance for large lists
                            // add cacheExtent or itemExtent if items are same width
                            itemBuilder: (context, index) {
                              final vendor = filtered[index];
                              final rating = double.tryParse(vendor['avgRating']?.toString() ?? '0') ?? 0.0;
                              final shopName = vendor['shopName'];
                              final distance = vendor['distance'];
                              final shopBanner = vendor['shopBanner'] ?? '';
                              final location = vendor['locationAddress'];
                              final status = vendor['status'];
                              final id = vendor['_id'];
                              final openingTimeRaw = vendor['openingTime'];
                              final openingTime = (openingTimeRaw == null ||
                                  (openingTimeRaw is Map && openingTimeRaw.isEmpty))
                                  ? {
                                "weekdays": {"from": "", "to": ""},
                                "weekends": {"from": "", "to": ""},
                              }
                                  : Map<String, dynamic>.from(openingTimeRaw);


                              final galleryImages =
                              vendor['gallery'] is List
                                  ? List<String>.from(vendor['gallery'])
                                  : [];

                              double ratingValue = double.tryParse(rating.toString()) ?? 0.0;
                              int indexed = ratingValue.floor();
                              int activeIndex = rating.floor()-1;
                              print("active index $activeIndex");

                              // ...extract vendor fields as you already do...

                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: SizedBox(
                                  width: cardWidth, // IMPORTANT: give a fixed width
                                  child: SaloonCardFour(
                                    distanceKm: vendor['distance'],
                                    rating: rating,
                                    imageUrl: shopBanner,
                                    shopeName: shopName,
                                    location: location,
                                    onTap: () {
                                      print("opening time: $openingTime");
                                      Get.to(() => SaloonDetailPageScreen(
                                        phoneNumber: vendor['phone'] ?? '',
                                        rating: rating,
                                        longitude: vendor['vendorLong'] ?? '',
                                        latitude: vendor["vendorLat"] ?? '',
                                        galleryImage: galleryImages,
                                        vendorId: vendor["_id"] ?? '',
                                        desc: vendor["description"] ?? '',
                                        imageUrl: vendor["shopBanner"] ?? '',
                                        location: vendor["locationAddress"] ?? '',
                                        openingTime: openingTime,
                                        shopName: vendor["shopName"] ?? '',
                                        status: vendor["status"] ?? '',
                                        title: vendor["title"] ?? '',
                                        userName: vendor["userName"] ?? '',
                                        hasPhysicalShop: vendor["hasPhysicalShop"] ?? false,
                                        homeServiceAvailable: vendor["homeServiceAvailable"] ?? false,
                                      ));
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ],
                    ),
                  );
                }).toList(),
              ),
            )

          ],
        ) : Center(
          child: CircularProgressIndicator(),
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
                            this.setState(() => activeButtonIndex = 1);
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
                            this.setState(() => activeButtonIndex = 2);
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
                            this.setState(() => activeButtonIndex = 3);
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
                    onChanged: (value) {
                      this.setState(() => onlineNow = value);
                      setState(() => onlineNow = value);
                    },
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
                    onChanged: (value) {
                      this.setState(() => homeVisitAvailable = value);
                      setState(() => homeVisitAvailable = value);
                    },
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
                    onChanged: (value) {
                      this.setState(() => hasSalonLocation = value);
                      setState(() => hasSalonLocation = value);
                    },
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
                    onChanged: (values) {
                      this.setState(() => priceRange = values);
                      setState(() => priceRange = values);
                    },
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
                            });
                            setState(() {
                              onlineNow = false;
                              nearby = false;
                              homeVisitAvailable = false;
                              hasSalonLocation = false;
                              priceRange = const RangeValues(0, 500);
                              isAvailableNow = true;
                              selectedTime = TimeOfDay.now();
                              activeButtonIndex = 0;
                            });
                            _fetchNearbyVendors(); // Load all vendors
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
                            applyLocalFilters(
                              vendors: _originalVendors,
                              categoryId: _selectedCategoryId!,
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
                              userLat: _currentPosition!.latitude.toString(),
                              userLong: _currentPosition!.longitude.toString(),

                            );
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

  void sortVendorsByRatingHighFirst(List<dynamic> fetchedVendors) {
    fetchedVendors.sort((a, b) {
      double ratingA = _toDouble(a['avgRating']);
      double ratingB = _toDouble(b['avgRating']);

      return ratingB.compareTo(ratingA); // high → low
    });
  }

  void sortVendorsByDistanceNearestFirst(List<dynamic> fetchedVendors) {
    // Calculate distance for each vendor if not already present
    for (var vendor in fetchedVendors) {
      if (vendor['distance'] == null && _currentPosition != null) {
        final lat = double.tryParse(vendor['vendorLat']?.toString() ?? '0');
        final lng = double.tryParse(vendor['vendorLong']?.toString() ?? '0');
        if (lat != null && lng != null && lat != 0 && lng != 0) {
          final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            lat,
            lng,
          ) / 1000; // Convert to km
          vendor['distance'] = distance;
        }
      }
    }
    
    fetchedVendors.sort((a, b) {
      double distanceA = _toDouble(a['distance']);
      double distanceB = _toDouble(b['distance']);

      return distanceA.compareTo(distanceB); // near → far
    });
    print("applying filter");
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
