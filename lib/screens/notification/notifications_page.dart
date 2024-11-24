import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:points/controllers/notification_q.dart';
import 'package:flutter/cupertino.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationController _notificationController =
      Get.find<NotificationController>();

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
      body: Obx(() {
        if (authController.userData.value == null) {
          return const Center(child: Text("No user data available."));
        }

        return StreamBuilder(
          stream: _notificationController.getNotificationsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data!.docs;

            if (notifications.isEmpty) {
              return const Center(child: Text("No notifications yet."));
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                // Cast the notification data to a Map<String, dynamic>
                final notification = notifications[index].data();

                return ListTile(
                  title: Text(notification['title'] ?? 'No Title'),
                  subtitle: Text(notification['body'] ?? 'No Body'),
                  trailing: notification['isChecked'] == true
                      ? null
                      : const Icon(Icons.fiber_new, color: Colors.red),
                  onTap: () {
                    _notificationController.markAsRead(
                      notifications[index].id,
                      notification,
                    );
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
