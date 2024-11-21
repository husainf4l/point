import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:points/class/blog_model.dart';
import 'package:points/components/blog_card.dart';
import 'package:points/screens/blog/blog_details.dart';

class BlogPage extends StatelessWidget {
  BlogPage({super.key});

  // Firestore collection reference
  final CollectionReference blogsCollection =
      FirebaseFirestore.instance.collection('blogs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blogs',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: blogsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No blogs available.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          final blogDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: blogDocs.length,
            itemBuilder: (context, index) {
              final blogData = blogDocs[index].data() as Map<String, dynamic>;

              // Parse Firestore data into a `Blog` object
              final blog = Blog(
                title: blogData['title'] ?? 'Untitled',
                description: blogData['description'] ?? 'No description',
                image: blogData['image'] ?? '',
                sections: (blogData['sections'] as List<dynamic>?)
                        ?.map((section) => BlogSection(
                              heading: section['heading'] ?? '',
                              content: section['content'] ?? '',
                              bulletPoints:
                                  (section['bulletPoints'] as List<dynamic>?)
                                      ?.cast<String>(),
                            ))
                        .toList() ??
                    [],
              );

              return GestureDetector(
                onTap: () {
                  Get.to(() => BlogDetailsPage(blog: blog));
                },
                child: BlogCard(
                  title: blog.title,
                  description: blog.description,
                  imageUrl: blog.image,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
