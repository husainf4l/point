import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String active;
  final String barcode;
  final String brand;
  final String feature;
  final String howToUse;
  final String keyWord;
  final String whenToUse;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.active,
    required this.barcode,
    required this.brand,
    required this.feature,
    required this.howToUse,
    required this.keyWord,
    required this.whenToUse,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    // Extract price and remove 'Price: ' prefix if present.
    String priceString = data['price'] ?? '0';
    double price = double.tryParse(priceString
            .replaceAll(RegExp(r'Price: '), '')
            .replaceAll(' JD', '')) ??
        0.0;

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ??
          '', // Changed from imageUrl to photo to match your Firestore field
      price: price,
      active: data['active'] ?? '',
      barcode: data['barcode'] ?? '',
      brand: data['brand'] ?? '',
      feature: data['feature'] ?? '',
      howToUse: data['howToUse'] ?? '',
      keyWord: data['keyWord'] ?? '',
      whenToUse: data['whenToUse'] ?? '',
    );
  }
}

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> fetchProductsBykeyWord(String keyWord) async {
    try {
      final List<Product> allProducts = await fetchProducts();
      return allProducts
          .where((product) =>
              product.keyWord.toLowerCase().contains(keyWord.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

Future<void> addDemoData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> demoProducts = [
    {
      "name": "Product 1",
      "description": "This is the first demo product.",
      "imageUrl":
          "https://cdn3.dumyah.com/image/cache/data/PartnerPortal/request/281/5201580907917_1_1712995052-800x800.png",
      "price": "10 JD",
      "active": "Yes",
      "barcode": "123456789",
      "brand": "coverderm",
      "feature": "Feature 1",
      "howToUse": "Use as directed.",
      "keyWord": "keyword1",
      "whenToUse": "When necessary."
    },
    {
      "name": "Product 2",
      "description": "This is the second demo product.",
      "imageUrl":
          "https://skinior.com/api/uploads/products/coverderm/coverderm-filteray-face-60.webp",
      "price": "20 JD",
      "active": "Yes",
      "barcode": "987654321",
      "brand": "coverderm",
      "feature": "Feature 2",
      "howToUse": "Use as needed.",
      "keyWord": "keyword2",
      "whenToUse": "For daily use."
    },
    {
      "name": "Product 3",
      "description": "This is the third demo product.",
      "imageUrl":
          "https://skinior.com/api/uploads/products/coverderm/coverderm-filteray-face-60.webp",
      "price": "30 JD",
      "active": "No",
      "barcode": "555555555",
      "brand": "coverderm",
      "feature": "Feature 3",
      "howToUse": "Follow instructions.",
      "keyWord": "keyword3",
      "whenToUse": "At night."
    }
  ];

  for (var product in demoProducts) {
    await firestore.collection('products').add(product);
  }
}
