// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:beautician_app/utils/libs.dart';

// class VendorSocketService {
//   late IO.Socket socket;
//   bool _alreadyHandled = false;

//   VendorSocketService._privateConstructor();
//   static final VendorSocketService _instance = VendorSocketService._privateConstructor();
//   static VendorSocketService get instance => _instance;

//   void initSocket() {
//     socket = IO.io('http://89.116.39.230:4000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print('Vendor Socket Connected');
//     });

//     socket.on('bookingActivated', (data) {
//       print('Vendor Booking Activated: $data');
//       if (!_alreadyHandled) {
//         _alreadyHandled = true;

//         /// Example action:
//         Get.snackbar(
//           'Booking Activated!',
//           'A user has activated a booking.',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );

//         /// Refresh vendor booking list
//         /// (Example: Call your controller to refresh)
//         // vendorBookingController.fetchBookings();
//       }
//     });

//     socket.onDisconnect((_) => print('Vendor Socket Disconnected'));
//     socket.onError((error) => print('Vendor Socket Error: $error'));
//   }

//   void disposeSocket() {
//     socket.dispose();
//   }
// }
