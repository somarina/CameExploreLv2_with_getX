part of 'itinerary_screen_view.dart';

class ItineraryScreenViewController extends GetxController {
  late Map<String, dynamic> package;
  List itinerary = [];

  @override
  void onInit() {
    super.onInit();

    // 1. Extract the package map safely
    package = Get.arguments?["package"] ?? {};

    // 2. Extract the itinerary list from the package data
    itinerary = package["itinerary"] ?? [];
  }

  String get price {
    return package["price_per_person"]?.toString() ?? "0";
  }

  String get packageName {
    bool km = Get.locale?.languageCode == "km";
    return km ? package["name_km"] ?? "" : package["name_en"] ?? "";
  }

  String get noteKey {
    return Get.locale?.languageCode == "km" ? "note_km" : "note_en";
  }
}