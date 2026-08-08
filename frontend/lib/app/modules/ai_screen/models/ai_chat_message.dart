class AiSuggestedPlace {
  final String id;
  final String nameEn;
  final String nameKm;
  final String province;
  final String category;
  final String imageUrl;
  final double rating;

  AiSuggestedPlace({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.province,
    required this.category,
    required this.imageUrl,
    required this.rating,
  });

  factory AiSuggestedPlace.fromJson(Map<String, dynamic> json) {
    return AiSuggestedPlace(
      id: json["id"]?.toString() ?? "",
      nameEn: json["name_en"]?.toString() ?? "",
      nameKm: json["name_km"]?.toString() ?? "",
      province: json["province"]?.toString() ?? "",
      category: json["category"]?.toString() ?? "",
      imageUrl: json["image_url"]?.toString() ?? "",
      rating: (json["rating"] as num?)?.toDouble() ?? 0,
    );
  }
}

enum AiSender { user, assistant }

class AiChatMessage {
  final AiSender sender;
  final String text;
  final List<AiSuggestedPlace> suggestedPlaces;
  final bool isError;
  final String? localImagePath; // preview of the image the user uploaded
  final String? googleMapsUrl; // link to open the identified place on Google Maps

  AiChatMessage({
    required this.sender,
    required this.text,
    this.suggestedPlaces = const [],
    this.isError = false,
    this.localImagePath,
    this.googleMapsUrl,
  });
}