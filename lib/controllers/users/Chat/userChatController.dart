import 'dart:convert';

import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class UserChatController extends GetxController {
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var vendorChats = [].obs; // List of dynamic/maps
  var errorMessage = ''.obs;
  var chatMessages = [].obs;
  late IO.Socket socket;
  var currentUserId = ''.obs; // 👈 Add this line

  void setCurrentUser(String userId) {
    currentUserId.value = userId;
  }

  Future<void> fetchVendorChats(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      vendorChats.clear();

      final url = Uri.parse(
        '${GlobalsVariables.baseUrlapp}/chat/allChats/$userId',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success1') {
          vendorChats.value = List.from(data['data'] ?? []);
          if (vendorChats.isEmpty) {
            errorMessage.value = 'No chats found';
          }
        } else {
          errorMessage.value = 'Please Login ';
        }
      } else {
        errorMessage.value = 'Please Login';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Please check your internet Connectin';
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchChatMessages(String chatId) async {
    try {
      // isLoading.value = true;
      errorMessage.value = '';
      chatMessages.clear();

      var response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/chat/allMessages/$chatId'),
      );

      print('Final URL: $chatId');
      print('Response status: ${response.statusCode}');
      print('Raw response body: ${response.body}');
      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        print('data ---$data');
        if (data['status'] == 'success') {
          chatMessages.value = List<Map<String, dynamic>>.from(
            data['data'] ?? [],
          );
          print(chatMessages);
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch messages';
          Get.snackbar(
            "Error",
            errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        Get.snackbar(
          "Error",
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessagess({
    required String senderId,
    required String receiverId,
    required String chatId,
    required String content,
  }) async {
    final url = Uri.parse('${GlobalsVariables.baseUrlapp}/chat/message');
    final body = jsonEncode({
      "senderId": senderId,
      "receiverId": receiverId,
      "content": content,
      "chatId": chatId,
      "type": "text",
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Optionally add the new message locally for instant UI update
          fetchChatMessages(chatId); // refresh chat
        } else {
          Get.snackbar("Error", data['message'] ?? "Failed to send message");
        }
      } else {
        Get.snackbar("Error", "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e");
    }
  }

  void initSocket(String chatId) {
    if (socket.connected) return; // prevent multiple connections

    socket = IO.io(GlobalsVariables.baseUrlapp, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connected');

      // Register this user with type
      socket.emit('register', {'id': currentUserId.value, 'type': 'user'});

      // Join the chat room
      socket.emit('join-chat', {
        'senderId': currentUserId.value,
        'chatId': chatId,
      });
    });

    socket.on('new_message', (data) {
      print("📥 New message received: $data");

      final message = data['data'];
      if (message != null &&
          message['content'] != null &&
          message['senderId'] != null &&
          message['createdAt'] != null) {
        chatMessages.add(message);
        chatMessages.refresh();
      } else {
        print('⚠️ Invalid message structure: $message');
      }
    });

    socket.onDisconnect((_) {
      print('❌ Socket disconnected');
    });
  }

  void sendSocketMessage({
    required String receiverId,
    required String chatId,
    required String content,
  }) {
    final message = {
      "senderId": currentUserId.value,
      "receiverId": receiverId,
      "chatId": chatId,
      "type": "text",
      "content": content,
    };

    socket.emitWithAck(
      'send_message',
      message,
      ack: (response) {
        print("✅ send_message acknowledged: $response");

        final msg = response['data'];
        if (msg != null &&
            msg['content'] != null &&
            msg['createdAt'] != null &&
            msg['senderId'] != null) {
          chatMessages.add(msg);
          chatMessages.refresh();
        }
      },
    );
  }
}
