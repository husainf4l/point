import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:points/components/my_textfield.dart';
import 'package:points/controllers/settings_controller.dart';

class CompleteProfilePage extends StatelessWidget {
  final SettingsController settingsController = Get.find<SettingsController>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController walletNameController = TextEditingController();
  final TextEditingController walletNumberController = TextEditingController();
  final TextEditingController posNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  CompleteProfilePage({super.key});

  Future<void> saveProfile() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'email': FirebaseAuth.instance.currentUser!.email,
        'phone': phoneController.text.trim(),
        'posName': posNameController.text,
        'wallet': {
          'name': walletNameController.text.trim(),
          'number': walletNumberController.text.trim(),
        },
        'fcmToken': "",
        'pointBalance': 20,
        'createdAt': Timestamp.now(),
        "userUid": uid,
      });

      await FirebaseFirestore.instance.collection('transactions').add({
        'refId': DateTime.now().millisecondsSinceEpoch,
        'userName': nameController.text,
        'points': 20,
        'pointBalance': 0,
        'createdOn': Timestamp.now(),
        'type': 'SALES',
        'posName': posNameController,
        'notes': 'Opening Balance',
        'walletName': walletNameController.text.trim(),
        'walletNumber': walletNumberController.text.trim(),
        'status': 'COMPLETED',
        'userUid': uid,
        'imageUrl': settingsController.settingsData['welcomesImageUrl'],
        'isChecked': true,
        'checkedBy': '',
        'updatedOn': Timestamp.now(),
      });

      Get.toNamed('/home'); // Navigate to home page after saving
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save profile. Please try again.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              MyTextField(
                controller: nameController,
                hintText: "الاسم",
                obscureText: false,
                prefixIcon: Icons.person,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: AutofillHints.name,
              ),
              MyTextField(
                controller: posNameController,
                hintText: "مكان العمل",
                obscureText: false,
                prefixIcon: Icons.business,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: AutofillHints.organizationName,
              ),
              MyTextField(
                controller: phoneController,
                hintText: "رقم الموبايل",
                obscureText: false,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: AutofillHints.telephoneNumber,
              ),
              MyTextField(
                controller: walletNameController,
                hintText: "اسم محفظة الكليك",
                obscureText: false,
                prefixIcon: Icons.account_balance_wallet,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              MyTextField(
                controller: walletNumberController,
                hintText: "رقم المحفظة",
                obscureText: false,
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text("تاكيد"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
