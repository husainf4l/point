import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/components/my_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  // Fetch the About Us data from Firestore
  Future<About?> fetchAboutUsInfo() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('aboutUs')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        return About(
          title: data['title'] ?? '',
          imageTitle: data['imageTitle'] ?? '',
          description: data['description'] ?? '',
          sections: (data['sections'] as List<dynamic>?)
                  ?.map((section) => AboutSection(
                        heading: section['heading'] ?? '',
                        content: section['content'] ?? '',
                        image: section['image'] ?? '',
                        bulletPoints:
                            (section['bulletPoints'] as List<dynamic>?)
                                ?.map((point) => point.toString())
                                .toList(),
                      ))
                  .toList() ??
              [],
          imageUrls: (data['imageUrls'] as List<dynamic>?)
                  ?.map((url) => url.toString())
                  .toList() ??
              [],
        );
      }
      return null;
    } catch (e) {
      print('Error fetching About Us: $e');
      return null;
    }
  }

  // Launch WhatsApp contact
  void launchWhatsApp(BuildContext context) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/+962791102555");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cannot launch WhatsApp. Make sure it is installed on your device.",
          ),
        ),
      );
    }
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
      body: FutureBuilder<About?>(
        future: fetchAboutUsInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("Failed to load About Us information."),
            );
          }

          final about = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  about.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  about.description,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Sections
                ...about.sections.map((section) {
                  return AboutSectionWidget(section: section);
                }),

                MyButton(
                    onTap: () => launchWhatsApp(context),
                    title: "تواصل معنا على Whatsapp"),
                const SizedBox(height: 24),

                Text(
                  about.imageTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                if (about.imageUrls.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: about.imageUrls.map((imageUrl) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Contact Us Button
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget for displaying individual sections
class AboutSectionWidget extends StatelessWidget {
  final AboutSection section;

  const AboutSectionWidget({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Image
          if (section.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                section.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),

          // Section Heading
          Text(
            section.heading,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 8),

          // Section Content
          Text(
            section.content,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),

          // Bullet Points (if any)
          if (section.bulletPoints != null && section.bulletPoints!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.bulletPoints!.map((point) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• "),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// Models
class About {
  final String title;
  final String description;
  final String imageTitle;
  final List<AboutSection> sections;
  final List<String> imageUrls; // List of additional images

  About({
    required this.imageTitle,
    required this.title,
    required this.description,
    required this.sections,
    required this.imageUrls,
  });
}

class AboutSection {
  final String heading;
  final String content;
  final String image; // Image for each section
  final List<String>? bulletPoints;

  AboutSection({
    required this.heading,
    required this.content,
    required this.image,
    this.bulletPoints,
  });
}
