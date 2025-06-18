// import 'dart:async';
// import 'package:beautician_app/utils/libs.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;

// class BookingSocketController extends GetxController {
//   late io.Socket socket;
//   final RxBool _isConnected = false.obs;
//   final _connectionStream = StreamController<bool>.broadcast();
//   final _bookingCompletedController = StreamController<Map<String, dynamic>>.broadcast();

//   String? _id;
//   String? _type;

//   bool get isConnected => _isConnected.value;
//   Stream<bool> get connectionStream => _connectionStream.stream;
//   Stream<Map<String, dynamic>> get bookingCompletedStream => _bookingCompletedController.stream;

//   @override
//   void onInit() {
//     super.onInit();
//     initSocket();
//   }

//   Future<void> initSocket() async {
//     try {
//       socket = io.io(
//         'https://api.thebeautyshop.io',
//         io.OptionBuilder()
//             .setTransports(['websocket'])
//             .enableAutoConnect()
//             .build(),
//       );
//       _setupSocketListeners();
//     } catch (e) {
//       print('🚨 Socket init error: $e');
//       rethrow;
//     }
//   }

//   void setupIdentity({required String id, required String type}) {
//     _id = id;
//     _type = type;
//     if (_isConnected.value) {
//       socket.emit('register', {'id': _id, 'type': _type});
//       print('📡 Registered with id: $_id as $_type');
//     }
//   }

//   void _setupSocketListeners() {
//     socket.onConnect((_) {
//       _isConnected.value = true;
//       if (!_connectionStream.isClosed) _connectionStream.add(true);
//       print('✅ Socket connected');

//       if (_id != null && _type != null) {
//         socket.emit('register', {'id': _id, 'type': _type});
//         print('📡 Auto-registered with id: $_id as $_type');
//       }
//     });

//     socket.onDisconnect((_) {
//       _isConnected.value = false;
//       if (!_connectionStream.isClosed) _connectionStream.add(false);
//       print('❌ Socket disconnected');
//     });

//     socket.on('booking-completed', (data) {
//       if (data is Map && !_bookingCompletedController.isClosed) {
//         print('📦 Received booking-completed: $data');
//         _bookingCompletedController.add(Map<String, dynamic>.from(data));
//       }
//     });
//   }

//   StreamSubscription<Map<String, dynamic>> onBookingCompleted(
//       void Function(Map<String, dynamic>) callback,
//   ) {
//     return bookingCompletedStream.listen(callback);
//   }

//   void emitCompleteBooking({
//     required String bookingId,
//     required VoidCallback onSuccess,
//     required ValueChanged<String> onError,
//   }) {
//     if (!_isConnected.value) {
//       onError("Socket not connected");
//       return;
//     }

//     socket.emitWithAck(
//       'complete-booking',
//       {'bookingId': bookingId},
//       ack: (response) {
//         print("✅ ACK: $response");
//         if (response is Map && response['status'] == 'success') {
//           onSuccess();
//         } else {
//           final err = response['message'] ?? response['error'] ?? 'Unknown error';
//           onError(err.toString());
//         }
//       },
//     );
//   }

//   Future<void> disconnect() async {
//     try {
//       if (_isConnected.value) await socket.disconnect();
//     } catch (_) {}
//     if (!_connectionStream.isClosed) await _connectionStream.close();
//     if (!_bookingCompletedController.isClosed) await _bookingCompletedController.close();
//   }

//   @override
//   Future<void> onClose() async {
//     await disconnect();
//     super.onClose();
//   }
// }
