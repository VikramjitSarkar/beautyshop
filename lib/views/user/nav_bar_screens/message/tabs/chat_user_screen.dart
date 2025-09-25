import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/chat/vendorChatConroller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserChatScreen extends StatefulWidget {
  final String chatId;
  final String vendorName;
  final String currentUser;
  final String reciverId;

  const UserChatScreen({
    super.key,
    required this.vendorName,
    required this.chatId,
    required this.currentUser,
    required this.reciverId,
  });

  @override
  State<UserChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<UserChatScreen> {
  final VendorChatController chatController = Get.put(VendorChatController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatController.setCurrentUser(widget.currentUser);
    chatController.fetchChatMessages(widget.chatId);
    chatController.initSocket(widget.chatId);

    ever(chatController.chatMessages, (_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    chatController.leaveSocket(widget.chatId);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            //  await chatController.fetchVendorChats(GlobalsVariables.userId ?? '');
            //  await chatController.vendorChats();
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vendorName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Online",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Obx(() {
                if (chatController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (chatController.chatMessages.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = chatController.chatMessages[index];
                    final isMe =
                        (msg['senderId'] ?? '').toString() ==
                        chatController.currentUserId.value;

                    final content = msg['content']?.toString() ?? '';
                    final createdAt = msg['createdAt']?.toString() ?? '';
                    final showTime = _shouldShowTime(index);

                    return Column(
                      children: [
                        if (showTime)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatDate(msg['createdAt']),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isMe ? Color(0xFFDCF8C6) : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(isMe ? 8 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      msg['content'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTime(msg['createdAt']),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: messageController,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            minLines: 1,
                            maxLines: 5, // Expand up to 5 lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: "Type a message",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final msg = messageController.text.trim();
                    if (msg.isNotEmpty) {
                      chatController.sendSocketMessage(
                        receiverId: widget.reciverId,
                        chatId: widget.chatId,
                        content: msg,
                      );
                      messageController.clear();
                      Future.delayed(const Duration(milliseconds: 80), () {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });
                    }
                  },

                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  bool _shouldShowTime(int index) {
    if (index == 0) return true;

    final currentCreatedAt = chatController.chatMessages[index]['createdAt'];
    final previousCreatedAt =
        chatController.chatMessages[index - 1]['createdAt'];

    if (currentCreatedAt == null || previousCreatedAt == null) return false;

    try {
      final currentDate = DateTime.parse(currentCreatedAt);
      final previousDate = DateTime.parse(previousCreatedAt);

      return currentDate.day != previousDate.day ||
          currentDate.month != previousDate.month ||
          currentDate.year != previousDate.year;
    } catch (e) {
      print('⚠️ Date parsing error: $e');
      return false;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "--:--";
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    } catch (e) {
      print('⚠️ Time format error: $e');
      return "--:--";
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return "Today";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        return "Yesterday";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      print('⚠️ Date format error: $e');
      return "";
    }
  }
}
