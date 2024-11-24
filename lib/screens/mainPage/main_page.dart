import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/class/blog_model.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/components/blog_card_small.dart';
import 'package:points/components/horizantal_brand.dart';
import 'package:points/components/my_button.dart';
import 'package:points/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:points/controllers/bottom_nav_controller.dart';
import 'package:points/controllers/settings_controller.dart';
import 'package:points/screens/blog/blog_details.dart';
import 'package:flutter/cupertino.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Get.find<AuthController>().userData.value;
    final blogsCollection = FirebaseFirestore.instance.collection('blogs');
    final navController = Get.find<BottomNavController>();
    final SettingsController settingsController =
        Get.find<SettingsController>();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Profile Banner
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                settingsController.settingsData['mainBanner'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(height: 16),

            // Points Section
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.teal, Color.fromARGB(255, 88, 223, 191)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "النقاط الحالية",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.scatter_plot,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${userData?['pointBalance']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.scatter_plot,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              navController.changeIndex(1);
                            },
                            child: Container(
                                width: 90,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                    child: Text(
                                  "صرف النقاط",
                                  style: TextStyle(color: Colors.teal),
                                ))),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${userData?['pointBalance'] / 10} JOD",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "منتجاتنا",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/products', arguments: {'brandName': ''});
                    },
                    child: const Row(
                      children: [
                        Text('جميع المنتجات'),
                        SizedBox(
                          width: 3,
                        ),
                        Icon(Icons.filter_list_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const HorizontalBrandScroller(),
            const SizedBox(height: 16),

            // Latest Blog Section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "أحدث الإعلانات",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
            ),

            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: blogsCollection
                  .orderBy('createdAt', descending: true)
                  .limit(3) // Fetch the last 3 blogs
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد اعلانات متوفرة حالياً.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final blogDocs = snapshot.data!.docs;

                return Column(
                  children: blogDocs.map((doc) {
                    final blogData = doc.data() as Map<String, dynamic>;

                    // Map Firestore data to the Blog model
                    final blog = Blog(
                      title: blogData['title'] ?? 'Untitled',
                      description: blogData['description'] ?? 'No description',
                      image: blogData['image'] ?? '',
                      sections: (blogData['sections'] as List<dynamic>?)
                              ?.map((section) => BlogSection(
                                    heading: section['heading'] ?? '',
                                    content: section['content'] ?? '',
                                    bulletPoints: (section['bulletPoints']
                                            as List<dynamic>?)
                                        ?.cast<String>(),
                                  ))
                              .toList() ??
                          [],
                    );

                    return GestureDetector(
                      onTap: () {
                        // Navigate to BlogDetailsPage with the blog model
                        Get.to(() => BlogDetailsPage(blog: blog));
                      },
                      child: BlogCardSmall(
                        title: blog.title,
                        description: blog.description,
                        imageUrl: blog.image,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
