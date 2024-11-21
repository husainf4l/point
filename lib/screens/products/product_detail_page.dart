import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:points/class/item_model.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieving the whole product object
    final Product product = Get.arguments;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(product.imageUrl, fit: BoxFit.cover),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Text("${product.brand} ${product.name}",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    Text(product.description,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(product.whenToUse,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
