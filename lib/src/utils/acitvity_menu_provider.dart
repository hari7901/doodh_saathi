import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuOptionsProvider with ChangeNotifier {
  List<Map<String, dynamic>> menuOptions = [
    {'title': 'Weaned', 'icon': FontAwesomeIcons.weightScale},
    {'title': 'Heat', 'icon': FontAwesomeIcons.heart},
    {'title': 'Breeding', 'icon': FontAwesomeIcons.seedling},
    {'title': 'Pregnant', 'icon': FontAwesomeIcons.cow},
    {'title': 'Medical', 'icon': FontAwesomeIcons.suitcaseMedical},
    {'title': 'Vaccine', 'icon': FontAwesomeIcons.syringe},
  ];
  Set<String> addedOptions = Set<String>();
  final List<String> originalOrder = [
    'Weaned', 'Heat', 'Breeding', 'Pregnant', 'Medical', 'Vaccine'
  ];


  void addActivity(String title) {
    addedOptions.add(title);
    notifyListeners();
  }

  bool isActivityAdded(String title) {
    return addedOptions.contains(title);
  }

  void removeActivity(String title) {
    addedOptions.remove(title);
    notifyListeners();
  }

  void reInsertOption(String title, IconData icon) {
    int originalIndex = originalOrder.indexOf(title);
    if (originalIndex != -1) {
      Map<String, dynamic> optionData = {
        'title': title,
        'icon': icon,
      };

      // Re-insert the option at its original position
      if (menuOptions.length > originalIndex) {
        menuOptions.insert(originalIndex, optionData);
      } else {
        menuOptions.add(optionData);
      }

      notifyListeners();
    }
  }

  void deleteActivity(String title) {
    addedOptions.remove(title);
    reInsertOption(title, getIconForTitle(title));
  }

  IconData getIconForTitle(String title) {
    switch (title) {
      case 'Weaned':
        return FontAwesomeIcons.weightScale;
      case 'Heat':
        return FontAwesomeIcons.heart;
      case 'Breeding':
        return FontAwesomeIcons.seedling;
      case 'Pregnant':
        return FontAwesomeIcons.cow;
      case 'Medical':
        return FontAwesomeIcons.suitcaseMedical;
      case 'Vaccine':
        return FontAwesomeIcons.syringe;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }
}
