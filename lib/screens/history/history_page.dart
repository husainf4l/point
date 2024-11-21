import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:points/components/app_bar_theme.dart';
import 'package:points/controllers/auth_controller.dart';
import 'sales_details_page.dart';
import 'package:flutter/cupertino.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final userData = Get.find<AuthController>().userData.value;

  DateTimeRange selectedDateRange = DateTimeRange(
    start:
        DateTime.now().subtract(const Duration(days: 30)), // Default start date
    end: DateTime.now(), // Default end date
  );

  // Function to filter sales by date range

  @override
  Widget build(BuildContext context) {
    final salesStream = FirebaseFirestore.instance
        .collection('transactions')
        .where('userUid', isEqualTo: userData?['userUid'])
        .orderBy('createdOn', descending: true)
        .snapshots();

    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png', // Path to your logo image
          height: 32, // Adjust as per your logo's dimensions
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: salesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            var salesDocs = snapshot.data!.docs.toList();
            if (salesDocs.isEmpty) {
              return const Center(
                  child: Text('No sales found for the selected date  range'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemCount: salesDocs.length,
                itemBuilder: (context, index) {
                  var sale = salesDocs[index];

                  // Parse the 'createdOn' field
                  var createdOn = sale['createdOn'];

                  DateTime? date;

                  // Check if 'createdOn' is a Firestore Timestamp or a string
                  if (createdOn is Timestamp) {
                    date = createdOn
                        .toDate(); // Convert Firestore Timestamp to DateTime
                  } else if (createdOn is String) {
                    date = DateTime.tryParse(
                        createdOn); // Parse the ISO 8601 string
                  }

                  // Format the date or use 'N/A' if parsing fails
                  var formattedDate = date != null
                      ? DateFormat('yyyy-MM-dd').format(date)
                      : 'N/A';

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${sale['type']} \n$formattedDate "),
                            Text(
                                '${sale['notes']} \n${sale['points'].toString()} نقطة'),
                            IconButton(
                                onPressed: () {
                                  var saleId = salesDocs[index]
                                      .id; // Navigate to SaleDetailsPage with saleId
                                  Get.to(() => SaleDetailsPage(saleId: saleId));
                                },
                                icon: const Icon(Icons.info_outline))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
