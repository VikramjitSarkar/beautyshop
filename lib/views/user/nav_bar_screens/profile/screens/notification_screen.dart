import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/users/profile/notificationController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/screens/notifications_details.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  final UserNotificationController notificationController = Get.put(
    UserNotificationController(),
  );

  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with actual user ID
    notificationController.fetchNotifications(GlobalsVariables.userId!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                ),
              ],
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        child: Obx(() {
          if (notificationController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notificationController.notifications.isEmpty) {
            return const Center(child: Text("No notifications available"));
          }

          final all = notificationController.notifications;
          final now = DateTime.now();

          final newNotifications =
              all.where((n) {
                final createdAt =
                    DateTime.tryParse(n['createdAt'] ?? '') ?? now;
                return now.difference(createdAt).inHours < 24;
              }).toList();

          final earlierNotifications =
              all.where((n) {
                final createdAt =
                    DateTime.tryParse(n['createdAt'] ?? '') ?? now;
                return now.difference(createdAt).inHours >= 24;
              }).toList();

          return ListView(
            children: [
              if (newNotifications.isNotEmpty) ...[
                const Text(
                  "New",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: newNotifications.length,
                  itemBuilder: (context, index) {
                    final item = newNotifications[index];
                    return GestureDetector(
                      onTap: () {
                        print("object");
                        Get.to(
                          () => NotificationDetailScreen(
                            notification: item,
                            bookingId: item['reference'] ?? '',
                          ),
                        );
                      },
                      child: _buildListTile(item),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
              if (earlierNotifications.isNotEmpty) ...[
                const Text(
                  "Earlier",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: earlierNotifications.length,
                  itemBuilder: (context, index) {
                    final item = earlierNotifications[index];
                    return GestureDetector(
                      onTap: (){
                        Get.to(
                              () => NotificationDetailScreen(
                            notification: item,
                            bookingId: item['reference'] ?? '',
                          ),
                        );
                      },
                      child: _buildListTile(item));
                  },
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(width: 1),
        ),
        child:
            item["shopName"] == ''
                ? Icon(Icons.person)
                : ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(item["shopBanner"], fit: BoxFit.cover),
                ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item["shopName"] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            _formatTime(item["createdAt"]),
            style: TextStyle(color: kGreyColor, fontSize: 14),
          ),
        ],
      ),
      subtitle: Text(
        item["body"] ?? '',
        style: TextStyle(color: kGreyColor, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final dateTime = DateTime.tryParse(isoTime);
    if (dateTime == null) return '';
    final time = TimeOfDay.fromDateTime(dateTime);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${hour}:${time.minute.toString().padLeft(2, '0')} $period";
  }
}
