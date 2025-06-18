import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/chat/vendorChatConroller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/message/tabs/vendor_chat_screen.dart';
import 'package:get/get.dart';

class VendorMessageTabScreen extends StatefulWidget {
  const VendorMessageTabScreen({super.key});

  @override
  State<VendorMessageTabScreen> createState() => _VendorMessageTabScreenState();
}

class _VendorMessageTabScreenState extends State<VendorMessageTabScreen> {
  final VendorChatController chatController = Get.put(VendorChatController());
  final String? vendorId = GlobalsVariables.vendorId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Refresh data each time this screen is shown
    chatController.fetchVendorChats(vendorId!);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (chatController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (chatController.errorMessage.isNotEmpty) {
        return Center(child: Text(chatController.errorMessage.value));
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        itemCount: chatController.vendorChats.length,
        itemBuilder: (context, index) {
          final chat = chatController.vendorChats[index];
          final otherUser = chat['other'] ?? {};
          final lastMessage = chat['lastMessage'];
          final unreadCount = chat['unread'] ?? 0;
          final chatId = chat['chatId'];

          final lastMessageText = lastMessage?['content'] ?? 'No messages yet';
          final lastMessageTime =
              lastMessage != null
                  ? _formatTime(lastMessage['createdAt'] ?? '')
                  : '--:--';

          return GestureDetector(
            onTap: () async {
              await Get.to(
                () => VendorChatScreen(
                  vendorName: otherUser['userName'],
                  reciverId: chat['receiverId'],
                  chatId: chatId,
                  currentUser: chat['senderId'],
                ),
              );
              // ✅ Refresh after returning from chat detail screen
              chatController.fetchVendorChats(vendorId!);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUser['userName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessageText,
                          style: TextStyle(fontSize: 13, color: kGreyColor),
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
                        style: TextStyle(fontSize: 12, color: kGreyColor),
                      ),
                      const SizedBox(height: 4),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
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
    });
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
