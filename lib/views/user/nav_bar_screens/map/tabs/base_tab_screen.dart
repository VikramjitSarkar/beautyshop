import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

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
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;
  List<dynamic> _allVendors = [];
  Position? _currentPosition;

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
    }
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

  void _updateMarkers(List<dynamic> vendors) async {
    _markers.clear();

    for (final vendor in vendors) {
      final lat = double.tryParse(vendor['vendorLat'] ?? '0');
      final lng = double.tryParse(vendor['vendorLong'] ?? '0');
      final imageUrl = vendor['profileImage'] ?? ''; // Update based on your key

      if (lat != null && lng != null && imageUrl.isNotEmpty) {
        final icon = await _getMarkerIconFromUrl(imageUrl);

        _markers.add(
          Marker(
            markerId: MarkerId(vendor['_id']),
            position: LatLng(lat, lng),
            icon: icon,
            infoWindow: InfoWindow(
              title: vendor['shopName'] ?? 'Vendor',
              snippet: '${vendor['distance']?.toStringAsFixed(1)} km away',
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {});
      if (_markers.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              _getBounds(_markers.map((m) => m.position).toList()),
              50.0,
            ),
          );
        });
      }
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
          child:
              _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
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
                            _getBounds(
                              _markers.map((m) => m.position).toList(),
                            ),
                            50.0,
                          ),
                        );
                      }
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
        ),
      ],
    );
  }
}
