import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:points/controllers/auth_controller.dart';

class PointController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final userData = Get.find<AuthController>().userData.value;
  RxInt pointBalance = 0.obs;
  String? userUid;
  int currentBalance = 0;

  @override
  void onInit() {
    super.onInit();
    userUid = userData?['userData'];
    currentBalance = userData?['pointBalance'];
  }

  Future<void> addTransaction({
    required int points,
    required String type, // e.g., "sales" or "rewards"
    String? notes,
    String? imageUrl,
  }) async {
    if (userUid == null) return;

    try {
      await db.runTransaction((transaction) async {
        final userRef = db.collection('users').doc(userUid);
        final int newBalance = currentBalance + points;

        transaction.update(userRef, {'pointBalance': newBalance});

        final transactionRef = db.collection('transactions').doc();
        transaction.set(transactionRef, {
          'userUid': userUid,
          'points': points,
          'type': type,
          'notes': notes ?? '',
          'createdOn': FieldValue.serverTimestamp(),
          "imageUrl": imageUrl ??
              "https://firebasestorage.googleapis.com/v0/b/pointsv1.appspot.com/o/profile%2Fnull%2Fdata%2Fuser%2F0%2Fcom.papayatrading.admin.adminpoints%2Fcache%2Fimage_picker7515151903961275661.jpg?alt=media&token=333a2c9b-6c42-4440-88d4-c39993fefc5e",
          "checkedBy": '',
          "isChecked": false,
          "posName": ""
        });
      });

      pointBalance.value += points;

      userData!.update("pointBalance", (value) => pointBalance.value);

      Get.snackbar(
        "Success",
        "Transaction added and balance updated!",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to add transaction: $e");
    }
  }
}
