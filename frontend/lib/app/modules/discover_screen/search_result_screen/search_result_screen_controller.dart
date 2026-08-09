// import 'package:flutter/material.dart';
// import 'package:frontend/app/core/api/services/places_services.dart';
// import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
// import 'package:frontend/app/modules/discover_screen/nearby_screen/place_model.dart';
// import 'package:get/get.dart';

// class SearchResultScreenController extends GetxController {

//   final nearbyController = Get.find<NearbyScreenController>();

//   final placesService = PlacesServices();

//   final searchController = TextEditingController();

//   RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
//   final RxList<PlaceModel> allPlaces = <PlaceModel>[].obs;

//   RxBool isLoading = false.obs;
//   final RxString selectedCategory = "".obs;
//   String currentKeyword = "";

//   @override
// void onInit() {
//   super.onInit();

//   loadAllPlaces();
// }

//   Future<void> searchPlaces(String keyword) async {
//     currentKeyword = keyword;

//     applyFilters();
//   }

//   void filterByCategory(Map<String, dynamic> item) {
//     selectedCategory.value = item["name"] ?? "";

//     applyFilters();
//   }

//   // void applyFilters() {
//   //   final keyword = currentKeyword.toLowerCase().trim();

//   //   searchResults.value = nearbyController.nearbyPlaces.where((place) {
//   //     // Search filter
//   //     final matchSearch =
//   //         keyword.isEmpty ||
//   //         place.nameEn.toLowerCase().contains(keyword) ||
//   //         place.nameKm.toLowerCase().contains(keyword) ||
//   //         place.province.toLowerCase().contains(keyword) ||
//   //         place.provinceKm.toLowerCase().contains(keyword);

//   //     // Category filter
//   //     final matchCategory =
//   //         selectedCategory.value.isEmpty ||
//   //         place.category.toLowerCase() == selectedCategory.value.toLowerCase();

//   //     return matchSearch && matchCategory;
//   //   }).toList();
//   // }
//   void applyFilters() {
//   final keyword = currentKeyword.toLowerCase().trim();

//   searchResults.assignAll(
//     allPlaces.where((place) {
//       // Search filter
//       final matchSearch =
//           keyword.isEmpty ||
//           place.nameEn.toLowerCase().contains(keyword) ||
//           place.nameKm.toLowerCase().contains(keyword) ||
//           place.province.toLowerCase().contains(keyword) ||
//           place.provinceKm.toLowerCase().contains(keyword);

//       // Category filter
//       final matchCategory =
//           selectedCategory.value.isEmpty ||
//           place.category.toLowerCase() ==
//               selectedCategory.value.toLowerCase();

//       return matchSearch && matchCategory;
//     }),
//   );
// }

// Future<void> loadAllPlaces() async {
//   try {
//     final response = await placesService.fetchPlaces();

//     final List<dynamic> data = response["data"] ?? response;

//     allPlaces.assignAll(
//       data.map((json) => PlaceModel.fromJson(json)).toList(),
//     );

//     applyFilters();
//   } catch (e) {
//     print("Error loading all places: $e");
//   }
// }

//   Future<void> refreshSearchResults() async {
//     final keyword = searchController.text.trim();

//     if (keyword.trim().isEmpty) {
//       currentKeyword = "";
//       applyFilters();
//       return;
//     }

//     await searchPlaces(keyword);
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/hotels_services.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/core/api/services/search_service.dart';
import 'package:frontend/app/core/api/services/travel_package_services.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
import 'package:get/get.dart';

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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is String) {
      currentKeyword = Get.arguments.toString();
      searchController.text = currentKeyword;

      if (currentKeyword.isNotEmpty) {
        searchPlaces(currentKeyword);
      }
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> searchPlaces(String keyword) async {
    currentKeyword = keyword.trim();

    // if (currentKeyword.isEmpty) {
    //   searchResults.clear();
    //   return;
    // }
    if (currentKeyword.isEmpty) {
    searchResults.clear();
    allSearchResults.clear();
    return;
  }

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

  // void applyCategoryFilter() {
  //   final category = selectedCategory.value.trim().toLowerCase();

  //   if (category.isEmpty) {
  //     searchResults.assignAll(allSearchResults);
  //     return;
  //   }

  //   final filtered = allSearchResults.where((item) {
  //     final data = item["data"];

  //     if (data is! Map) {
  //       return false;
  //     }

  //     final itemCategory =
  //         data["category"]?.toString().trim().toLowerCase() ?? "";

  //     final itemCategoryKm =
  //         data["category_km"]?.toString().trim().toLowerCase() ?? "";

  //     return itemCategory == category || itemCategoryKm == category;
  //   }).toList();

  //   searchResults.assignAll(filtered);

  //   print("========================================");
  //   print("CATEGORY FILTER: ${selectedCategory.value}");
  //   print("RESULTS AFTER FILTER: ${searchResults.length}");
  //   print("========================================");
  // }

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
        matchCategory =
            categoryEn == category ||
            categoryKm == category;
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
