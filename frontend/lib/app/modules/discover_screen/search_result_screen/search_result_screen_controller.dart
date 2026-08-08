import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/place_model.dart';
import 'package:get/get.dart';

class SearchResultScreenController extends GetxController {
  final nearbyController = Get.find<NearbyScreenController>();

  final placesService = PlacesServices();

  final searchController = TextEditingController();

  RxList<PlaceModel> searchResults = <PlaceModel>[].obs;

  RxBool isLoading = false.obs;
  final RxString selectedCategory = "".obs;
  String currentKeyword = "";

  Future<void> searchPlaces(String keyword) async {
    currentKeyword = keyword;

    applyFilters();
  }

  void filterByCategory(Map<String, dynamic> item) {
    selectedCategory.value = item["name"] ?? "";

    applyFilters();
  }

  void applyFilters() {
    final keyword = currentKeyword.toLowerCase().trim();

    searchResults.value = nearbyController.nearbyPlaces.where((place) {
      // Search filter
      final matchSearch =
          keyword.isEmpty ||
          place.nameEn.toLowerCase().contains(keyword) ||
          place.nameKm.toLowerCase().contains(keyword) ||
          place.province.toLowerCase().contains(keyword) ||
          place.provinceKm.toLowerCase().contains(keyword);

      // Category filter
      final matchCategory =
          selectedCategory.value.isEmpty ||
          place.category.toLowerCase() == selectedCategory.value.toLowerCase();

      return matchSearch && matchCategory;
    }).toList();
  }

  Future<void> refreshSearchResults() async {
    final keyword = searchController.text.trim();

    if (keyword.trim().isEmpty) {
      currentKeyword = "";
      applyFilters();
      return;
    }

    await searchPlaces(keyword);
  }
}
