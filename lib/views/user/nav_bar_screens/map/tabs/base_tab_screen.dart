import 'dart:async';
import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:beautician_app/controllers/users/auth/genralController.dart';
import 'package:beautician_app/utils/colors.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';




abstract class BaseTabScreen extends StatefulWidget {
  final String category;
  final String categoryId;
  final String searchQuery;

  const BaseTabScreen({
    super.key,
    required this.category,
    required this.categoryId,
    required this.searchQuery,
  });

  @override
  State<BaseTabScreen> createState() => _BaseTabScreenState();


}

class _BaseTabScreenState extends State<BaseTabScreen>
    with WidgetsBindingObserver {
  Future<void> _rebuildMarkersFromVendors() async {
    _markers.clear();
    if (_allVendors.isEmpty) return;
    // Prepare a single salon pin icon
    final ByteData data = await rootBundle.load('assets/icons/salon_pin.png');
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 100);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List bytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final BitmapDescriptor icon = BitmapDescriptor.fromBytes(bytes);

    for (final vendor in _allVendors) {
      final lat = double.tryParse(vendor['location']?['latitude']?.toString() ?? '') ??
          double.tryParse(vendor['latitude']?.toString() ?? '') ?? 0;
      final lng = double.tryParse(vendor['location']?['longitude']?.toString() ?? '') ??
          double.tryParse(vendor['longitude']?.toString() ?? '') ?? 0;
      if (lat == 0 && lng == 0) continue;

      final id = vendor['_id']?.toString() ?? UniqueKey().toString();
      final shopName = (vendor['shopName'] ?? 'Salon').toString();
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, lng),
          icon: icon,
          infoWindow: InfoWindow(
            title: shopName,
            onTap: () {
              Get.to(() => SalonSpecialistDetailScreen(vendorId: id));
            },
          ),
        ),
      );
    }

    // If we have a mapController and markers, fit bounds
    if (mapController != null && _markers.isNotEmpty) {
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getBounds(_markers.map((m) => m.position).toList()),
          50.0,
        ),
      );
    }
  }

  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;
  List<dynamic> _allVendors = [];
  Position? _currentPosition;
  // Search-like filter state
  final GenralController _genralController = Get.put(GenralController());
  bool onlineNow = false;
  bool homeVisitAvailable = false;
  bool hasSalonLocation = false;
  bool nearby = false;
  RangeValues priceRange = const RangeValues(0, 1000);

  void _updateMarkers(List<dynamic> vendors) async {
    _markers.clear();

    for (final vendor in vendors) {
      final lat = double.tryParse(
        (vendor['vendorLat'] ?? vendor['latitude'] ?? vendor['location']?['latitude'] ?? '0').toString(),
      );
      final lng = double.tryParse(
        (vendor['vendorLong'] ?? vendor['longitude'] ?? vendor['location']?['longitude'] ?? '0').toString(),
      );
      if (lat == null || lng == null) continue;

      // Prefer given distance, else compute from my current location
      double? distKm;
      final vDist = vendor['distance'];
      if (vDist != null && vDist.toString().isNotEmpty) {
        distKm = double.tryParse(vDist.toString());
      }
      if (distKm == null && _currentPosition != null) {
        distKm = _haversineKm(
          _currentPosition!.latitude, _currentPosition!.longitude,
          lat, lng,
        );
      }

      final icon = await _makeBubbleAvatarMarker(vendor, distKm: distKm);

      _markers.add(
        Marker(
          markerId: MarkerId((vendor['_id'] ?? UniqueKey().toString()).toString()),
          position: LatLng(lat, lng),
          icon: icon,
          anchor: const Offset(0.5, 1.0), // bottom center = pointer point
          infoWindow: const InfoWindow(), // bubble already shows info; keep empty
          zIndex: 2, // float above default pins if any
        ),
      );


    }

    if (mounted) {
      setState(() {});
      if (_markers.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              _getBounds(_markers.map((m) => m.position).toList()),
              60.0,
            ),
          );
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchNearbyVendors();


  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchNearbyVendors(); // Refresh map after returning from settings
    }
  }

  @override
  void didUpdateWidget(covariant BaseTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _filterMarkers();
      _searchVendors(widget.searchQuery);
      updateSearch(widget.searchQuery);
    }
  }

  Future<void> _applyFilters() async {
    try {
      // Ensure location ok (same as your nearby fetch)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Location services are disabled.');
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

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() => _isLoading = true);

      // 🔁 Use the same API as Search
      await _genralController.fetchFilteredsSubcategories(
        categoryId: widget.categoryId,
        status: onlineNow ? "online" : null,
        homeVisit: homeVisitAvailable ? "on" : null,
        hasSalon: hasSalonLocation ? "on" : null,
        minPrice: priceRange.start.toInt(),
        maxPrice: priceRange.end.toInt(),
        onlineNow: onlineNow,
        nearby: nearby,
        userLat: pos.latitude.toString(),
        userLong: pos.longitude.toString(),
      );

      // Update list + markers
      setState(() {
        _allVendors = _genralController.filteredSubcategories.toList();
        _error = null;
      });
      _updateMarkers(_allVendors);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Online Now
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Online Now'),
                      subtitle: const Text('Show specialists available for instant booking'),
                      value: onlineNow,
                      activeColor: Colors.white,
                      activeTrackColor: kPrimaryColor,
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      inactiveTrackColor: kGreyColor2,
                      inactiveThumbColor: Colors.white,
                      onChanged: (v) => setModalState(() => onlineNow = v),
                    ),

                    // Home Visit Available
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Home Visit Available'),
                      subtitle: const Text('Show specialists who can come to you'),
                      value: homeVisitAvailable,
                      activeColor: Colors.white,
                      activeTrackColor: kPrimaryColor,
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      inactiveTrackColor: kGreyColor2,
                      inactiveThumbColor: Colors.white,
                      onChanged: (v) => setModalState(() => homeVisitAvailable = v),
                    ),

                    // Has Salon Location
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Has Salon Location'),
                      subtitle: const Text('Specialists with their own location'),
                      value: hasSalonLocation,
                      activeColor: Colors.white,
                      activeTrackColor: kPrimaryColor,
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      inactiveTrackColor: kGreyColor2,
                      inactiveThumbColor: Colors.white,
                      onChanged: (v) => setModalState(() => hasSalonLocation = v),
                    ),

                    // Nearby
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nearby'),
                      subtitle: const Text('Show closest to you first'),
                      value: nearby,
                      activeColor: Colors.white,
                      activeTrackColor: kPrimaryColor,
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      inactiveTrackColor: kGreyColor2,
                      inactiveThumbColor: Colors.white,
                      onChanged: (v) => setModalState(() => nearby = v),
                    ),

                    const SizedBox(height: 16),

                    // Price Range
                    const Text('Price Range'),
                    RangeSlider(
                      min: 0,
                      max: 1000,
                      divisions: 50,
                      activeColor: kPrimaryColor,
                      inactiveColor: kGreyColor2,
                      labels: RangeLabels(
                        '₹${priceRange.start.toInt()}',
                        '₹${priceRange.end.toInt()}',
                      ),
                      values: priceRange,
                      onChanged: (val) => setModalState(() => priceRange = val),
                    ),


                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () { /* your reset code */ },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: kPrimaryColor, width: 1.2),
                              foregroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async { Navigator.pop(context); await _applyFilters(); },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text('Apply'),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }

  // String _priceLabel(Map v) {
  //   // Try lots of common shapes
  //   final dynamic p = v['price'];
  //   final dynamic pFrom = v['priceFrom'] ?? v['minPrice'] ?? v['startingPrice'];
  //   final dynamic pTo   = v['priceTo']   ?? v['maxPrice'];
  //   String numStr(dynamic x) {
  //     if (x == null) return '';
  //     final d = double.tryParse(x.toString());
  //     if (d == null) return '';
  //     // Round to nearest 10/1 as you prefer
  //     return d >= 1000 ? '₹${d.toStringAsFixed(0)}' : '₹${d.toStringAsFixed(0)}';
  //   }
  //
  //   // If a single price exists
  //   if (p != null && p.toString().isNotEmpty) {
  //     final s = numStr(p);
  //     return s.isEmpty ? '' : '$s+';
  //   }
  //
  //   // If a range exists
  //   final sFrom = numStr(pFrom);
  //   final sTo   = numStr(pTo);
  //   if (sFrom.isNotEmpty && sTo.isNotEmpty) return '$sFrom–$sTo';
  //   if (sFrom.isNotEmpty) return '$sFrom+';
  //   if (sTo.isNotEmpty) return '$sTo';
  //
  //   return '';
  // }

  // Future<ui.Image> _loadNetworkImage(String url, {int target = 160}) async {
  //   try {
  //     final resp = await http.get(Uri.parse(url));
  //     if (resp.statusCode != 200) {
  //       throw Exception('HTTP ${resp.statusCode}');
  //     }
  //     final bytes = resp.bodyBytes;
  //     final codec = await ui.instantiateImageCodec(bytes, targetWidth: target, targetHeight: target);
  //     final frame = await codec.getNextFrame();
  //     return frame.image;
  //   } catch (_) {
  //     // Fallback: solid color circle
  //     final recorder = ui.PictureRecorder();
  //     final canvas = Canvas(recorder);
  //     final size = 160.0;
  //     final paint = Paint()..color = const Color(0xFFECECEC);
  //     canvas.drawCircle(Offset(size/2, size/2), size/2, paint);
  //     final pic = recorder.endRecording();
  //     return await pic.toImage(size.toInt(), size.toInt());
  //   }
  // }

  // Cache to avoid rebuilding marker bitmaps repeatedly
  final Map<String, BitmapDescriptor> _markerCache = {};


  Future<BitmapDescriptor> _makeBeautifulMarker(Map vendor) async {
    // Try cache first
    final id = (vendor['_id'] ?? '').toString();
    if (_markerCache.containsKey(id)) return _markerCache[id]!;

    final String imageUrl = (vendor['profileImage'] ?? '').toString();
    final String price = _priceLabel(vendor);

    // Canvas size
    const double w = 180;
    const double h = 220;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // Shadow pin base
    final pinPath = Path();
    const double pinWidth = 110;
    const double pinHeight = 130;
    final pinRect = RRect.fromRectAndCorners(
      Rect.fromLTWH((w - pinWidth)/2, 8, pinWidth, pinHeight),
      topLeft: const Radius.circular(28),
      topRight: const Radius.circular(28),
      bottomLeft: const Radius.circular(32),
      bottomRight: const Radius.circular(32),
    );

    // Soft drop shadow
    canvas.drawShadow(Path()..addRRect(pinRect), const Color(0x55000000), 6, true);

    // Pin background (subtle gradient using your brand-ish vibe)
    final grad = ui.Gradient.linear(
      const Offset(0, 0), const Offset(0, pinHeight),
      [const Color(0xFFFBF8F1), const Color(0xFFF2EADF)],
      [0.0, 1.0],
    );
    paint.shader = grad;
    canvas.drawRRect(pinRect, paint);
    paint.shader = null;

    // Avatar circle
    final avatarSize = 96.0;
    final avatarCenter = Offset(w/2, 8 + 20 + avatarSize/2);
    final avatarRect = Rect.fromCircle(center: avatarCenter, radius: avatarSize/2);

    // Clip circle
    final clipPath = Path()..addOval(avatarRect);
    canvas.save();
    canvas.clipPath(clipPath);

    final img = await _loadNetworkImage(imageUrl, target: avatarSize.toInt());
    // Draw image fitted to circle
    final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    canvas.drawImageRect(img, srcRect, avatarRect, Paint());
    canvas.restore();

    // Thin rim around avatar
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x99FFFFFF);
    canvas.drawCircle(avatarCenter, avatarSize/2, rimPaint);

    // Pointer tail
    final tailPath = Path();
    final tailTop = 8 + pinHeight - 6;
    tailPath.moveTo(w/2 - 10, tailTop);
    tailPath.lineTo(w/2, tailTop + 18);
    tailPath.lineTo(w/2 + 10, tailTop);
    tailPath.close();
    final tailPaint = Paint()..color = const Color(0xFFF5EBDD);
    canvas.drawPath(tailPath, tailPaint);

    // Price pill
    if (price.isNotEmpty) {
      final pillLeft = (w - 120) / 2;
      final pillTop  = 8 + pinHeight - 42;
      final pillRect = RRect.fromLTRBR(
        pillLeft, pillTop, pillLeft + 120, pillTop + 32, const Radius.circular(16),
      );

      // Glass + border
      final glass = Paint()
        ..shader = ui.Gradient.linear(
          Offset(pillLeft, pillTop),
          Offset(pillLeft, pillTop + 32),
          [const Color(0x66FFFFFF), const Color(0x33FFFFFF)],
        );
      canvas.drawRRect(pillRect, glass);
      canvas.drawRRect(
        pillRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x99FFFFFF),
      );

      // Text
      final pb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
        ),
      )..pushStyle(ui.TextStyle(color: const Color(0xFF1B1B1B)))
        ..addText(price);

      final paragraph = pb.build()..layout(const ui.ParagraphConstraints(width: 120));
      canvas.drawParagraph(paragraph, Offset(pillLeft, pillTop + (32 - paragraph.height)/2));
    }

    // Finish recording
    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final icon = BitmapDescriptor.fromBytes(pngBytes);
    _markerCache[id] = icon;
    return icon;
  }

  String _priceLabel(Map v) {
    // Helper to coerce any dynamic into a double (or null)
    double? _toDouble(dynamic x) {
      if (x == null) return null;
      return double.tryParse(x.toString());
    }

    String _fmt(num? d) => d == null ? '' : '₹${d.toStringAsFixed(0)}';

    // 1) Primary source: `charges`
    final dynamic charges = v['charges'];

    // charges as a plain number or numeric string
    if (charges is num) {
      return '${_fmt(charges)}+';
    }
    if (charges is String) {
      final c = _toDouble(charges);
      if (c != null) return '${_fmt(c)}+';
    }

    // charges as a map (support various key names)
    if (charges is Map) {
      final minC = _toDouble(
          charges['min'] ??
              charges['from'] ??
              charges['low'] ??
              charges['minPrice'] ??
              charges['priceFrom']
      );
      final maxC = _toDouble(
          charges['max'] ??
              charges['to'] ??
              charges['high'] ??
              charges['maxPrice'] ??
              charges['priceTo']
      );

      if (minC != null && maxC != null) return '${_fmt(minC)}–${_fmt(maxC)}';
      if (minC != null) return '${_fmt(minC)}+';
      if (maxC != null) return _fmt(maxC);
    }

    // charges as a list (e.g., list of services with price fields)
    if (charges is List) {
      double? minP;
      double? maxP;
      for (final item in charges) {
        if (item is Map) {
          final p = _toDouble(
              item['price'] ??
                  item['charges'] ??
                  item['amount'] ??
                  item['cost']
          );
          if (p != null) {
            minP = (minP == null) ? p : (p < minP! ? p : minP);
            maxP = (maxP == null) ? p : (p > maxP! ? p : maxP);
          }
        } else {
          final p = _toDouble(item);
          if (p != null) {
            minP = (minP == null) ? p : (p < minP! ? p : minP);
            maxP = (maxP == null) ? p : (p > maxP! ? p : maxP);
          }
        }
      }
      if (minP != null && maxP != null && minP != maxP) return '${_fmt(minP)}–${_fmt(maxP)}';
      if (minP != null) return '${_fmt(minP)}+';
    }

    // 2) Fallbacks to older fields (if any exist in your data)
    final p      = _toDouble(v['price']);
    final pFrom  = _toDouble(v['priceFrom'] ?? v['minPrice'] ?? v['startingPrice']);
    final pTo    = _toDouble(v['priceTo']   ?? v['maxPrice']);

    if (p != null) return '${_fmt(p)}+';
    if (pFrom != null && pTo != null) return '${_fmt(pFrom)}–${_fmt(pTo)}';
    if (pFrom != null) return '${_fmt(pFrom)}+';
    if (pTo != null) return _fmt(pTo);

    return ''; // no price visible
  }


  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
    final dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);
    final a =
        (math.sin(dLat/2) * math.sin(dLat/2)) +
            math.cos(lat1 * (3.141592653589793 / 180.0)) *
                math.cos(lat2 * (3.141592653589793 / 180.0)) *
                (math.sin(dLon/2) * math.sin(dLon/2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  String _formatDistKm(double km) {
    if (km >= 1) return '${km.toStringAsFixed(1)} km';
    return '${(km * 1000).toStringAsFixed(0)} m';
  }


  Future<ui.Image> _loadNetworkImage(String url, {int? size, int? target}) async {
    try {
      final resp = await http.get(Uri.parse(url));
      // Decode FULL image (no targetWidth/targetHeight) to preserve the real aspect
      final codec = await ui.instantiateImageCodec(
        resp.statusCode == 200 ? resp.bodyBytes : Uint8List(0),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      // Fallback: plain gray box
      const fallback = 256;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = const Color(0xFFEAEAEA);
      canvas.drawRect(Rect.fromLTWH(0, 0, fallback.toDouble(), fallback.toDouble()), paint);
      final pic = recorder.endRecording();
      return pic.toImage(fallback, fallback);
    }
  }

  // =======================================
// Bubble + circular photo marker (like screenshot)
// =======================================
  Future<BitmapDescriptor> _makeBubbleAvatarMarker(Map vendor, {double? distKm}) async {
    // cache key (shop+rating+image)
    final id = (vendor['_id'] ?? '').toString();
    final name = (vendor['shopName'] ?? 'Salon').toString().trim();
    final rating = double.tryParse(vendor['avgRating']?.toString() ?? '') ?? 0.0;
    final imgUrl = (vendor['profileImage'] ?? '').toString();

    final cacheKey = 'bubble:$id|$name|$rating|$_dpr';
    if (_markerCache.containsKey(cacheKey)) return _markerCache[cacheKey]!;

    // ---- Layout (logical px; we draw @ _dpr for crispness) ----
    const double GAP = 8;         // gap between bubble and circle image
    const double TAIL_H = 10;     // bubble tail height
    const double BUBBLE_PAD_X = 14;
    const double BUBBLE_PAD_Y = 10;
    const double BUBBLE_R = 16;   // bubble radius

    const double AVATAR_R = 26;   // inner image radius
    const double AVATAR_RING = 4; // white ring thickness
    final double avatarDiameter = (AVATAR_R + AVATAR_RING) * 2;

    // We'll first measure the text to decide bubble width
    ui.Paragraph _line(String text, double size, {double maxWidth = 240}) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontFamily: 'Manrope', // make sure Manrope is bundled in pubspec for canvas text
        fontSize: size,
        maxLines: 1,
        ellipsis: '…',
        textAlign: TextAlign.left,
      ))..pushStyle(ui.TextStyle(color: const Color(0xFF1B1B1B)));
      pb.addText(text);
      final p = pb.build();
      p.layout(ui.ParagraphConstraints(width: maxWidth));
      return p;
    }

    // Compose "Shop Name   ⭐ 4.0"
    final ratingText = rating > 0 ? '  ⭐  ${rating.toStringAsFixed(1)}' : '';
    final titlePara  = _line('$name$ratingText', 16);

    final double bubbleW = titlePara.maxIntrinsicWidth + (BUBBLE_PAD_X * 2);
    final double bubbleH = titlePara.height + (BUBBLE_PAD_Y * 2);

    // total marker size
    final double W = math.max(bubbleW, avatarDiameter) + 4; // a hair extra
    final double H = bubbleH + TAIL_H + GAP + avatarDiameter;

    // ------- Start drawing @ device pixel ratio -------
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(_dpr);
    final paint = Paint()..isAntiAlias = true;

    // Center bubble horizontally
    final double bubbleLeft = (W - bubbleW) / 2;
    final double bubbleTop = 0;

    // Bubble rect
    final RRect bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleLeft, bubbleTop, bubbleW, bubbleH),
      const Radius.circular(BUBBLE_R),
    );

    // Bubble background (white) + soft shadow
    canvas.drawShadow(Path()..addRRect(bubbleRect), const Color(0x40000000), 6, true);
    canvas.drawRRect(bubbleRect, Paint()..color = const Color(0xFFFFFFFF));

    // Bubble border (subtle) – adjust color if you want project green here
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x19000000),
    );

    // Tail (little triangle)
    final double tailX = W / 2;
    final Path tail = Path()
      ..moveTo(tailX - 8, bubbleTop + bubbleH)
      ..lineTo(tailX, bubbleTop + bubbleH + TAIL_H)
      ..lineTo(tailX + 8, bubbleTop + bubbleH)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(
      tail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x19000000),
    );

    // Title text inside bubble (Manrope, no weight)
    canvas.drawParagraph(
      titlePara,
      Offset(bubbleLeft + BUBBLE_PAD_X, bubbleTop + (bubbleH - titlePara.height) / 2),
    );

    // -------- Circular photo beneath bubble --------
    final double avatarCx = W / 2;
    final double avatarCy = bubbleH + TAIL_H + GAP + avatarDiameter / 2;

    // outer soft shadow
    canvas.drawCircle(Offset(avatarCx, avatarCy), AVATAR_R + AVATAR_RING,
        Paint()..color = const Color(0x14000000));

    // white ring
    canvas.drawCircle(Offset(avatarCx, avatarCy), AVATAR_R + AVATAR_RING,
        Paint()..color = const Color(0xFFFFFFFF));

    // clip to inner circle and draw COVER image
    final img = await _loadNetworkImage(imgUrl, size: (AVATAR_R * 2).toInt(), target: (AVATAR_R * 2).toInt());

    // compute cover source rect (no stretching, no gaps)
    Rect _coverSrc(double tw, double th, double iw, double ih) {
      final targetRatio = tw / th;
      final imageRatio = iw / ih;
      if (imageRatio > targetRatio) {
        final newW = ih * targetRatio;
        final x = (iw - newW) / 2;
        return Rect.fromLTWH(x, 0, newW, ih);
      } else {
        final newH = iw / targetRatio;
        final y = (ih - newH) / 2;
        return Rect.fromLTWH(0, y, iw, newH);
      }
    }

    final double targetSide = AVATAR_R * 2;
    final Rect src = _coverSrc(targetSide, targetSide, img.width.toDouble(), img.height.toDouble());
    final Rect dst = Rect.fromCenter(center: Offset(avatarCx, avatarCy), width: targetSide, height: targetSide);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(avatarCx, avatarCy), radius: AVATAR_R)));
    canvas.drawImageRect(img, src, dst, Paint());
    canvas.restore();

    // export
    final pic = recorder.endRecording();
    final uiImage = await pic.toImage((W * _dpr).toInt(), (H * _dpr).toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final bmp = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());

    _markerCache[cacheKey] = bmp;
    return bmp;
  }



  Future<BitmapDescriptor> _makeRectMarker(Map vendor, {double? distKm}) async {
    final id = (vendor['_id'] ?? '').toString();
    final price = _priceLabel(vendor);
    final distText = distKm != null ? _formatDistKm(distKm) : '';
    final shopName = (vendor['shopName'] ?? '').toString().trim();

    final cacheKey = '$id|$price|$distText|$_dpr';
    if (_markerCache.containsKey(cacheKey)) return _markerCache[cacheKey]!;

    // Logical sizes (these feel good on map). We’ll draw at DPR-scaled canvas.
    const double W = 100;     // card width
    const double H = 100;     // image/card height
    const double CAP = 44;    // caption height (text below)
    const double r = 14;      // corner radius
    const double pad = 5;    // padding
    const double imgSide = 60;// square image
    const double tailH = 16;  // pointer height under caption

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // draw at higher resolution for crispness
    canvas.scale(_dpr);

    final paint = Paint()..isAntiAlias = true;

    // ----- Card (image area) -----
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, W, H), Radius.circular(r),
    );

    // soft shadow
    canvas.drawShadow(Path()..addRRect(bodyRect), const Color(0x55000000), 6, true);

    // background
    paint.shader = ui.Gradient.linear(
      const Offset(0, 0), const Offset(0, H),
      [const Color(0xFFFFFFFF), const Color(0xFFF7F3EA)],
    );
    canvas.drawRRect(bodyRect, paint);
    paint.shader = null;

    // GREEN border for card
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kPrimaryColor,
    );

    // ----- Image (left) with rounded rect + green border, COVER (no stretch) -----
    final double imgLeft = pad;
    final double imgTop = (H - imgSide) / 2;
    final imgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(imgLeft, imgTop, imgSide, imgSide), const Radius.circular(12),
    );

    canvas.save();
    canvas.clipRRect(imgRRect, doAntiAlias: true);

    final imgUrl = (vendor['profileImage'] ?? '').toString();
    final avatar = await _loadNetworkImage(imgUrl, size: imgSide.toInt(), target: imgSide.toInt());

    Rect _coverSrc() {
      final iw = avatar.width.toDouble();
      final ih = avatar.height.toDouble();
      final tr = imgSide / imgSide; // 1.0
      final ir = iw / ih;
      if (ir > tr) {
        final newW = ih * tr;
        final x = (iw - newW) / 2;
        return Rect.fromLTWH(x, 0, newW, ih);
      } else {
        final newH = iw / tr;
        final y = (ih - newH) / 2;
        return Rect.fromLTWH(0, y, iw, newH);
      }
    }

    final src = _coverSrc();
    final dst = Rect.fromLTWH(imgLeft, imgTop, imgSide, imgSide);
    canvas.drawImageRect(avatar, src, dst, Paint());
    canvas.restore();

    // green border around image
    canvas.drawRRect(
      imgRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kPrimaryColor,
    );

    // ----- Caption (below the card) -----
    final captionTop = H;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, captionTop, W, CAP), const Radius.circular(12),
    );

    canvas.drawRRect(capRect, Paint()..color = const Color(0xFFFDFBF7));
    canvas.drawRRect(
      capRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kPrimaryColor,
    );

    // Paragraph builder helper — Manrope, no weight
    ui.Paragraph _para(String text, double size, ui.TextAlign align, int maxLines) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontFamily: 'Manrope', // Ensure Manrope is bundled in pubspec for canvas text.
        fontSize: size,
        textAlign: align,
        maxLines: maxLines,
        ellipsis: '…',
      ))..pushStyle(ui.TextStyle(color: const Color(0xFF1B1B1B)));
      pb.addText(text);
      final p = pb.build();
      p.layout(const ui.ParagraphConstraints(width: W - pad * 2));
      return p;
    }

    // First line: shop name (trimmed)
    final nameText = (shopName.isNotEmpty ? shopName : 'Salon');
    final namePara = _para(nameText, 14, ui.TextAlign.left, 1);
    canvas.drawParagraph(namePara, Offset(pad, captionTop + 6));

    // Second line: price + • + distance (if available)
    final second = [
      if (price.isNotEmpty) price,
      if (distText.isNotEmpty) distText,
    ].join(' • ');
    final metaPara = _para(second.isNotEmpty ? second : '—', 12, ui.TextAlign.left, 1);
    canvas.drawParagraph(metaPara, Offset(pad, captionTop + 6 + namePara.height + 2));

    // ----- Pointer tail (under caption) -----
    final totalH = H + CAP;
    final tailPath = Path()
      ..moveTo(W / 2 - 9, totalH)
      ..lineTo(W / 2, totalH + tailH)
      ..lineTo(W / 2 + 9, totalH)
      ..close();

    canvas.drawPath(tailPath, Paint()..color = const Color(0xFFFDFBF7));
    canvas.drawPath(
      tailPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kPrimaryColor,
    );

    // Export at DPR-scaled size
    final pic = recorder.endRecording();
    final img = await pic.toImage((W * _dpr).toInt(), ((totalH + tailH) * _dpr).toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final bmp = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());

    _markerCache[cacheKey] = bmp;
    return bmp;
  }




  Future<void> _searchVendors(String query) async {
    // If empty, show the full nearby/all list again
    if (query.trim().isEmpty) {
      _updateMarkers(_allVendors);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // include user location if available (so server can sort by distance)
      final lat = _currentPosition?.latitude;
      final lng = _currentPosition?.longitude;

      final url = Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/search');
      final body = {
        'categoryId': widget.categoryId,
        'query': query.trim(),
        if (lat != null) 'userLat': lat.toString(),
        if (lng != null) 'userLong': lng.toString(),
      };

      // print the API call (requirement #6)
      print('POST $url');
      print('REQ_HEADERS: {Authorization: Bearer ${GlobalsVariables.token}, Content-Type: application/json}');
      print('REQ_BODY: ${json.encode(body)}');

      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('RESP_STATUS: ${resp.statusCode}');
      print('RESP_BODY: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['status'] == 'success') {
          final List<dynamic> result = (data['data'] as List?) ?? [];
          setState(() => _allVendors = result);
          _updateMarkers(_allVendors);

          // 👇 Auto-fit the results on the map
          if (mounted && _markers.isNotEmpty && mapController != null) {
            mapController.animateCamera(
              CameraUpdate.newLatLngBounds(
                _getBounds(_markers.map((m) => m.position).toList()),
                60.0,
              ),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Search failed');
        }
      } else {
        throw Exception('HTTP ${resp.statusCode}');
      }

    } catch (e) {
      setState(() => _error = 'Search error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }




  late double _dpr = 2.0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = MediaQuery.of(context).devicePixelRatio; // 1.0–4.0 typically
  }

  Future<void> _fetchNearbyVendors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are still disabled.');
        }
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. Please enable it in app settings.',
        );
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position; // ✅ store current position
      double lat = position.latitude;
      double lng = position.longitude;

      final response = await http.post(
        Uri.parse('${GlobalsVariables.baseUrlapp}/vendor/nearby'),
        headers: {
          'Authorization': 'Bearer ${GlobalsVariables.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userLat': lat.toString(),
          'userLong': lng.toString(),
          'categoryId': widget.categoryId,
        }),
      );
      print('Category ID: ${widget.categoryId}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _allVendors = data['data'];
          _updateMarkers(_allVendors);
          print("vendors: $_allVendors");
        } else {
          throw Exception(data['message'] ?? 'Failed to load vendors');
        }
      } else {
        // throw Exception('HTTP ${response.statusCode}');
      }
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

  void _filterMarkers() {
    if (widget.searchQuery.isEmpty) {
      _updateMarkers(_allVendors);
      return;
    }

    final filteredVendors =
    _allVendors.where((vendor) {
      final shopName = vendor['shopName']?.toString().toLowerCase() ?? '';
      return shopName.contains(widget.searchQuery.toLowerCase());
    }).toList();

    _updateMarkers(filteredVendors);
  }

  Future<BitmapDescriptor> _getMarkerIconFromUrl(String url) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        final ui.Codec codec = await ui.instantiateImageCodec(
          imageBytes,
          targetWidth: 100,
          targetHeight: 100,
        );
        final ui.FrameInfo frame = await codec.getNextFrame();
        final ui.Image image = frame.image;

        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);
        final Paint paint = Paint()..isAntiAlias = true;

        const double size = 100;
        final Rect rect = Rect.fromLTWH(0, 0, size, size);
        final RRect rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(size / 2),
        );
        canvas.clipRRect(rrect); // Clip to circle

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          rect,
          paint,
        );

        final ui.Image circularImage = await recorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );

        final ByteData? byteData = await circularImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        final Uint8List pngBytes = byteData!.buffer.asUint8List();

        return BitmapDescriptor.fromBytes(pngBytes);
      } else {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }
    } catch (e) {
      print("❌ Marker image error: $e");
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }





  LatLngBounds _getBounds(List<LatLng> points) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in points) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }


  // Debounce for typing
  Timer? _searchDebounce;

