
class AddressData {
  final String id;
  final String name;
  final String phone;
  final String flatHouseNo;
  final String areaStreet;
  final String landmark;
  final String pincode;
  final String city;
  final String state;

  AddressData({
    this.id = '',
    required this.name,
    required this.phone,
    required this.flatHouseNo,
    required this.areaStreet,
    required this.landmark,
    required this.pincode,
    required this.city,
    required this.state,
  });

  factory AddressData.fromMap(Map<String, dynamic> map, String documentId) {
    return AddressData(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      flatHouseNo: map['flatHouseNo'] ?? '',
      areaStreet: map['areaStreet'] ?? '',
      landmark: map['landmark'] ?? '',
      pincode: map['pincode'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'flatHouseNo': flatHouseNo,
      'areaStreet': areaStreet,
      'landmark': landmark,
      'pincode': pincode,
      'city': city,
      'state': state,
    };
  }
}
