import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/herd_activity_service.dart';
import '../services/user_profile_service.dart';
import '../utils/activity_provider.dart';

class CattleEntry extends ChangeNotifier {
  List<ActivityInfo> activities = [];
  Set<String> addedActivities = {};
  String id;
  String tagNumber;
  String name;
  String birthday;
  String breed;
  String lactation;
  String mother;
  String inseminator;
  String herd;
  String Date;
  String weight;

  CattleEntry({
    required this.id,
    this.tagNumber = '',
    this.name = '',
    this.birthday = '',
    this.breed = '',
    this.lactation = '',
    this.mother = '',
    this.inseminator = '',
    this.herd = '',
    this.Date = '',
    this.weight = '',
  });

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }


  void addActivity(ActivityInfo activity) {
    activities.add(activity);
    addedActivities.add(activity.title);
    notifyListeners();
  }

  bool isActivityAdded(String activityTitle) {
    return addedActivities.contains(activityTitle);
  }

  void removeActivity(String activityId, String activityTitle) {
    activities.removeWhere((activity) => activity.documentId == activityId);
    addedActivities.remove(activityTitle);
    notifyListeners();
  }

  factory CattleEntry.fromMap(Map<String, dynamic> map) {
    return CattleEntry(
      id: map['id'] ?? '',
      tagNumber: map['tagNumber'] ?? '',
      name: map['name'] ?? '',
      birthday: map['birthday'] ?? '',
      breed: map['breed'] ?? '',
      mother: map['mother'] ?? '',
      inseminator: map['inseminator'] ?? '',
      herd: map['herd'] ?? '',
      Date: map['Date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagNumber': tagNumber,
      'name': name,
      'birthday': birthday,
      'breed': breed,
      'mother': mother,
      'inseminator': inseminator,
      'herd': herd,
      'Date': Date,
    };
  }
}

class CattleModel extends ChangeNotifier {
  List<CattleEntry> cattle = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _cattleCollection =
  FirebaseFirestore.instance.collection('cattle');

  Future<void> fetchCattleEntries() async {
    try {
      final QuerySnapshot snapshot = await _cattleCollection.get();
      final List<CattleEntry> entries = snapshot.docs
          .map((doc) => CattleEntry.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      setCattleList(entries);
    } catch (e) {
      print('Error fetching cattle entries: $e');
    }
  }

  void addCattleEntry(CattleEntry entry) async {
    try {
      await _cattleCollection.add(entry.toMap());
      fetchCattleEntries(); // Refresh the list after adding
    } catch (e) {
      print('Error adding cattle entry: $e');
    }
  }

  void setCattleList(List<CattleEntry> entries) {
    cattle = entries;
    notifyListeners();
  }

  void updateCattleEntry(CattleEntry updatedEntry) async {
    try {
      await _cattleCollection.doc(updatedEntry.id).update(updatedEntry.toMap());
      fetchCattleEntries(); // Refresh the list after updating
    } catch (e) {
      print('Error updating cattle entry: $e');
    }
  }

  void removeCattleEntry(String cattleId) async {
    try {
      await _cattleCollection.doc(cattleId).delete();
      fetchCattleEntries(); // Refresh the list after deleting
    } catch (e) {
      print('Error removing cattle entry: $e');
    }
  }
  void updateActivityDate(
      String cattleId,
      String activityId,
      DateTime newDate,
      ) async {
    try {
      final cattleRef = _cattleCollection.doc(cattleId);
      final activityRef = cattleRef.collection('activities').doc(activityId);
      await activityRef.update({'date': newDate});
      fetchCattleEntries(); // Refresh the list after updating
    } catch (e) {
      print('Error updating activity date: $e');
    }
  }

  void removeCattleActivity(
      String cattleId,
      String activityId,
      ) async {
    try {
      final cattleRef = _cattleCollection.doc(cattleId);
      final activityRef = cattleRef.collection('activities').doc(activityId);
      await activityRef.delete();
      fetchCattleEntries(); // Refresh the list after deleting
    } catch (e) {
      print('Error removing cattle activity: $e');
    }
  }

  void updateCattleActivity(
      String cattleId,
      String activityId,
      Map<String, dynamic> updatedData,
      ) async {
    try {
      final cattleRef = _cattleCollection.doc(cattleId);
      final activityRef = cattleRef.collection('activities').doc(activityId);
      await activityRef.update(updatedData);
      fetchCattleEntries(); // Refresh the list after updating
    } catch (e) {
      print('Error updating cattle activity: $e');
    }
  }
}
