import 'package:flutter/foundation.dart';

class Cow {
  final String cowName;
  final String cowBreed;
  final double cowPrice;
  final double cowWeight;
  final int cowLactation;
  final List<String> cowImages;
  final String phoneNumber;
  final String medication;
  final String lastFeverDate;
  final String disease;
  final String vaccineName;
  final String vaccineDate;

  Cow({
    required this.cowName,
    required this.cowBreed,
    required this.cowPrice,
    required this.cowWeight,
    required this.cowLactation,
    required this.cowImages,
    required this.phoneNumber,
    required this.medication,
    required this.lastFeverDate,
    required this.disease,
    required this.vaccineName,
    required this.vaccineDate,
  });
}
class CowProvider with ChangeNotifier {
  List<Cow> _cows = [];
  Cow? _selectedCow;

  Cow? get selectedCow => _selectedCow;
  List<Cow> get cows => _cows;

  void addCow(Cow cow) {
    _cows.add(cow);
    notifyListeners();
  }

  void selectCow(Cow cow) {
    _selectedCow = cow;
    notifyListeners();
  }

}
