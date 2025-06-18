import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/Chat/userChatController.dart';
import 'package:beautician_app/controllers/vendors/chat/vendorChatConroller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/onboarding/user_vender_screen.dart';
import 'package:get/get.dart';

class UserMessageTabScreen extends StatefulWidget {
  const UserMessageTabScreen({super.key});

  @override
  State<UserMessageTabScreen> createState() => _UserMessageTabScreenState();
}

class _UserMessageTabScreenState extends State<UserMessageTabScreen> {
  final UserChatController chatController = Get.put(UserChatController());
  final String? vendorId = GlobalsVariables.userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Always fetch fresh chats when screen is shown
    chatController.fetchVendorChats(vendorId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (GlobalsVariables.token == null) {
      return Center(
        child: TextButton(
          onPressed: () {
            Get.to(() => UserVendorScreen());
          },
          child: Text(
            'Please login to see messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // 🔍 Search Field
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged:
                (value) =>
                    chatController.searchQuery.value =
                        value.trim().toLowerCase(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search user...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 📦 Chat List
        Flexible(
          child: Center(
            child: Obx(() {
              if (chatController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (chatController.errorMessage.isNotEmpty) {
                return Text(
                  'No chat available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              }

              final filteredChats =
                  chatController.vendorChats.where((chat) {
                    final otherUser = chat['other'] ?? {};
                    final name =
                        (otherUser['userName'] ?? '').toString().toLowerCase();
                    final query = chatController.searchQuery.value;
                    return name.contains(query);
                  }).toList();

              if (filteredChats.isEmpty) {
                return Center(child: Text("No users found"));
              }

              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 10,
                ),
                itemCount: filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];
                  final otherUser = chat['other'] ?? {};
                  final lastMessage = chat['lastMessage'];
                  final unreadCount = chat['unread'] ?? 0;
                  final chatId = chat['chatId'];
                  final lastMessageText =
                      lastMessage?['content'] ?? 'No messages yet';
                  final lastMessageTime =
                      lastMessage != null
                          ? _formatTime(lastMessage['createdAt'] ?? '')
                          : '--:--';

                  return GestureDetector(
                    onTap: () async {
                      await Get.to(
                        () => UserChatScreen(
                          vendorName: otherUser['userName'],
                          reciverId: chat['receiverId'],
                          chatId: chatId,
                          currentUser: chat['senderId'],
                        ),
                      );
                      // Refresh again after returning from chat
                      chatController.fetchVendorChats(vendorId ?? '');
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: kGreyColor,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherUser['userName'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  lastMessageText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kGreyColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                lastMessageTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kGreyColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              if (unreadCount > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '--:--';
    }
  }
}
