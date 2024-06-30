import 'dart:convert';
import 'dart:typed_data';

class PersonModel {
  final int? id;
  late final String? name;
  late final String? gender;
  late final String? dob;
  late final String? birthPlace;
  late final String? presentAddress;
  late final String? presentPincode;
  late final String? presentCountry;
  late final String? permanentAddress;
  late final String? maritalStatus;
  late final String? profession;
  late final String? relation;
  late final Uint8List? photo;
  late final List<String>? interests;
  late final List<String>? phoneNumbers;
  late final List<String>? emailAddresses;
  late final List<String>? links;
  late final List<Map<String, String>>? educationDetails;

  PersonModel({
    this.id,
    this.name,
    this.gender,
    this.dob,
    this.birthPlace,
    this.presentAddress,
    this.presentPincode,
    this.presentCountry,
    this.permanentAddress,
    this.maritalStatus,
    this.profession,
    this.relation,
    this.photo,
    this.interests,
    this.phoneNumbers,
    this.emailAddresses,
    this.links,
    this.educationDetails,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
        id: json['id'],
        name: json['name'],
        gender: json['gender'],
        dob: json['dob'],
        birthPlace: json['birthPlace'],
        presentAddress: json['presentAddress'],
        presentPincode: json['presentPincode'],
        presentCountry: json['presentCountry'],
        permanentAddress: json['permanentAddress'],
        maritalStatus: json['maritalStatus'],
        profession: json['profession'],
        relation: json['relation'],
        photo: json['photo'] != null ? base64Decode(json['photo']) : null,
        interests: json['interests'] != null
            ? List<String>.from(jsonDecode(json['interests']).map((x) => x))
            : [],
        phoneNumbers: json['phoneNumbers'] != null
            ? List<String>.from(jsonDecode(json['phoneNumbers']).map((x) => x))
            : [],
        emailAddresses: json['emailAddresses'] != null
            ? List<String>.from(jsonDecode(json['emailAddresses']).map((x) => x))
            : [],
        links: json['links'] != null
            ? List<String>.from(jsonDecode(json['links']).map((x) => x))
            : [],
        educationDetails: json['educationDetails'] != null
            ? List<Map<String, String>>.from(
                jsonDecode(json['educationDetails']).map((x) => Map<String, String>.from(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'dob': dob,
        'birthPlace': birthPlace,
        'presentAddress': presentAddress,
        'presentPincode': presentPincode,
        'presentCountry': presentCountry,
        'permanentAddress': permanentAddress,
        'maritalStatus': maritalStatus,
        'profession': profession,
        'relation': relation,
        'photo': photo != null ? base64Encode(photo!) : null,
        'interests': interests != null ? jsonEncode(interests) : null,
        'phoneNumbers': phoneNumbers != null ? jsonEncode(phoneNumbers) : null,
        'emailAddresses': emailAddresses != null ? jsonEncode(emailAddresses) : null,
        'links': links != null ? jsonEncode(links) : null,
        'educationDetails': educationDetails != null ? jsonEncode(educationDetails) : null,
      };
}
