import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CattleOptionsProvider extends ChangeNotifier {
  String selectedOption = 'Birth';
  IconData selectedIcon = FontAwesomeIcons.bottleWater;
  String selectedDate = '';

  void updateOption(String option, IconData icon) {
    selectedOption = option;
    selectedIcon = icon;
    notifyListeners();
  }

  void updateDate(String newDate) {
    selectedDate = newDate;
    notifyListeners();
  }
}
