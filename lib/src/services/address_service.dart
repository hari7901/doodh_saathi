import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';

class AddressService {
  Future<void> saveAddressToFirebase(String userId, AddressData addressData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add(addressData.toMap());
      // Handle successful addition of data
    } catch (e) {
      // Handle errors
      throw Exception('Error saving address: ${e.toString()}');
    }
  }

  Future<void> deleteAddressFromFirebase(String userId, String addressId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
      // Handle successful deletion
    } catch (e) {
      // Handle errors
      throw Exception('Error deleting address: ${e.toString()}');
    }
  }

  Future<void> updateAddressInFirebase(String userId, String addressId, AddressData addressData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .update(addressData.toMap());
      // Address successfully updated
    } catch (e) {
      throw Exception('Error updating address: ${e.toString()}');
    }
  }
}
