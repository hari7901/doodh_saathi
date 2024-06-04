import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String id;
  String title;
  DateTime date;

  Activity({
    required this.id,
    required this.title,
    required this.date,
  });

  // Converts a Firestore DocumentSnapshot to an Activity object
  factory Activity.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      title: data['title'] as String,
      date: DateTime.parse(data['date'] as String),
    );
  }

  // Converts an Activity object to a map, suitable for Firestore
  Map<String, dynamic> toFirestoreDocument() {
    return {
      'title': title,
      'date': date.toIso8601String(),
    };
  }
}
