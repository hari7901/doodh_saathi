import 'package:DoodhSaathi/src/models/products_model.dart';
import 'package:flutter/cupertino.dart';

class CartModel extends ChangeNotifier {
  final Map<Product, int> _items = {};

  Map<Product, int> get items => _items;

  double get totalPrice {
    return _items.entries
        .map((entry) => entry.key.price.toDouble() * entry.value) // Ensure calculation returns double
        .fold(0.0, (previousValue, element) => previousValue + element);
  }

  void add(Product product, int quantity) {
    if (_items.containsKey(product)) {
      _items.update(product, (existingQuantity) => existingQuantity + quantity);
    } else {
      _items[product] = quantity;
    }
    notifyListeners();
  }

  void remove(Product product) {
    if (_items.containsKey(product) && _items[product]! > 1) {
      _items.update(product, (existingQuantity) => existingQuantity - 1);
    } else {
      _items.remove(product);
    }
    notifyListeners();
  }

  double calculateSubtotal() {
    return _items.entries
        .map((entry) => entry.key.price.toDouble() * entry.value) // Ensure calculation returns double
        .fold(0.0, (previousValue, element) => previousValue + element);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeItemCompletely(Product product) {
    if (_items.containsKey(product)) {
      _items.remove(product);
    }
    notifyListeners();
  }
}
