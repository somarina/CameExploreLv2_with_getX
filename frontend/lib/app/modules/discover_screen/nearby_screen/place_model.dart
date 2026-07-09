class PlaceModel {
  final String id;
  final String name;
  final String description;
  final String province;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;

  double distance = 0;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.province,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.distance = 0,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
  return PlaceModel(
    id: json["id"].toString(),
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    province: json["province"] ?? "",
    category: json["category"] ?? "",
    imageUrl: json["image_url"] ?? "",
    latitude: (json["latitude"] as num).toDouble(),
    longitude: (json["longitude"] as num).toDouble(),
  );
}
}