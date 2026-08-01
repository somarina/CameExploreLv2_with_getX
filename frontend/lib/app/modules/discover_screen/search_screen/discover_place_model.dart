class DiscoverPlaceModel {
  final String id;
  final String nameEn;
  final String nameKm;
  final String descriptionEn;
  final String descriptionKm;

  final String province;
  final String provinceKm;

  final String category;
  final String categoryKm;

  final String addressEn;
  final String addressKm;

  final double latitude;
  final double longitude;

  final String openingHours;
  final String entryFee;

  final String phoneNum;

  final double rating;
  final double ratingStar;

  final String imageUrl;
  final List<String> images;
  final List<String> tags;

  final int searchCount;

  DiscoverPlaceModel({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.descriptionEn,
    required this.descriptionKm,
    required this.province,
    required this.provinceKm,
    required this.category,
    required this.categoryKm,
    required this.addressEn,
    required this.addressKm,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    required this.entryFee,
    required this.phoneNum,
    required this.rating,
    required this.ratingStar,
    required this.imageUrl,
    required this.images,
    required this.tags,
    required this.searchCount,
  });

  factory DiscoverPlaceModel.fromJson(Map<String, dynamic> json) {
    return DiscoverPlaceModel(
      id: json["id"] ?? "",
      nameEn: json["name_en"] ?? "",
      nameKm: json["name_km"] ?? "",
      descriptionEn: json["description_en"] ?? "",
      descriptionKm: json["description_km"] ?? "",
      province: json["province"] ?? "",
      provinceKm: json["province_km"] ?? "",
      category: json["category"] ?? "",
      categoryKm: json["category_km"] ?? "",
      addressEn: json["address_en"] ?? "",
      addressKm: json["address_km"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      openingHours: json["opening_hours"] ?? "",
      entryFee: json["entry_fee"] ?? "",
      phoneNum: json["phoneNum"] ?? "",
      rating: (json["rating"] ?? 0).toDouble(),
      ratingStar: (json["rating_star"] ?? 0).toDouble(),
      imageUrl: json["image_url"] ?? "",
      images: List<String>.from(json["images"] ?? []),
      tags: List<String>.from(json["tags"] ?? []),
      searchCount: json["search_count"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name_en": nameEn,
      "name_km": nameKm,
      "description_en": descriptionEn,
      "description_km": descriptionKm,
      "province": province,
      "province_km": provinceKm,
      "category": category,
      "category_km": categoryKm,
      "address_en": addressEn,
      "address_km": addressKm,
      "latitude": latitude,
      "longitude": longitude,
      "opening_hours": openingHours,
      "entry_fee": entryFee,
      "phoneNum": phoneNum,
      "rating": rating,
      "rating_star": ratingStar,
      "image_url": imageUrl,
      "images": images,
      "tags": tags,
      "search_count": searchCount,
    };
  }
}
