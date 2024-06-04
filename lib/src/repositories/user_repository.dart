import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Make sure this is the correct path to your AppUser model

class UserRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> saveUser(BaseUser user) async {
    try {
      await _firebaseFirestore.collection('users').doc(user.userId).set(user.toMap());
      print("User saved successfully");
    } catch (e) {
      print("Error saving user: $e");
      throw Exception("Error saving user: $e");
    }
  }
}
