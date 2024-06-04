import 'package:cloud_firestore/cloud_firestore.dart';

class LactationEntry {
  final String id; // Useful for referencing specific entries if needed
  final DateTime startDate;
  final DateTime endDate;

  LactationEntry({
    this.id = '',
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  static LactationEntry fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return LactationEntry(
      id: snapshot.id,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }
}
