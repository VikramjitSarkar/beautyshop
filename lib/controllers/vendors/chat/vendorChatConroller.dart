import 'dart:convert';
import 'dart:io' as IO;
import 'package:beautician_app/constants/globals.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VendorChatController extends GetxController {
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var vendorChats = [].obs;
  var errorMessage = ''.obs;
  var chatMessages = [].obs;
  var currentUserId = ''.obs;
  static const String baseUrl = '${GlobalsVariables.baseUrlapp}';
  late IO.Socket socket;

  void setCurrentUser(String userId) {
    currentUserId.value = userId;
  }

  Future<void> fetchVendorChats(String vendorId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      vendorChats.clear();

      final url = Uri.parse('$baseUrl/chat/vendorChats/$vendorId');
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          vendorChats.value = List.from(data['data'] ?? []);
          if (vendorChats.isEmpty) errorMessage.value = 'No chats found';
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch chats';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchChatMessages(String chatId) async {
    try {
      errorMessage.value = '';
      chatMessages.clear();

      final response = await http.get(
        Uri.parse('$baseUrl/chat/allMessages/$chatId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          chatMessages.value = List<Map<String, dynamic>>.from(
            data['data'] ?? [],
          );
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

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String chatId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/chat/message');
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
          fetchChatMessages(chatId);
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
    socket = IO.io(GlobalsVariables.baseUrlapp, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connected');

      // Register the vendor or user
      socket.emit('register', {
        'id': currentUserId.value, // this should be vendorId or userId
        'type': 'vendor', // or 'user' depending on your role
      });

      // Join the chat
      socket.emitWithAck(
        'join-chat',
        {'senderId': currentUserId.value, 'chatId': chatId},
        ack: (response) {
          print('✅ Joined chat room response: $response');
        },
      );
    });

    socket.on('new_message', (data) {
      print("📥 Received new_message: $data");

      final message = data['data'];
      if (message is Map &&
          message['senderId'] != null &&
          message['content'] != null &&
          message['createdAt'] != null) {
        chatMessages.add(message);
        chatMessages.refresh();
      }
    });

    socket.onDisconnect((_) => print('❌ Socket disconnected'));
  }

  void leaveSocket(String chatId) {
    socket.emitWithAck(
      'leave-chat',
      {'senderId': currentUserId.value, 'chatId': chatId},
      ack: (response) {
        print("🔴 leave-chat acknowledged: $response");
      },
    );
    socket.dispose();
  }

  void sendSocketMessage({
    required String receiverId,
    required String chatId,
    required String content,
  }) {
    socket.emitWithAck(
      'send_message',
      {
        "senderId": currentUserId.value,
        "receiverId": receiverId,
        "chatId": chatId,
        "type": "text",
        "content": content,
      },
      ack: (response) {
        print("✅ Message sent response: $response");

        final data = response['data'];
        if (data != null) {
          chatMessages.add(data);
          chatMessages.refresh();
        }
      },
    );
  }
}
