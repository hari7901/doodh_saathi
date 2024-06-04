import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/user_profile_service.dart';

class CattleIdProvider with ChangeNotifier {
  String? _cattleId;
  String? _error;

  String? get cattleId => _cattleId;
  String? get error => _error;

  void setCattleId(String? newId) {
    _cattleId = newId;
    _error = null; // Reset error when successfully setting a new ID
    notifyListeners();
  }

  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

}