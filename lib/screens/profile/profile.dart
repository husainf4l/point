import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/components/my_textfield.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:points/controllers/messaging_controller.dart';
import 'package:points/controllers/theme_controller.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  final RxBool isEditing = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController walletNameController = TextEditingController();
  final TextEditingController walletNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userData = authController.userData.value;

    nameController.text = userData?['name'] ?? '';
    emailController.text = userData?['email'] ?? '';
    phoneController.text = userData?['phone'] ?? '';
    walletNameController.text = userData?['wallet']?['name'] ?? '';
    walletNumberController.text = userData?['wallet']?['number'] ?? '';
    Get.put(MessagingController());

    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/images/profileBanner.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "الوضع الداكن",
                ),
                Obx(() => Switch(
                      value: themeController.isDarkMode.value,
                      onChanged: (value) {
                        themeController.toggleTheme();
                      },
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "الملف الشخصي",
              style: Theme.of(context).textTheme.headlineMedium,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Column(
                children: [
                  _buildProfileField("الاسم", nameController, isEditing.value),
                  _buildProfileField(
                      "البريد الإلكتروني", emailController, isEditing.value),
                  _buildProfileField(
                      "رقم الهاتف", phoneController, isEditing.value),
                  _buildProfileField(
                      "اسم المحفظة", walletNameController, isEditing.value),
                  _buildProfileField(
                      "رقم المحفظة", walletNumberController, isEditing.value),

                  const SizedBox(height: 20),

                  const SizedBox(height: 20),

                  // Action Buttons
                  if (!isEditing.value)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            isEditing.value = true;
                          },
                          child: const Text("تعديل"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () {
                            AuthController().logout();
                          },
                          child: const Text("تسجيل خروج"),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            isEditing.value = false;
                            authController.updateUserData({
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'wallet': {
                                'name': walletNameController.text.trim(),
                                'number': walletNumberController.text.trim(),
                              },
                            });
                          },
                          child: const Text("حفظ"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            isEditing.value = false;
                          },
                          child: const Text("إلغاء"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            _showDeleteAccountDialog(context);
                          },
                          child: const Text("حذف الحساب"),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
      String label, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
          ),
          if (isEditable)
            MyTextField(
              controller: controller,
              hintText: "الاسم",
              obscureText: false,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: AutofillHints.name,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.text,
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController confirmNameController = TextEditingController();

    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText:
          "يرجى إدخال اسمك لتأكيد حذف الحساب. لا يمكن التراجع عن هذا الإجراء.",
      content: Column(
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: confirmNameController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: "أدخل اسمك",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textCancel: "إلغاء",
      textConfirm: "حذف",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (confirmNameController.text.trim() ==
            authController.userData.value?['name']) {
          authController.deleteAccount();
          Get.back(); // Close the dialog
        } else {
          Get.snackbar("خطأ", "الاسم لا يطابق. حاول مرة أخرى.",
              snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
  }
}