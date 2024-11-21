import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  Future<Map<String, dynamic>?> fetchAboutUsInfo() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('aboutUs')
          .get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  void launchWhatsApp(BuildContext context) async {
    final Uri whatsappUri =
        Uri.parse("https://wa.me/+962791102555"); // Use https scheme

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Cannot launch WhatsApp. Make sure it is installed on your device.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.bell,
              color: CupertinoColors.black,
            ),
            onPressed: () {
              Get.snackbar("Notification", "No new notifications.");
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: fetchAboutUsInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: Text("Failed to load About Us information."));
            }

            var data = snapshot.data!;
            var imageUrls = List<String>.from(data['imageUrls']);

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No description available.',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        data['description'] ?? 'No description available.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        data['title1'] ?? 'No description available.',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data['description1'] ?? 'No description available.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ...imageUrls
                          .map((url) => Image.network(url, fit: BoxFit.cover)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.message),
                            label: const Text('Contact Us on WhatsApp'),
                            onPressed: () => launchWhatsApp(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
