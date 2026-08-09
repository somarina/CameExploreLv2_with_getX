part of 'itinerary_screen_view.dart';

class ItineraryScreenViewController extends GetxController {
  final TravelPackageServices _packageServices = TravelPackageServices();

  Map<String, dynamic> package = {};
  List itinerary = [];
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();

    // 1. Extract package map from arguments safely
    final rawArgs = Get.arguments;
    if (rawArgs is Map<String, dynamic>) {
      package = rawArgs["package"] is Map<String, dynamic>
          ? rawArgs["package"]
          : rawArgs;
    }

    itinerary = package["itinerary"] ?? [];

    // 2. Fetch directly if itinerary is missing
    final String packageId = (package["package_id"] ?? package["id"] ?? "")
        .toString();

    if (itinerary.isEmpty && packageId.isNotEmpty) {
      loadItinerary(packageId);
    }
  }

  Future<void> loadItinerary(String id) async {
    try {
      isLoading = true;
      update();

      final response = await _packageServices.fetchTravelPackageById(id);
      if (response != null && response is Map<String, dynamic>) {
        package = response;
        itinerary = response["itinerary"] ?? [];
      }
    } catch (e) {
      debugPrint("Error loading itinerary: $e");
    } finally {
      isLoading = false;
      update(); // Rebuilds GetBuilder in UI
    }
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

  String get titleKey {
    return Get.locale?.languageCode == "km" ? "title_km" : "title_en";
  }
}
