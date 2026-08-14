import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/hotels_services.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/core/api/services/search_service.dart';
import 'package:frontend/app/core/api/services/travel_package_services.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SearchResultScreenController extends GetxController {
  final SearchService searchService = SearchService();
  final hotelService =
      HotelServices(); // Assuming you have a separate service for hotels
  final travelPackageService =
      TravelPackageServices(); // Assuming you have a separate service for travel packages
  final placeServices =
      PlacesServices(); // Assuming you have a separate service for places
  final nearbyController = Get.find<NearbyScreenController>();

  final TextEditingController searchController = TextEditingController();

  // ============================================================
  // SEARCH RESULTS
  // ============================================================

  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allSearchResults =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  final RxString selectedCategory = "".obs;

  String currentKeyword = "";

  final GetStorage storage = GetStorage();

  final RxList<Map<String, dynamic>> searchHistory =
      <Map<String, dynamic>>[].obs;

  final RxBool hasSearched = false.obs;

  static const String searchHistoryKey = "search_history";

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();

    final arguments = Get.arguments;

    print("SEARCH SCREEN ARGUMENTS: $arguments");
    print("SEARCH SCREEN ARGUMENT TYPE: ${arguments.runtimeType}");

    if (arguments is String) {
      currentKeyword = arguments.trim();
      searchController.text = currentKeyword;

      if (currentKeyword.isNotEmpty) {
        hasSearched.value = true;
        searchPlaces(currentKeyword);
      }
    } else if (arguments is Map) {
      final keyword = arguments["keyword"]?.toString().trim() ?? "";

      currentKeyword = keyword;
      searchController.text = keyword;

      if (keyword.isNotEmpty) {
        hasSearched.value = true;
        searchPlaces(keyword);
      }
    }
  }

  void loadSearchHistory() {
    final history = storage.read<List>(searchHistoryKey);

    if (history != null) {
      searchHistory.assignAll(
        history.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    }
  }

  void saveRecentSearch(Map<String, dynamic> result) {
    final item = {
      "type": result["type"],
      "data": Map<String, dynamic>.from(result["data"] ?? {}),
    };

    searchHistory.removeWhere((existing) {
      final existingData = Map<String, dynamic>.from(existing["data"] ?? {});

      return existing["type"] == item["type"] &&
          existingData["id"] == item["data"]["id"];
    });

    searchHistory.insert(0, item);

    if (searchHistory.length > 20) {
      searchHistory.removeRange(20, searchHistory.length);
    }

    storage.write(searchHistoryKey, searchHistory.toList());
  }

  void removeRecentSearch({required String type, required dynamic itemId}) {
    searchHistory.removeWhere((item) {
      final data = item["data"];

      if (data is! Map) return false;

      return item["type"] == type &&
          data["id"]?.toString() == itemId?.toString();
    });

    storage.write(searchHistoryKey, searchHistory.toList());
  }

  void clearSearchHistory() {
    searchHistory.clear();

    storage.remove(searchHistoryKey);
  }

  Future<void> searchSubmitted(String keyword) async {
    final query = keyword.trim();

    if (query.isEmpty) return;

    await searchPlaces(query);
  }
  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> searchPlaces(String keyword) async {
    currentKeyword = keyword.trim();

    if (currentKeyword.isEmpty) {
      hasSearched.value = false;
      searchResults.clear();
      allSearchResults.clear();
      return;
    }

    hasSearched.value = true;

    try {
      isLoading.value = true;

      final response = await searchService.search(
        keyword: currentKeyword,
        limit: 20,
      );

      print("========================================");
      print("SEARCH RESPONSE");
      print(response);
      print("========================================");

      final data = response["data"];

      if (data is! Map) {
        searchResults.clear();
        return;
      }

      final List<Map<String, dynamic>> results = [];

      // ========================================================
      // PLACES
      // ========================================================

      final places = data["places"];

      if (places is List) {
        for (final item in places) {
          if (item is Map) {
            results.add({
              "type": "place",
              "data": Map<String, dynamic>.from(item),
            });
          }
        }
      }

      // ========================================================
      // HOTELS
      // ========================================================

      final hotels = data["hotels"];

      if (hotels is List) {
        for (final item in hotels) {
          if (item is Map) {
            results.add({
              "type": "hotel",
              "data": Map<String, dynamic>.from(item),
            });
          }
        }
      }

      // ========================================================
      // PACKAGES
      // ========================================================

      final packages = data["packages"];

      if (packages is List) {
        for (final item in packages) {
          if (item is Map) {
            results.add({
              "type": "package",
              "data": Map<String, dynamic>.from(item),
            });
          }
        }
      }

      allSearchResults.assignAll(results);

      applyCategoryFilter();

      print("TOTAL RESULTS: ${searchResults.length}");
      print("PLACES: ${results.where((e) => e["type"] == "place").length}");
      print("HOTELS: ${results.where((e) => e["type"] == "hotel").length}");
      print("PACKAGES: ${results.where((e) => e["type"] == "package").length}");
    } catch (e, stackTrace) {
      print("SEARCH ERROR: $e");
      print(stackTrace);

      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void applyCategoryFilter() {
    final keyword = currentKeyword.toLowerCase().trim();
    final category = selectedCategory.value.toLowerCase().trim();

    final filtered = allSearchResults.where((result) {
      final type = result["type"]?.toString().toLowerCase() ?? "";
      final data = Map<String, dynamic>.from(result["data"] ?? {});

      // -----------------------------
      // Keyword filter
      // -----------------------------
      final nameEn = data["name_en"]?.toString().toLowerCase() ?? "";
      final nameKm = data["name_km"]?.toString().toLowerCase() ?? "";
      final province = data["province"]?.toString().toLowerCase() ?? "";
      final provinceKm = data["province_km"]?.toString().toLowerCase() ?? "";
      final categoryEn = data["category"]?.toString().toLowerCase() ?? "";
      final categoryKm = data["category_km"]?.toString().toLowerCase() ?? "";

      final matchKeyword =
          keyword.isEmpty ||
          nameEn.contains(keyword) ||
          nameKm.contains(keyword) ||
          province.contains(keyword) ||
          provinceKm.contains(keyword) ||
          categoryEn.contains(keyword) ||
          categoryKm.contains(keyword);

      // -----------------------------
      // Category filter
      // -----------------------------
      bool matchCategory = true;

      if (category.isNotEmpty) {
        if (type == "place") {
          matchCategory = categoryEn == category || categoryKm == category;
        } else if (category == "hotel") {
          matchCategory = type == "hotel";
        } else if (category == "package") {
          matchCategory = type == "package";
        } else {
          matchCategory = false;
        }
      }

      return matchKeyword && matchCategory;
    }).toList();

    searchResults.assignAll(filtered);
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void filterByCategory(Map<String, dynamic> item) {
    selectedCategory.value = item["name"]?.toString().trim() ?? "";

    applyCategoryFilter();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshSearchResults() async {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) {
      currentKeyword = "";
      searchResults.clear();
      return;
    }

    await searchPlaces(keyword);
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearSearch() {
    searchController.clear();
    currentKeyword = "";
    selectedCategory.value = "";
    searchResults.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
