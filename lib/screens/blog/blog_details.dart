import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/class/blog_model.dart';
import 'package:points/components/app_bar_theme.dart';
import 'package:points/components/my_button.dart';

class BlogDetailsPage extends StatelessWidget {
  final Blog blog;

  const BlogDetailsPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png', // Path to your logo image
          height: 32, // Adjust as per your logo's dimensions
          fit: BoxFit.contain,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Blog Image
            if (blog.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  blog.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            // Blog Title
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Blog Description
            Text(
              blog.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                  ),
            ),

            const SizedBox(height: 16),

            // Blog Sections
            ...blog.sections.map((section) {
              return BlogSectionWidget(section: section);
            }),
          ],
        ),
      ),
    );
  }
}

class BlogSectionWidget extends StatelessWidget {
  final BlogSection section;

  const BlogSectionWidget({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Text(
            section.heading,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Section Content
          Text(
            section.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 8),

          // Bullet Points (if any)
          if (section.bulletPoints != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.bulletPoints!.map((point) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    Expanded(
                      child: Text(
                        point,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
