import 'dart:typed_data';

class PersonModel {
  final int? id;
  late final String name;
  late final String? gender;
  late final String? dob;
  late final String? birthPlace;
  late final String? country;
  late final String? pincode;
  late final String? nationality;
  late final String? maritalStatus;
  late final String? profession;
  late final Uint8List? photo;
  late final String? additionalFields;

  PersonModel({
    this.id,
    required this.name,
    this.gender,
    this.dob,
    this.birthPlace,
    this.country,
    this.pincode,
    this.nationality,
    this.maritalStatus,
    this.profession,
    this.photo,
    this.additionalFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'birthPlace': birthPlace,
      'country': country,
      'pincode': pincode,
      'nationality': nationality,
      'maritalStatus': maritalStatus,
      'profession': profession,
      'photo': photo,
      'additionalFields': additionalFields,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Unknown',
      gender: map['gender'] ?? 'Unknown',
      dob: map['dob'] ?? 'Unknown',
      birthPlace: map['birthPlace'] ?? 'Unknown',
      country: map['country'] ?? 'Unknown',
      pincode: map['pincode'] ?? 'Unknown',
      nationality: map['nationality'] ?? 'Unknown',
      maritalStatus: map['maritalStatus'] ?? 'Unknown',
      photo: map['photo'] != null ? Uint8List.fromList(map['photo'].cast<int>()) : null,
      profession: map['profession'] ?? 'Unknown',
      additionalFields: map['additionalFields'] ?? 'Unknown',
    );
  }
}
