import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:points/controllers/notification_q.dart';

class MyCupertinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;

  MyCupertinoAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  final NotificationController notificationController =
      Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    // Check for unread notifications whenever the app bar is built

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: title,
        leading: leading ??
            IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: CupertinoColors.activeBlue,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        actions: [
          if (actions != null) ...actions!,
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.bell,
                      color: CupertinoColors.black,
                    ),
                    onPressed: () {
                      // Navigate to notification page
                      Get.toNamed('/notifications');
                    },
                  ),
                  if (notificationController.hasUnreadNotifications.value)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              )),
        ],
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            color: CupertinoColors.systemGrey4,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
