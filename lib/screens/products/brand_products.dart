import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/class/item_model.dart';
import 'package:points/components/app_bar_theme.dart';

class BrandProductsPage extends StatelessWidget {
  final ProductService productService = ProductService();

  BrandProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String brandName = Get.arguments['brandName'];
    return Scaffold(
      appBar: MyCupertinoAppBar(
        title: Image.asset(
          'assets/images/mainLogo.png', // Path to your logo image
          height: 32, // Adjust as per your logo's dimensions
          fit: BoxFit.contain,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          color: Colors.black, // Customize the color as needed
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: productService.fetchProductsByBrand(brandName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading products: ${snapshot.error}'),
            );
          }

          final products = snapshot.data;

          if (products == null || products.isEmpty) {
            return const Center(
                child: Text('No products found for this brand.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                  title: Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Price: ${product.price.toStringAsFixed(2)} JD',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Get.toNamed('/productDetails',
                        arguments: {'productId': product.id});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}