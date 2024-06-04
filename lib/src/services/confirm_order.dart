import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../models/cart_model.dart';

Future<void> ConfirmOrder(
    CartModel cart, AddressData selectedAddress, BuildContext context) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final String uid = user.uid;
    final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');
    final CollectionReference ordersCollection =
    usersCollection.doc(uid).collection('orders');

    List<Map<String, dynamic>> cartItems = [];

    cart.items.forEach((product, quantity) {
      Map<String, dynamic> itemData = {
        'name': product.name,
        'imageUrl': product.imageUrls,
        'quantity': quantity,
      };
      cartItems.add(itemData);
    });

    Map<String, dynamic> orderData = {
      'address': selectedAddress.toMap(),
      'items': cartItems,
      'totalPrice': cart.totalPrice,
    };

    try {
      await ordersCollection.add(orderData);
      print("Order successfully added to Firestore");
      // Handle successful order placement (e.g., navigate to an order success page)
      // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderSuccessPage()));
    } catch (error) {
      print("Failed to add order: $error");
      // Handle errors (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $error')),
      );
    }
  }
}
