import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_category.dart';
import '../models/products_model.dart';

class NamesService {

  static Future<List<String>> fetchCategoryNames() async {
    List<String> fetchedNames = [];
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection(
          'categories').get();
      for (var doc in querySnapshot.docs) {
        // Assuming each document has a 'name' field
        fetchedNames.add(doc.data()['name'] ?? '');
      }
    } catch (e) {
      print("Error fetching category names: $e");
      // Handle exceptions or return an empty list, depending on your app's needs
    }
    return fetchedNames;
  }

  static Future<List<Product>> fetchProducts() async {
    List<Product> products = [];
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection('marketplace').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        var images = List<String>.from(data['imageUrls'] ?? []);
        var firstImageUrl = images.isNotEmpty ? images[0] : 'default.jpg'; // Get only the first image URL

        products.add(Product(
          id: doc.id,
          name: data['name'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
          imageUrls: [firstImageUrl], // Store it in a list
          description: data['description'] ?? '',
        ));
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
    return products;
  }

  static Future<List<ProductCategory>> fetchCategory() async {
    List<ProductCategory> supplies = [];
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection(
          'product_category').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        supplies.add(ProductCategory(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        ));
      }
    } catch (e) {
      print("Error fetching products: $e");
      // Handle exceptions or return an empty list, depending on your app's needs
    }
    return supplies;
  }

  static Future<List<Product>> fetchProductsByCategory(String categoryName) async {
    List<Product> products = [];
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('supplies')
          .where('category', isEqualTo: categoryName)
          .get();

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        var images = List<String>.from(data['imageUrls'] ?? []);
        var firstImageUrl = images.isNotEmpty ? images[0] : 'default.jpg'; // Get only the first image URL
        products.add(Product(
          id: doc.id,
          name: data['name'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
          imageUrls: [firstImageUrl], // Store it in a list
          description: data['description'] ?? '',
        ));
      }
    } catch (e) {
      print("Error fetching products for category $categoryName: $e");
    }
    return products;
  }

  static Future<Product> fetchProductById(String productId) async {
    try {
      var doc = await FirebaseFirestore.instance.collection('supplies').doc(productId).get();
      var data = doc.data();
      return Product(
        id: doc.id,
        name: data?['name'] ?? '',
        description: data?['description'] ?? '',
        price: data?['price']?.toDouble() ?? 0.0,
        imageUrls: List<String>.from(data?['imageUrls'] ?? []), // Retrieve all image URLs
      );
    } catch (e) {
      print("Error fetching product details: $e");
      return Product(id: '', name: '', price: 0.0, imageUrls: [], description: ''); // Return an empty product or handle error
    }
  }

}



