// // vendor_qr_view_controller.dart
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class VendorQrViewController extends GetxController {
//   late IO.Socket socket;
//   var bookingActivated = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _connectSocket();
//   }

//   void _connectSocket() {
//     socket = IO.io('http://89.116.39.230:4000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print('✅ Vendor Socket connected');
//     });

//     socket.onAny((event, data) {
//       print('🔥 Event received: $event');
//       print('🔥 Data received: $data');
//     });

//     socket.on('bookingActivated', (data) {
//       print('📩 Vendor received bookingActivated: $data');
//       bookingActivated.value = true;
//     });

//     socket.onDisconnect((_) => print('⚡ Vendor Socket disconnected'));
//     socket.onError((err) => print('❗ Vendor Socket error: $err'));
//   }

//   @override
//   void onClose() {
//     socket.dispose();
//     super.onClose();
//   }
// }
