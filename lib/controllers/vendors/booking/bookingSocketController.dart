// import 'package:beautician_app/utils/libs.dart';

// class UserSideBookingSocketController extends GetxController {
//   late IO.Socket socket;

//   @override
//   void onInit() {
//     super.onInit();
//     socket = IO.io('http://89.116.39.230:4000/', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket.connect();
//   }

//   void onBookingCompleted(VoidCallback callback) {
//     socket.on('booking-completed', (_) {
//       callback();
//     });
//   }
// }
