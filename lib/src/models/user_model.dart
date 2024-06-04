abstract class BaseUser {
  final String userId;

  BaseUser(this.userId);
  Map<String, dynamic> toMap();
}

class AppUser extends BaseUser {
  final String phone;
  final DateTime registrationDate;

  AppUser({
    required String userId,
    required this.phone,
    required this.registrationDate,
  }) : super(userId); // Pass userId to the BaseUser constructor

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phone': phone,
      'registrationDate': registrationDate,
    };
  }
}

class VetUser extends BaseUser {
  final String email;
  final String phone;
  final DateTime registrationDate;
  final String firstName;
  final String lastName;

  VetUser( {
    required String userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.registrationDate,
  }) : super(userId); // Pass userId to the BaseUser constructor

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'phone': phone,
      'registrationDate': registrationDate,
    };
  }
}
