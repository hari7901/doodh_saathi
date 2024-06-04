import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/marketplace_data_provider.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<void> addCowToFirestore(String collectionName, Map<String, dynamic> cowData) async {
    try {
      await _firestore.collection(collectionName).add(cowData);
    } catch (e) {
      print("Error adding cow to Firestore: $e");
    }
  }

  Future<List<Cow>> getCowsFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('listed_cows').get();

      return querySnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
        Map<String, dynamic> data = doc.data()!;
        return Cow(
          cowName: data['cowName'],
          cowBreed: data['cowBreed'],
          cowPrice: data['cowPrice'].toDouble(),
          cowWeight: data['cowWeight'].toDouble(),
          cowLactation: data['cowLactation'],
          phoneNumber: data['phoneNumber'],
          cowImages: List<String>.from(data['cowImages']),
          medication: data['medication'] ?? 'None',
          lastFeverDate: data['lastFeverDate'] ?? 'None',
          disease: data['disease']?? 'None',
          vaccineName: data['vaccineName']??'None',
          vaccineDate: data['vaccineDate']??'None'
        );
      }).toList();
    } catch (e) {
      print("Error fetching cows from Firestore: $e");
      return [];
    }
  }

}
