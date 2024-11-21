import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:points/class/point_transaction_model.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/components/wallet_info.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';

class RedeemPage extends StatefulWidget {
  const RedeemPage({super.key});

  @override
  State<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final userData = Get.find<AuthController>().userData.value;
  bool isSubmitting = false;
  int _redeemPoints = 50;

  Future<void> submitRedeemPage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      try {
        // Create an instance of PointTransaction
        PointTransaction transaction = PointTransaction(
          refId: DateTime.now().millisecondsSinceEpoch, // Unique ID
          userName: userData?['name'] ?? 'Unknown',
          points: 0, // Deduct redeem points
          createdOn: DateTime.now(),
          type: "redeem",
          pointBalance: (userData?['pointBalance'] ?? 0).toDouble(),
          posName: userData?['posName'] ?? 'Unknown',
          status: "Under_process",
          userUid: userData?['userUid'] ?? 'Unknown',
          imageUrl:
              "https://firebasestorage.googleapis.com/v0/b/pointsv1.appspot.com/o/profile%2Fnull%2Fdata%2Fuser%2F0%2Fcom.papayatrading.admin.adminpoints%2Fcache%2Fimage_picker7515151903961275661.jpg?alt=media&token=333a2c9b-6c42-4440-88d4-c39993fefc5e",
          isChecked: false,
          checkedBy: "",
          notes:
              "طلب صرف ${_redeemPoints.toString()} نقطة \n ${_notesController.text}",
          updatedOn: DateTime.now(),
        );

        // Save transaction to Firestore
        await FirebaseFirestore.instance
            .collection('transactions')
            .add(transaction.toFirestoreMap());

        setState(() {
          isSubmitting = false;
        });

        Get.snackbar(
          'تم بنجاح',
          'تم إرسال طلب الاستبدال بنجاح! سيتم مراجعته خلال 48 ساعة.',
          snackPosition: SnackPosition.TOP,
        );
        Get.offAllNamed('/home');
      } catch (e) {
        setState(() {
          isSubmitting = false;
        });
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء إرسال طلب الاستبدال. حاول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double availablePoints =
        (userData?['pointBalance'] ?? 0).toDouble(); // Ensure it's a double

    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.profile_circled,
            color: CupertinoColors.black,
          ),
          onPressed: () {
            Get.toNamed('/profile');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Information with Available Points
              WalletInfoWidget(
                userData: userData,
                availablePoints: availablePoints,
              ),

              const SizedBox(height: 24),

              // Slider or Warning Message
              if (availablePoints < 50)
                const Center(
                  child: Text(
                    "الحد الأدنى للسحب هو 50 نقطة.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "اختر النقاط المراد استبدالها",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:
                            Colors.teal, // Color of the active track
                        inactiveTrackColor:
                            Colors.grey, // Color of the inactive track
                      ),
                      child: Slider(
                        value: _redeemPoints.toDouble(),
                        min: 50.0, // The starting point for the slider
                        max: (availablePoints >= 50
                                ? (availablePoints ~/ 10) * 10
                                : 50)
                            .toDouble(), // Ensure max aligns with the nearest multiple of 10
                        divisions: ((availablePoints ~/ 10) -
                            4), // Calculate exact divisions
                        label: _redeemPoints.toString(),
                        onChanged: (value) {
                          setState(() {
                            _redeemPoints = ((value ~/ 10) * 10)
                                .toInt(); // Ensure multiples of 10
                          });
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        "نقاط الاستبدال: ${_redeemPoints.toInt()}",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.teal),
                      ),
                    ),
                    Center(
                      child: Text(
                        "JD ${_redeemPoints / 10.toInt()}",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Notes Input
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Submission Info
              const Text(
                "سيتم مراجعة الطلب خلال 48 ساعة.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Submit Button or Loader
              if (isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: availablePoints < 50 ? null : submitRedeemPage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50.0),
                    backgroundColor:
                        availablePoints < 50 ? Colors.grey : Colors.teal,
                  ),
                  child: const Text(
                    "تاكيد الطلب",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}