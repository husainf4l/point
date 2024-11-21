import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestApi extends StatefulWidget {
  @override
  _TestApiState createState() => _TestApiState();
}

class _TestApiState extends State<TestApi> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final Uri url =
          Uri.parse('https://skinior.com/api/products/category/hair-care');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Api from the nest server '),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text('No products available'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          product['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 50);
                          },
                        ),
                        title: Text(product['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: \$${product['price']}'),
                            Text('Discounted: \$${product['discountedPrice']}'),
                          ],
                        ),
                        trailing: Text(product['brand']),
                      ),
                    );
                  },
                ),
    );
  }
}
