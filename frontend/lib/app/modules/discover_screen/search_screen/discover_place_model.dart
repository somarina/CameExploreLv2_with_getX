class DiscoverPlaceModel {
  final String id;
  final String name;
  final String province;
  final String category;
  final double rating;
  final String imageUrl;
  final int searchCount;

  DiscoverPlaceModel({
    required this.id,
    required this.name,
    required this.province,
    required this.category,
    required this.rating,
    required this.imageUrl,
    required this.searchCount,
  });

  factory DiscoverPlaceModel.fromJson(Map<String, dynamic> json) {
    return DiscoverPlaceModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      province: json["province"] ?? "",
      category: json["category"] ?? "",
      rating: (json["rating"] ?? 0).toDouble(),
      imageUrl: json["image_url"] ?? "",
      searchCount: json["search_count"] ?? 0,
    );
  }
}