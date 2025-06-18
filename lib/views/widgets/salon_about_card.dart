import 'package:beautician_app/constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class SalonAboutCard extends StatefulWidget {
  final String vendorId;
  final String title;
  final String des;
  final String location;
  final Map<String, dynamic> openingTime;
  final String phonenumber;

  const SalonAboutCard({
    super.key,
    required this.location,
    required this.title,
    required this.openingTime,
    required this.vendorId,
    required this.des,
    required this.phonenumber,
  });

  @override
  State<SalonAboutCard> createState() => _SalonAboutCardState();
}

class _SalonAboutCardState extends State<SalonAboutCard> {
  LatLng? _locationCoordinates;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(widget.location);
      if (locations.isNotEmpty) {
        setState(() {
          _locationCoordinates = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not fetch map location")),
        );
      }
    }
  }

  Future<void> _launchDirections(LatLng coordinates) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${coordinates.latitude},${coordinates.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open directions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            widget.des,
            style: kSubheadingStyle,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGreyColor2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/timer2.png'),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opening Hours',
                            style: kHeadingStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'We are open on weekdays and weekends.',
                            style: kSubheadingStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: kGreyColor2),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Monday - Friday : ', style: kSubheadingStyle),
                    Text(
                      '${widget.openingTime['weekdays']['from']} - ${widget.openingTime['weekdays']['to']}',
                      style: kHeadingStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Saturday - Sunday: ', style: kSubheadingStyle),
                    Text(
                      '${widget.openingTime['weekends']['from']} - ${widget.openingTime['weekends']['to']}',
                      style: kHeadingStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// Google Map Container
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGreyColor2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  _locationCoordinates == null
                      ? const Center(child: Text("No location available"))
                      : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _locationCoordinates!,
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('salonLocation'),
                            position: _locationCoordinates!,
                            infoWindow: InfoWindow(title: widget.title),
                          ),
                        },
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                title: "Contact us",
                image: 'phone2',
                color: kBlackColor,
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: widget.phonenumber,
                  );
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not open dialer")),
                    );
                  }
                },
              ),
              SizedBox(width: 15),
              ActionButton(
                title: 'Get Direction',
                image: 'directions2',
                color: kPrimaryColor,
                onTap:
                    _locationCoordinates != null
                        ? () => _launchDirections(_locationCoordinates!)
                        : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Location not available"),
                            ),
                          );
                        },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.title,
    required this.image,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color == kBlackColor ? Colors.white : kBlackColor,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset('assets/$image.png'),
          ],
        ),
      ),
    );
  }
}
