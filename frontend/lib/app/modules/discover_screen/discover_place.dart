

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DiscoverPlace {
  final int id;
  final String name;
  final String location;
  final double rating;
  final String image;
  DiscoverPlace({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.image,
  });


  factory DiscoverPlace.fromMap(Map<String, dynamic> json) {
    return DiscoverPlace(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      rating: json['rating'] as double,
      image: json['image'] as String,
    );
  }
}
