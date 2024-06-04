import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lactation_model.dart';
import '../views/mycow/detail_view_parts/disease_page.dart';
import '../views/mycow/detail_view_parts/feed_entry_page.dart';
import '../views/mycow/detail_view_parts/milk_entry_page.dart';
import '../views/mycow/detail_view_parts/vaccination_page.dart';
import '../views/mycow/detail_view_parts/weight_entry_page.dart';

class CattleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMilkEntry(String userId, String cattleId, double milk, DateTime date) async {
    try {
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      Map<String, dynamic> milkData = {
        'milk': milk,
        'date': Timestamp.fromDate(date),
      };

      // Add the milk entry to the global collection
      await globalCattleRef.collection('milkEntries').add(milkData);

      // Add the milk entry to the user's specific cattle
      await userCattleRef.collection('milkEntries').add(milkData);

      print("Milk entry added successfully to both global and user-specific collections.");
    } catch (e) {
      print("Error adding milk entry: $e");
      throw e;
    }
  }

  // Method to fetch milk entries from the user-specific cattle collection
  Stream<List<MilkEntry>> getUserMilkEntries(String userId, String cattleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('milkEntries')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MilkEntry.fromSnapshot(doc)).toList());
  }

  Future<void> addWeightEntry(String userId, String cattleId, double weight, DateTime date) async {
    try {
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      Map<String, dynamic> weightData = {
        'weight': weight,
        'date': Timestamp.fromDate(date),
      };

      // Add the weight entry to both the global and the user-specific cattle document
      await globalCattleRef.collection('weightEntries').add(weightData);
      await userCattleRef.collection('weightEntries').add(weightData);

      print("Weight entry added successfully to both global and user-specific collections.");
    } catch (e) {
      print("Error adding weight entry: $e");
      throw e;
    }
  }

  Stream<List<WeightEntry>> getUserWeightEntries(String userId, String cattleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('weightEntries')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => WeightEntry.fromSnapshot(doc)).toList());
  }

  Future<void> addLactationCycle(String userId, String cattleId, DateTime startDate, DateTime endDate) async {
    try {
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      Map<String, dynamic> lactationData = {
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
      };

      // Add the lactation cycle to the global collection
      await globalCattleRef.collection('lactationCycles').add(lactationData);

      // Add the lactation cycle to the user's specific cattle
      await userCattleRef.collection('lactationCycles').add(lactationData);

      print("Lactation cycle added successfully to both global and user-specific collections.");
    } catch (e) {
      print("Error adding lactation cycle: $e");
      throw e;
    }
  }

  Stream<List<LactationEntry>> getUserLactationEntries(String userId, String cattleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('lactationCycles')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => LactationEntry.fromSnapshot(doc)).toList());
  }

  Future<void> addVaccineEntry(String userId, String cattleId, String vaccineName, String vaccineType,String imageUrl, DateTime date) async {
    try {
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      Map<String, dynamic> vaccineData = {
        'name': vaccineName,
        'type': vaccineType,
        'date': date,
        'imageUrl': imageUrl
      };

      // Add the lactation cycle to the global collection
      await globalCattleRef.collection('vaccinations').add(vaccineData);

      // Add the lactation cycle to the user's specific cattle
      await userCattleRef.collection('vaccinations').add(vaccineData);

      print("Lactation cycle added successfully to both global and user-specific collections.");
    } catch (e) {
      print("Error adding lactation cycle: $e");
      throw e;
    }
  }
  // Fetch vaccination entries from the userCattle subcollection
  Stream<List<VaccinationEntry>> getUserVaccinationEntries(String userId, String cattleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('vaccinations')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VaccinationEntry.fromSnapshot(doc))
        .toList());
  }

  Future<void> addDiseaseEntry(String userId, String cattleId, String diseases, DateTime date) async {
    try {
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      Map<String, dynamic> diseaseData = {
        'disease': diseases,
        'date': Timestamp.fromDate(date),
      };

      // Add the weight entry to both the global and the user-specific cattle document
      await globalCattleRef.collection('diseaseRecord').add(diseaseData);
      await userCattleRef.collection('diseaseRecord').add(diseaseData);

      print("Weight entry added successfully to both global and user-specific collections.");
    } catch (e) {
      print("Error adding weight entry: $e");
      throw e;
    }
  }

  Stream<List<DiseaseEntry>> getUserDiseaseEntries(String userId, String cattleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('diseaseRecord')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => DiseaseEntry.fromSnapshot(doc)).toList());
  }

  Future<void> deleteMilkEntry(String userId, String cattleId, String entryId) async {
    DocumentReference globalLactationRef = _db.collection('cattle').doc(cattleId).collection('milkEntries').doc(entryId);
    DocumentReference userLactationRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId).collection('milkEntries').doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(globalLactationRef);
      transaction.delete(userLactationRef);
    });
  }

  Future<void> deleteWeightEntry(String userId, String cattleId, String entryId) async {
    DocumentReference globalLactationRef = _db.collection('cattle').doc(cattleId).collection('weightEntries').doc(entryId);
    DocumentReference userLactationRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId).collection('weightEntries').doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(globalLactationRef);
      transaction.delete(userLactationRef);
    });
  }


  Future<void> deleteLactationEntry(String userId, String cattleId, String entryId) async {
    DocumentReference globalLactationRef = _db.collection('cattle').doc(cattleId).collection('lactationCycles').doc(entryId);
    DocumentReference userLactationRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId).collection('lactationCycles').doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(globalLactationRef);
      transaction.delete(userLactationRef);
    });
  }

  Future<void> deleteVaccineEntry(String userId, String cattleId, String entryId) async {
    DocumentReference globalLactationRef = _db.collection('cattle').doc(cattleId).collection('vaccinations').doc(entryId);
    DocumentReference userLactationRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId).collection('vaccinations').doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(globalLactationRef);
      transaction.delete(userLactationRef);
    });
  }

  Future<void> deleteDiseaseEntry(String userId, String cattleId, String entryId) async {
    DocumentReference globalLactationRef = _db.collection('cattle').doc(cattleId).collection('diseaseRecord').doc(entryId);
    DocumentReference userLactationRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId).collection('diseaseRecord').doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(globalLactationRef);
      transaction.delete(userLactationRef);
    });
  }

  Future<void> addFeedEntry(String userId, String cattleId, String feedName, double feedQty, DateTime date) async {
    try {
      DocumentReference globalCattleRef = _db.collection('cattle').doc(cattleId);
      DocumentReference userCattleRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId);

      Map<String, dynamic> weightData = {
        'feedQty': feedQty,
        'feedName': feedName,
        'date': Timestamp.fromDate(date),
      };

      // Add the weight entry to both the global and the user-specific cattle document
      await globalCattleRef.collection('feedEntries').add(weightData);
      await userCattleRef.collection('feedEntries').add(weightData);

      print("Weight entry added successfully to both global and user-specific collections.");
    } catch (e) {
      print("Error adding weight entry: $e");
      throw e;
    }
  }

  Stream<List<FeedEntry>> getUserFeedEntries(String userId, String cattleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('userCattle')
        .doc(cattleId)
        .collection('feedEntries')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FeedEntry.fromSnapshot(doc)).toList());
  }

  Future<void> deleteFeedEntry(String userId, String cattleId, String entryId) async {
    DocumentReference globalLactationRef = _db.collection('cattle').doc(cattleId).collection('feedEntries').doc(entryId);
    DocumentReference userLactationRef = _db.collection('users').doc(userId).collection('userCattle').doc(cattleId).collection('feedEntries').doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(globalLactationRef);
      transaction.delete(userLactationRef);
    });
  }

}
