import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../utils/activity_provider.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> addActivityToFirestore(String userId, String cattleId, String title, DateTime date, int codePoint) async {
    try {
      // Format the date
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Create the activity map
      Map<String, dynamic> activityData = {
        'title': title,
        'date': formattedDate,
        'codePoint': codePoint, // Include the codePoint in the activity data
        // Add any additional details here
      };

      // Path to the global cattle collection and specific cattle document
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);

      // Path to the user-specific cattle document
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      // Add the activity to the global cattle collection
      DocumentReference globalActivityRef = await globalCattleRef
          .collection('herd_activities')
          .add(activityData);

      // Also, add the same activity data under the user-specific cattle document, using the same activity ID for consistency
      await userCattleRef
          .collection('herd_activities')
          .doc(globalActivityRef.id) // Use the same ID for user-specific record
          .set(activityData);

      print("Activity added successfully to both global and user-specific collections");
      return globalActivityRef.id; // Return the ID of the added activity
    } catch (e) {
      print("Error adding activity: $e");
      throw Exception("Error adding activity: $e");
    }
  }

  Future<void> updateActivityDateInFirestore(String userId, String documentId, String newDate) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('herd_activity')
          .doc(documentId)
          .update({
        'date': newDate, // Ensure this matches the field name in your Firestore
      });

      print("Date updated successfully");
    } catch (e) {
      print("Error updating date: $e");
    }
  }


  Future<void> deleteActivityFromFirestore(String userId, String cattleId, String documentId) async {
    try {
      // Delete from global cattle collection
      await _db.collection('cattle')
          .doc(cattleId)
          .collection('herd_activities')
          .doc(documentId)
          .delete();

      // Delete from user-specific cattle collection
      await _db.collection('users')
          .doc(userId)
          .collection('userCattle')
          .doc(cattleId)
          .collection('herd_activities')
          .doc(documentId)
          .delete();

      print("Activity deleted successfully from both collections");
    } catch (e) {
      print("Error deleting activity: $e");
      throw e;
    }
  }

  Stream<List<ActivityInfo>> streamActivities(String userId, String cattleId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('herd_activities')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityInfo.fromSnapshot(doc);
      }).toList();
    });
  }

}

