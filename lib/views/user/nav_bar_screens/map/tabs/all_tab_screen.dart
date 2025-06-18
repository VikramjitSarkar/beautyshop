// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:get/get.dart';

// Future<void> addLocation() async {
//   // 1. Check and request location permissions
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // showToast("Please enable location services");
//     return;
//   }

//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // showToast("Location permissions are denied");
//       return;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     // showToast(
//     //     "Location permissions are permanently denied, please enable them in app settings");
//     // Optionally open app settings
//     // await openAppSettings();
//     return;
//   }

//   // 2. Get current position
//   Position currentPosition;
//   try {
//     currentPosition = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.best,
//     );
//   } catch (e) {
//     // showToast("Failed to get current location: ${e.toString()}");
//     return;
//   }

//   LatLng currentLatLng =
//       LatLng(currentPosition.latitude, currentPosition.longitude);

//   // 3. Get initial address
//   String initialAddress = "Fetching address...";
//   try {
//     List<Placemark> places = await placemarkFromCoordinates(
//       currentLatLng.latitude,
//       currentLatLng.longitude,
//     );
//     if (places.isNotEmpty) {
//       Placemark place = places.first;
//       initialAddress =
//           "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
//     }
//   } catch (e) {
//     debugPrint("Geocoding error: $e");
//   }

//   // 4. Setup dialog controllers
//   final TextEditingController addressController =
//       TextEditingController(text: initialAddress);
//   LatLng pickedLocation = currentLatLng;
//   GoogleMapController? mapController;

//   // 5. Show location picker dialog
//   await Get.dialog(
//     AlertDialog(
//       title: Text("Add Location",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: 250,
//               width: double.maxFinite,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: currentLatLng,
//                       zoom: 16,
//                     ),
//                     onMapCreated: (controller) => mapController = controller,
//                     onCameraMove: (position) =>
//                         pickedLocation = position.target,
//                     onCameraIdle: () async {
//                       try {
//                         List<Placemark> places = await placemarkFromCoordinates(
//                           pickedLocation.latitude,
//                           pickedLocation.longitude,
//                         );
//                         if (places.isNotEmpty) {
//                           Placemark place = places.first;
//                           addressController.text =
//                               "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
//                         }
//                       } catch (e) {
//                         debugPrint("Geocoding error on move: $e");
//                         addressController.text = "Unable to get address";
//                       }
//                     },
//                     myLocationEnabled: true,
//                     myLocationButtonEnabled: true,
//                     zoomControlsEnabled: false,
//                   ),
//                   const Icon(Icons.location_pin, size: 40, color: Colors.red),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: addressController,
//               decoration: InputDecoration(
//                 labelText: "Address",
//                 border: OutlineInputBorder(),
//                 filled: true,
//               ),
//               maxLines: 3,
//               readOnly: true,
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (addressController.text.isEmpty ||
//                 addressController.text == "Unable to get address") {
//               // showToast("Please select a valid location");
//               return;
//             }

//             // Save the selected location
//             // You can access:
//             // - pickedLocation (LatLng with latitude/longitude)
//             // - addressController.text (full address)

//             Get.back(result: {
//               'latitude': pickedLocation.latitude,
//               'longitude': pickedLocation.longitude,
//               'address': addressController.text,
//             });
//           },
//           child: Text("Confirm Location"),
//         ),
//       ],
//     ),
//     barrierDismissible: false,
//   );
// }

// // Usage example:
// // final result = await addLocation();
// // if (result != null) {
// //   // Handle the selected location
// //   double lat = result['latitude'];
// //   double lng = result['longitude'];
// //   String address = result['address'];
// // }
