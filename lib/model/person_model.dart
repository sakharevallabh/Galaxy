import 'dart:typed_data';

class PersonModel {
  final int? id;
  late final String name;
  late final String? gender;
  late final String? dob;
  late final String? birthPlace;
  late final String? presentAddress;
  late final String? presentCountry;
  late final String? presentPincode;
  late final String? permanentAddress;
  late final String? maritalStatus;
  late final String? profession;
  late final Uint8List? photo;

  PersonModel({
    this.id,
    required this.name,
    this.gender,
    this.dob,
    this.birthPlace,
    this.presentAddress,
    this.presentPincode,
    this.presentCountry,
    this.permanentAddress,
    this.maritalStatus,
    this.profession,
    this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'birthPlace': birthPlace,
      'presentAddress': presentAddress,
      'presentCountry': presentCountry,
      'presentPincode': presentPincode,
      'permanentAddress': permanentAddress,
      'maritalStatus': maritalStatus,
      'profession': profession,
      'photo': photo,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Unknown',
      gender: map['gender'] ?? 'Unknown',
      dob: map['dob'] ?? 'Unknown',
      birthPlace: map['birthPlace'] ?? 'Unknown',
      presentAddress: map['presentAddress'] ?? 'Unknown',
      presentPincode: map['presentPincode'] ?? 'Unknown',
      presentCountry: map['presentCountry'] ?? 'Unknown',
      permanentAddress: map['permanentAddress'] ?? 'Unknown',
      maritalStatus: map['maritalStatus'] ?? 'Unknown',
      profession: map['profession'] ?? 'Unknown',
      photo: map['photo'] != null
          ? Uint8List.fromList(map['photo'].cast<int>())
          : null,
    );
  }
}
