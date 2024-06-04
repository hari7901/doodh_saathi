// product_category.dart

class ProductCategory {
  final String id;
  final String name;
  final String imageUrl;

  ProductCategory( {required this.name,required this.id, required this.imageUrl});

  // Method to create a ProductCategory object from a Map (e.g., from Firebase document)
  factory ProductCategory.fromFireStore(Map<String, dynamic> map, String id) {
    return ProductCategory(
      id: id, // The document ID from Firebase is used as the id
      name: map['name'] ?? '', // Assuming 'name' is the key in the map
      imageUrl: map['imageUrl'] ?? '', // Assuming 'imageUrl' is the key in the map
    );
  }
}
