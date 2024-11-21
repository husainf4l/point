import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:points/controllers/bottom_nav_controller.dart';
import 'package:points/screens/about_us/about_us.dart';
import 'package:points/screens/history/history_page.dart';
import 'package:points/screens/mainPage/main_page.dart';
import 'package:points/screens/redem/redem_page.dart';
import 'package:points/screens/sales/sales_page.dart';
import 'package:points/screens/testApi/test_api.dart';

class Homepage extends StatelessWidget {
  final List<Widget> _pages = [
    const AddSalesPage(),
    const RedeemPage(),
    const MainPage(),
    const HistoryPage(),
    TestApi(),
  ];

  Homepage({super.key});

  Future<void> refreshUserData() async {
    // Get an instance of the AuthController
    final authController = Get.find<AuthController>();
    await authController.refreshUserData();
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavController navController = Get.put(BottomNavController());

    return Scaffold(
      body: Obx(() => _pages[navController.selectedIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: navController.selectedIndex.value,
            onTap: (index) {
              navController.changeIndex(index);
              refreshUserData();
            },
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                label: '',
              ),
            ],
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
          )),
    );
  }
}
