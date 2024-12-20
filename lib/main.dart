import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:points/controllers/local_notification.dart';
import 'package:points/controllers/messaging_controller.dart';
import 'package:points/controllers/settings_controller.dart';
import 'package:points/controllers/theme_controller.dart';
import 'package:points/screens/auth/auth_checker.dart';
import 'package:points/screens/auth/complete_profile_page.dart';
import 'package:points/screens/blog/blog_page.dart';
import 'package:points/screens/home_page.dart';
import 'package:points/screens/auth/login_page.dart';
import 'package:points/screens/notification/notifications_page.dart';
import 'package:points/screens/products/product_details.dart';
import 'package:points/screens/products/brand_products.dart';
import 'package:points/screens/profile/profile.dart';
import 'package:points/theme/theme.dart';
import 'firebase_options.dart';
import 'package:points/controllers/notification_q.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  await GetStorage.init();
  Get.put(MessagingController());
  setupForegroundNotification();
  await createNotificationChannel();

  FirebaseMessaging.onBackgroundMessage(
      MessagingController.firebaseMessagingBackgroundHandler);

  Get.lazyPut<NotificationController>(() => NotificationController());
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.playIntegrity, // Use debug during development
  );
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SettingsController());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          textDirection: TextDirection.rtl,
          debugShowCheckedModeBanner: false,
          theme: themeController.isDarkMode.value
              ? AppThemes.darkTheme
              : AppThemes.lightTheme,
          initialRoute: '/authChecker',
          getPages: [
            GetPage(name: '/authChecker', page: () => const AuthChecker()),
            GetPage(name: '/auth', page: () => LoginPage()),
            GetPage(
                name: '/completeProfile', page: () => CompleteProfilePage()),
            GetPage(name: '/home', page: () => Homepage()),
            GetPage(name: '/profile', page: () => Profile()),
            GetPage(name: '/blogs', page: () => BlogPage()),
            GetPage(name: '/notifications', page: () => NotificationsPage()),
            GetPage(
              name: '/products',
              page: () => BrandProductsPage(),
            ),
            GetPage(
                name: '/productDetails',
                page: () => const ProductDetailsPage()),
          ],
        ));
  }
}
