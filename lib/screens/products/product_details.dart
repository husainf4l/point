import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:points/components/app_bar_theme.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchProductDetails(
      String productId) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final String productId = Get.arguments['productId'];

    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png', // Path to your logo image
          height: 32, // Adjust as per your logo's dimensions
          fit: BoxFit.contain,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchProductDetails(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error loading product details: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product not found.'));
          }

          final productData = snapshot.data!.data()!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full-width product image
                Image.network(
                  productData['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        productData['name'] ?? 'Unnamed Product',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Product Brand
                      if (productData['brand'] != null)
                        Text(
                          'Brand: ${productData['brand']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 16.0),

                      // Product Description
                      if (productData['description'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              productData['description'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16.0),

                      // Features Section
                      if (productData['feature'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Features:',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              productData['feature'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16.0),

                      // How to Use Section
                      if (productData['howToUse'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'How to Use:',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              productData['howToUse'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16.0),

                      // When to Use Section
                      if (productData['whenToUse'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'When to Use:',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              productData['whenToUse'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