// Call this from parent or wherever your search text changes
  void updateSearch(String q) {
    // If the value is same as current widget.searchQuery, still allow a refresh
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(q.trim());
    });
  }

// Internal: decides between empty vs server search
  Future<void> _runSearch(String q) async {
    if (!mounted) return;

    if (q.isEmpty) {
      // restore original list + markers
      _updateMarkers(_allVendors);
      // keep camera sane
      if (_markers.isNotEmpty && mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getBounds(_markers.map((m) => m.position).toList()),
            60.0,
          ),
        );
      }
      return;
    }

    await _searchVendors(q);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        if (_markers.isEmpty && !_isLoading && _error == null)
          Center(
            child: Text(
              widget.searchQuery.isEmpty
                  ? 'No vendors found in this category'
                  : 'No vendors match your search',
            ),
          ),
        Expanded(
          child: _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [
              GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                },

                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 14,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  mapController = controller;
                  if (!_isLoading && _markers.isNotEmpty) {
                    controller.animateCamera(
                      CameraUpdate.newLatLngBounds(
                        _getBounds(_markers.map((m) => m.position).toList()),
                        50.0,
                      ),
                    );
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),

              // Top-right filter button (matches app style; just a trigger)
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _showFilterBottomSheet,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.tune),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),


        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 200,

          width: double.maxFinite,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _allVendors.length,
            itemBuilder: (context, index){

              final double rating = double.tryParse(_allVendors[index]['avgRating']?.toString() ?? '') ?? 0.0;
              final shopName = _allVendors[index]['shopName'];
              final distance = _allVendors[index]['distance']; // keep as dynamic; format via helper
              final id = _allVendors[index]['_id'];

              String _formatDistance(dynamic d) {
                final v = double.tryParse(d?.toString() ?? '');
                if (v == null) return '';
                if (v >= 1) return '${v.toStringAsFixed(1)} km';
                return '${(v * 1000).toStringAsFixed(0)} m';
              }


              if(_allVendors.isEmpty){
                return Center(child: Text("No Vendors found", style: TextStyle(color: Colors.black),),);
              }
              return GestureDetector(
                onTap: (){
                  Get.to(()=> SalonSpecialistDetailScreen(vendorId: id));

                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: SizedBox(
                    width: 150,
                    height: 150, // image height; overall card grows a bit because of overlay
                    child: Stack(
                      children: [
                        // IMAGE
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            border: _allVendors[index]['profileImage'].toString().isNotEmpty
                                ? null
                                : Border.all(color: Colors.lightGreen, width: 0.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: (_allVendors[index]['profileImage'].toString().isNotEmpty)
                                ? Image.network(
                              _allVendors[index]['profileImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Image.asset('assets/app icon 2.png', fit: BoxFit.cover),
                            )
                                : Image.asset('assets/app icon 2.png', fit: BoxFit.cover),
                          ),
                        ),

                        // GOLDEN MATTE GLASS FOOTER
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x66E3DFD5), // pale gold
                                      Color(0x33FFFFFF), // gold
                                    ],
                                  ),
                                  border: Border.all(color: const Color(0x99FFFFFF), width: 0.6),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Rating row
                                    Row(
                                      children: [
                                        for (int i = 1; i <= 5; i++)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 3),
                                            child: Image.asset(
                                              i <= rating ? 'assets/star.png' : 'assets/star2.png',
                                              height: 14,
                                            ),
                                          ),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: GoogleFonts.manrope(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Shop name
                                    Text(
                                      shopName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    // Distance
                                    Text(
                                      "${_formatDistance(distance)} away",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              );
            },
          ),
        )
      ],
    );
  }
}
