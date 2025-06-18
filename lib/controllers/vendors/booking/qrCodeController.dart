import 'dart:async';
import 'dart:convert';
import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketController extends GetxController {
  late IO.Socket socket;
  bool _isConnected = false;

  String? _pendingRegisterId;
  String? _pendingRegisterType;

  bool _bookingActivatedBound = false;
  bool _bookingCompletedBound = false;

  Future<void> initSocket() async {
    if (_isConnected) return;

    print('🔌 [Socket] Connecting...');
    socket = IO.io(GlobalsVariables.baseUrlapp, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ [Socket] Connected');
      _isConnected = true;

      // Auto-register if waiting
      if (_pendingRegisterId != null && _pendingRegisterType != null) {
        socket.emit('register', {
          'id': _pendingRegisterId,
          'type': _pendingRegisterType,
        });
        print(
          '📤 [Socket] Auto-registered with id: $_pendingRegisterId as $_pendingRegisterType',
        );
      }
    });

    socket.onDisconnect((_) {
      print('❌ [Socket] Disconnected');
      _isConnected = false;
    });

    socket.onConnectError((e) => print('❌ [Socket] Connect Error: $e'));
    socket.onError((e) => print('❌ [Socket] General Error: $e'));

    socket.onAny((event, data) {
      print('📡 [Socket] Event: $event');
      print('📡 [Socket] Data: $data');
    });
  }

  Future<void> connectIfNotConnected() async {
    if (!_isConnected) {
      await initSocket();
    }
  }

  void register(String id, String type) {
    if (_isConnected) {
      socket.emit('register', {'id': id, 'type': type});
      print('📤 [Socket] Emitted register: id=$id, type=$type');
    } else {
      // Store to emit after connected
      _pendingRegisterId = id;
      _pendingRegisterType = type;

      socket.onConnect((_) {
        if (_isConnected &&
            _pendingRegisterId != null &&
            _pendingRegisterType != null) {
          socket.emit('register', {
            'id': _pendingRegisterId,
            'type': _pendingRegisterType,
          });
          print(
            '📤 [Socket] Registered on reconnect: id=$_pendingRegisterId, type=$_pendingRegisterType',
          );
        }
      });

      print(
        '⚠️ Tried to register before socket connected — deferred registration set',
      );
    }
  }

  void onBookingActivated(Function(Map<String, dynamic>) callback) {
    if (_bookingActivatedBound) return;
    _bookingActivatedBound = true;

    print('📥 [Socket] bookingActivated: Listener attached');

    socket.on('bookingActivated', (data) {
      print('📥 [Socket] bookingActivated Raw Data: $data');

      try {
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          print('✅ Parsed: $map');
          callback(map);
        } else if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            print('✅ Decoded from string: $decoded');
            callback(decoded);
          }
        } else {
          print('⚠ Unexpected format: ${data.runtimeType}');
        }
      } catch (e) {
        print('❌ Failed to handle bookingActivated: $e');
      }
    });
  }

  void onBookingCompleted(Function(Map<String, dynamic>) callback) {
    if (_bookingCompletedBound) return;
    _bookingCompletedBound = true;

    socket.on('booking-completed', (data) {
      print('📥 [Socket] booking-completed: $data');
      try {
        final parsed =
            data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);
        print('✅ booking-completed parsed: $parsed');
        callback(parsed);
      } catch (e) {
        print('❌ Error parsing booking-completed: $e');
      }
    });
  }

  Future<Map<String, dynamic>> scanQrCode(String code) async {
    final completer = Completer<Map<String, dynamic>>();

    if (!_isConnected) {
      await connectIfNotConnected(); // make sure it's ready
    }

    socket.emitWithAck(
      'scanQrCode',
      {'qrCode': code},
      ack: (response) {
        print('📤 [Socket] scanQrCode ack: $response');
        completer.complete(Map<String, dynamic>.from(response));
      },
    );

    return completer.future;
  }
}
