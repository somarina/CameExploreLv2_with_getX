import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PlaceModel {
  final int id;
  final String name;
  final String location;
  final double rating;
  final String image;
  PlaceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.image,
  });


  factory PlaceModel.fromMap(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      rating: json['rating'] as double,
      image: json['image'] as String,
    );
  }
}
