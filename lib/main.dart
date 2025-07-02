import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/booking/qrCodeController.dart';
import 'package:beautician_app/controllers/vendors/dashboard/servicesController.dart';
import 'package:beautician_app/firebase_options.dart';
import 'package:beautician_app/screens/firebaseServices.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseService.initialize();
  await GlobalsVariables.loadToken();
  Stripe.publishableKey = 'pk_test_LdzVjLW3uAsxkVjgF6WdjnXW00p4ufOVAO';
  Get.put(SocketController(), permanent: true);
  await requestUserLocationPermission(); // ✅ Request location permission
  Get.put(ServicesController(), permanent: true);
  runApp(const MyApp());
}

Future<void> requestUserLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled.");
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission denied.");
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permission permanently denied.");
    return;
  }

  print("Location permission granted.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: "Beautician App",
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}

