import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String id;
  String name;

  String email;
  String phone;
  String avatar;
  String gender;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'gender': gender,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['profile_image'] ?? '',
      gender: map['gender'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
