import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return '';
    } catch (e) {
      print('Geocoding error: $e');
      return '';
    }
  }
}