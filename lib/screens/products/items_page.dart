import 'package:flutter/material.dart';
import 'package:points/class/item_model.dart';

import 'items_card.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    List<Product> products = await _productService.fetchProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _searchProducts(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() => _filteredProducts = _products);
    } else {
      setState(() {
        _filteredProducts = _products
            .where((product) => product.keyWord
                .toLowerCase()
                .contains(searchTerm.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المنتجات"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _searchTerm = value;
                _searchProducts(_searchTerm);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductTile(product: _products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
