import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/cattle_model.dart';

class ActivityInfo {
  final String documentId;
  final String title;
  int iconCode; // IconData cannot be directly stored in Firestore, so you store the code instead.
  late final DateTime date;

  ActivityInfo({
    required this.documentId,
    required this.title,
    required this.iconCode, // Use an int to represent IconData
    required this.date,
  });

  factory ActivityInfo.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // Assuming 'date' in your Firestore is a string like "2022-01-01"
    String dateString = data['date'] as String? ?? '';
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(dateString);
    } catch (e) {
      // Handle the case where the date string is invalid or null
      dateTime = DateTime.now(); // Default to current time
    }
    Timestamp timestamp = Timestamp.fromDate(dateTime);

    return ActivityInfo(
      documentId: snapshot.id,
      title: data['title'] ?? '', // Default to an empty string if null
      iconCode: data['iconCode'] as int? ?? 0, // Default to 0 if null
      date: timestamp.toDate(), // Use the converted timestamp
    );
  }


  // Helper method to convert iconCode back to IconData for UI rendering
  IconData get icon {
    if (iconCode != null) {
      return IconData(iconCode, fontFamily: 'MaterialIcons');
    } else {
      // Return a default icon if iconCode is null
      return Icons.error; // Example: a default icon
    }
  }
}

class ActivityProvider with ChangeNotifier {
  Map<String, List<ActivityInfo>> _cattleActivities = {};
  List<CattleEntry> _cattleEntries = [];
  List<CattleEntry> get cattleEntries => _cattleEntries;
  List<ActivityInfo> getActivities(String cattleId) => _cattleActivities[cattleId] ?? [];

  Future<void> fetchActivities(String userId, String cattleId) async {
    // Define the path to your activities in Firestore
    var activitiesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('herd_activities')
        .orderBy('date', descending: true); // Assuming you store the date

    // Listen to the snapshot changes
    activitiesRef.snapshots().listen((snapshot) {
      _cattleActivities[cattleId] = snapshot.docs
          .map((doc) => ActivityInfo.fromSnapshot(doc))
          .toList();
      notifyListeners();
    });
  }

  void addActivity(String cattleId, ActivityInfo activity) {
    if (!_cattleActivities.containsKey(cattleId)) {
      _cattleActivities[cattleId] = [];
    }
    _cattleActivities[cattleId]!.add(activity);
    notifyListeners();
  }

  void updateActivityDate(String cattleId, String activityId, DateTime newDate) {
    final cattleIndex = _cattleEntries.indexWhere((cattle) => cattle.id == cattleId);

    if (cattleIndex != -1) {
      final activityIndex = _cattleEntries[cattleIndex].activities
          .indexWhere((activity) => activity.documentId == activityId);

      if (activityIndex != -1) {
        _cattleEntries[cattleIndex].activities[activityIndex].date = newDate;
        notifyListeners();
        print("Local state updated successfully");
      }
    }
  }


  void deleteActivity(String cattleId, String documentId) {
    var activities = _cattleActivities[cattleId];
    if (activities != null) {
      activities.removeWhere((activity) => activity.documentId == documentId);
      notifyListeners();
    }
  }
}
