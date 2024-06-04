class Product {
  String id;
  String name;
  double price;
  List<String> imageUrls; // Changed to a list of strings
  String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls, // Changed to a list
    required this.description,
  });

  // Factory constructor for creating a new Product instance from a map.
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    List<String> imageUrlsList = List<String>.from(data['images'] ?? []);
    return Product(
      id: id,
      name: data['name'],
      price: data['price'].toDouble(),
      imageUrls: imageUrlsList, // Assign the list of image URLs
      description: data['description'],
    );
  }
}
