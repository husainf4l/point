import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:points/components/app_bar_theme.dart';

class SaleDetailsPage extends StatelessWidget {
  final String saleId;

  const SaleDetailsPage({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    final transactionRef =
        FirebaseFirestore.instance.collection('transactions').doc(saleId);

    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png', // Path to your logo image
          height: 32, // Adjust as per your logo's dimensions
          fit: BoxFit.contain,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: transactionRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
              'حدث خطأ أثناء تحميل تفاصيل المعاملة',
            ));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text(
              'لم يتم العثور على المعاملة',
            ));
          }

          final transactionData = snapshot.data!.data() as Map<String, dynamic>;

          // Parse timestamps
          DateTime? createdOn = DateTime.tryParse(transactionData['createdOn']);
          DateTime? updatedOn = DateTime.tryParse(transactionData['updatedOn']);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),

                  // Transaction Information
                  _buildDetailRow(
                      'نوع المعاملة', transactionData['type'] ?? 'غير متوفر'),
                  _buildDetailRow(
                      'رقم المرجع', transactionData['refId'].toString()),
                  _buildDetailRow(
                      'الحالة', transactionData['status'] ?? 'غير متوفر'),
                  _buildDetailRow(
                      'النقاط', transactionData['points'].toString()),
                  _buildDetailRow('رصيد النقاط',
                      transactionData['pointBalance'].toString()),

                  // Notes
                  _buildDetailRow(
                      'الملاحظات', transactionData['notes'] ?? 'غير متوفر'),

                  // Dates
                  _buildDetailRow(
                    'تاريخ الإنشاء',
                    createdOn != null
                        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(createdOn)
                        : 'غير متوفر',
                  ),
                  _buildDetailRow(
                    'آخر تحديث',
                    updatedOn != null
                        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedOn)
                        : 'غير متوفر',
                  ),
                  _buildDetailRow(
                    'تمت المراجعة',
                    transactionData['isChecked'] ? 'نعم' : 'لا',
                  ),

                  // Image
                  if (transactionData['imageUrl'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'الصورة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              transactionData['imageUrl'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'فشل تحميل الصورة',
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
