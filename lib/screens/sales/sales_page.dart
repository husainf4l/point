import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:points/class/point_transaction_model.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';

class AddSalesPage extends StatefulWidget {
  const AddSalesPage({super.key});

  @override
  AddSalesPageState createState() => AddSalesPageState();
}

class AddSalesPageState extends State<AddSalesPage> {
  File? _image;
  final picker = ImagePicker();
  bool isUploading = false;
  final _notesController = TextEditingController();

  /// Pick image from gallery
  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Get.snackbar(
          "خطأ",
          "لم يتم تحديد أي صورة.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  /// Upload the sale data to Firebase
  Future<void> uploadSale() async {
    if (_image == null) {
      Get.snackbar(
        "خطأ",
        "يرجى اختيار صورة أولاً.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      String userUid = authController.userData.value?["userUid"] ?? "unknown";
      String userName = authController.userData.value?["name"] ?? "unknown";
      String posName = authController.userData.value?["posName"] ?? "unknown";
      double pointBalance =
          (authController.userData.value?['pointBalance'] ?? 0).toDouble();

      final storageRef = FirebaseStorage.instance.ref().child(
          'sales/$userName-$posName/${DateTime.now().toIso8601String()}');
      UploadTask uploadTask = storageRef.putFile(_image!);

      await uploadTask;
      final imageUrl = await storageRef.getDownloadURL();

      // Create transaction instance
      PointTransaction transaction = PointTransaction(
        refId: DateTime.now().millisecondsSinceEpoch,
        userName: userName,
        notes: "طلب اضافة مبيعات \n ${_notesController.text}",
        pointBalance: pointBalance,
        points: 0,
        createdOn: DateTime.now(),
        type: "sales",
        posName: posName,
        status: "Under_process",
        userUid: userUid,
        imageUrl: imageUrl,
        isChecked: false,
        checkedBy: "",
        updatedOn: DateTime.now(),
      );

      // Add transaction to Firestore
      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transaction.toFirestoreMap());

      Get.snackbar(
        "تم بنجاح",
        "تم إرسال المبيعات بنجاح! سيتم مراجعة الطلب قريبًا.",
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed('/home'); // Navigate to home page
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء رفع المبيعات. حاول مرة أخرى.",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  /// Remove the selected image
  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: getImage,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [8, 4],
                  color: Colors.teal,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _image == null
                        ? const Icon(Icons.add_a_photo,
                            color: Colors.teal, size: 50)
                        : Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 300,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                onPressed: removeImage,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "عند تسجيل المبيعات، يرجى التأكد من توفر رقم الفاتورة وتاريخ إصدارها حتى نتمكن من معالجتها بشكل صحيح.",
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            if (isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: uploadSale,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('إرسال'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.teal,
                ),
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
