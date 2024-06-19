import 'dart:typed_data';

class PersonModel {
  final int? id;
  late final String firstName;
  late final String? middleName;
  late final String? lastName;
  late final String? gender;
  late final String? dob;
  late final String? birthPlace;
  late final String? country;
  late final String? pincode;
  late final String? nationality;
  late final String? maritalStatus;
  late final String? profession;
  late final Uint8List? photo;
  late final List<String>? addresses;
  late final List<String>? phoneNumbers;
  late final List<String>? emailAddresses;
  late final List<String>? socialMediaProfiles;
  late final String? additionalFields;

  PersonModel({
    this.id,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.dob,
    this.birthPlace,
    this.country,
    this.pincode,
    this.nationality,
    this.maritalStatus,
    this.profession,
    this.photo,
    this.addresses,
    this.phoneNumbers,
    this.emailAddresses,
    this.socialMediaProfiles,
    this.additionalFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'birthPlace': birthPlace,
      'country': country,
      'pincode': pincode,
      'nationality': nationality,
      'maritalStatus': maritalStatus,
      'profession': profession,
      'photo': photo,
      'addresses': addresses?.join(';'),
      'phoneNumbers': phoneNumbers?.join(';'),
      'emailAddresses': emailAddresses?.join(';'),
      'socialMediaProfiles': socialMediaProfiles?.join(';'),
      'additionalFields': additionalFields,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      gender: map['gender'],
      dob: map['dob'],
      birthPlace: map['birthPlace'],
      country: map['country'],
      pincode: map['pincode'],
      nationality: map['nationality'],
      maritalStatus: map['maritalStatus'],
      photo: map['photo'] != null ? Uint8List.fromList(map['photo'].cast<int>()) : null,
      profession: map['profession'],
      addresses: map['addresses'],
      phoneNumbers: map['phoneNumbers'],
      emailAddresses: map['emailAddresses'],
      socialMediaProfiles: map['socialMediaProfiles'],
      additionalFields: map['additionalFields'],
    );
  }
}
