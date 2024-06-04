import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitUserProfile(
      String name, String email, String company, String userId) async {
    try {
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(userId);
      CollectionReference profileSubCollection =
      userDocRef.collection('profile');

      await profileSubCollection.doc('personal_info').set({
        'name': name,
        'email': email,
        'company': company,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  Future<String> addCattleData(
      String userId, Map<String, dynamic> cattleData) async {
    try {
      DocumentReference cattleDocRef = _firebaseFirestore
          .collection('cattle') // Changed to a global cattle collection
          .doc();

      // Ensure cattleData includes a 'userId' field to associate with the user
      cattleData['userId'] = userId;

      await cattleDocRef.set(cattleData);

      // Store all cattle information alongside cattleRef in the user's sub-collection
      await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('userCattle')
          .doc(cattleDocRef.id)
          .set({
        'cattleRef': cattleDocRef.id, // Store reference to cattle
        ...cattleData, // Spread operator to include all cattle data
      });

      return cattleDocRef.id; // Return the generated document ID
    } catch (e) {
      print(e.toString());
      throw Exception('Error adding cattle data: $e');
    }
  }

  Future<void> deleteCattleData(String userId, String cattleId) async {
    try {
      // Directly delete the cattle from the global collection
      await _firebaseFirestore
          .collection('cattle')
          .doc(cattleId)
          .delete();

      // Optionally, remove the user-specific reference
      await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('userCattle')
          .doc(cattleId)
          .delete();
    } catch (e) {
      print(e.toString());
      throw Exception('Error deleting cattle data: $e');
    }
  }

  Future<void> updateCattleData(String userId, String cattleId, Map<String, dynamic> cattleData) async {
    try {
      // Direct reference to the cattle document in the global collection
      DocumentReference cattleDocRef = _firebaseFirestore.collection('cattle').doc(cattleId);

      // Update the cattle document with new data in the global collection
      await cattleDocRef.update(cattleData);

      // Update the corresponding document in the user's 'userCattle' sub-collection.
      // This ensures that any changes are reflected in both places.
      await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('userCattle')
          .doc(cattleId)
          .set({
        ...cattleData, // Use the spread operator to include all updated cattle data
        'cattleRef': cattleId, // Maintain the cattle reference
      }, SetOptions(merge: true)); // Use merge option to update existing fields without overwriting the entire document

      print("Cattle data updated successfully in both global and user-specific collections.");
    } catch (e) {
      print(e.toString());
      throw Exception('Error updating cattle data: $e');
    }
  }



  Future<void> deleteHerdActivityData(String userId, String cattleId) async {
    // Get the reference to the herd_activity collection
    var collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cattle')
        .doc(cattleId)
        .collection('herd_activity');

    // Retrieve and delete each document in the collection
    var snapshots = await collectionRef.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> addLoanApplication(
      String aadhaarNumber,
      String panCardNumber,
      String name,
      String monthlyIncome,
      String gender,
      String employmentStatus,
      String userId,
      ) async {
    try {

      DocumentReference walletInfoRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wallet_info')
          .doc('credit_details');

      // Add the new data to the 'wallet_info' collection under the user's document
      await walletInfoRef.set({
        'aadhaarNumber': aadhaarNumber,
        'panCardNumber': panCardNumber,
        'name': name,
        'monthlyIncome': monthlyIncome,
        'gender': gender,
        'employmentStatus': employmentStatus,
        'loan': 50000,
        'loanApplicationCompleted': true, // Set loanApplicationCompleted to true
      });

      // Optionally, update the user's profile to indicate the completion of the loan application
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'loanApplicationCompleted': true}, SetOptions(merge: true));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loanApplicationCompleted', true);

      print('Loan application status saved locally.');

    } catch (e) {

      print('Error adding loan application: $e');
      throw Exception('Error adding loan application: $e');
    }
  }

  static Future<bool> hasCompletedLoanApplication(String userId) async {
    try {
      DocumentSnapshot walletInfoDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wallet_info')
          .doc('credit_details')
          .get();

      if (walletInfoDoc.exists) {
        var data = walletInfoDoc.data() as Map<String, dynamic>?;
        return data?['loanApplicationCompleted'] == true;
      }

      return false;
    } catch (e) {
      print('Error checking loan application status: $e');
      throw Exception('Error checking loan application status: $e');
    }
  }

  static Future<double> fetchUserCredit(String userId) async {
    try {
      DocumentSnapshot walletInfoDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wallet_info')
          .doc('credit_details')
          .get();

      if (walletInfoDoc.exists) {
        var data = walletInfoDoc.data() as Map<String, dynamic>?;
        return data?['loan']?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error fetching user credit: $e');
      throw Exception('Error fetching user credit: $e');
    }
  }

  Future<DocumentReference<Object?>> recordTransaction(
      String userId,
      double amount,
      String type,
      String imageUrl,
      String productName,
      int quantity, // Add the quantity parameter
      ) async {
    CollectionReference transactions = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions');

    return transactions.add({
      'amount': amount,
      'type': type,
      'date': Timestamp.now(),
      'imageUrl': imageUrl,
      'productName': productName,
      'quantity': quantity, // Store the quantity in the transaction
    }).catchError((error) => print("Failed to record transaction: $error"));
  }

  Future<void> updateWalletBalance(String userId, double newBalance) async {
    try {

      DocumentReference walletRef = _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('wallet_info')
          .doc('credit_details');

      await walletRef.update({
        'loan': newBalance,
      });

    } catch (e) {

      print('Error updating wallet balance: $e');
      throw Exception('Error updating wallet balance: $e');
    }
  }
}