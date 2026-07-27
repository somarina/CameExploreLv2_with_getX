class PlaceModel {
  final String id;
  final String nameEn;
  final String nameKm;
  final String description;
  final String province;
  final String provinceKm;
  final String category;
  final String categoryKm;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double rating;

  double distance = 0;

  PlaceModel({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.description,
    required this.province,
    required this.provinceKm,
    required this.category,
    required this.categoryKm,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.distance = 0,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
  return PlaceModel(
    id: json["id"]?.toString() ?? "",
    nameEn: json["name_en"]?.toString() ?? "",
    nameKm: json["name_km"]?.toString() ?? "",
    description: json["description_en"]?.toString() ?? "",
    province: json["province"]?.toString() ?? "",
    provinceKm: json["province_km"]?.toString() ?? "",
    category: json["category"]?.toString() ?? "",
    categoryKm: json["category_km"]?.toString() ?? "",
    imageUrl: json["image_url"]?.toString() ?? "",
    latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
    longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    rating: (json["rating"] as num?)?.toDouble() ?? 0.0,
  );
}
  Map<String, dynamic> toJson() {
  return {
    "id": id,
    "name_en": nameEn,
    "name_km": nameKm,
    "description_en": description,
    "province": province,
    "province_km": provinceKm,
    "category": category,
    "category_km": categoryKm,
    "image_url": imageUrl,
    "latitude": latitude,
    "longitude": longitude,
    "rating": rating,
    "phoneNum": "",
  };
}}
