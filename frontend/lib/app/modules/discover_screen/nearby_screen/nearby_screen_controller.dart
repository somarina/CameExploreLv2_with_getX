import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/category_service.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/place_model.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class NearbyScreenController extends GetxController {
  final PlacesServices service = PlacesServices();
  final CategoryService categoryService = CategoryService();

  final favoriteController = Get.find<FavoriteScreenController>();

  RxBool isLoading = true.obs;

  RxList categories = [].obs;

  RxList<PlaceModel> nearbyPlaces = <PlaceModel>[].obs;

  RxString selectedCategory = ''.obs;

  final List<PlaceModel> _allNearbyPlaces = [];

  static const double nearbyRadiusKm = 10.0;

  @override
  void onInit() async {
    super.onInit();

    getCategories();

    fetchNearbyPlaces();

    await favoriteController.loadFavoriteStatus();   
  }

  // CATEGORY FILTER

  void filterByCategory(String categoryName) {
    if (selectedCategory.value.toLowerCase() == categoryName.toLowerCase()) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = categoryName;
    }

    applyFilters();
  }

  // APPLY ALL FILTERS

  void applyFilters() {
    List<PlaceModel> result = List<PlaceModel>.from(_allNearbyPlaces);

    // Category filter
    if (selectedCategory.value.isNotEmpty) {
      result = result.where((place) {
        return place.category.toLowerCase() ==
            selectedCategory.value.toLowerCase();
      }).toList();
    }

    nearbyPlaces.assignAll(result);
  }

  Future<void> getCategories() async {
    try {
      final response = await categoryService.getCategories();

      if (response["result"] == true) {
        categories.value = response["data"] ?? [];
      }
    } catch (e) {
      debugPrint("Get Categories Error: $e");
    }
  }

  Future<void> fetchNearbyPlaces() async {
    try {
      isLoading.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint("Location service disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          debugPrint("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("Location permission denied forever");
        return;
      }

      Position user = await Geolocator.getCurrentPosition();

      debugPrint(
        "NEARBY USER LOCATION: "
        "${user.latitude}, ${user.longitude}",
      );

      final response = await service.fetchPlaces();

      final List<dynamic> data = (response["data"]?["items"] as List?) ?? [];

      // List<PlaceModel> places = data.map((e) {
      //   final place = PlaceModel.fromJson(e);

      //   debugPrint(
      //     "${place.nameEn}: "
      //     "${place.latitude}, ${place.longitude}",
      //   );

      //   place.distance =
      //       Geolocator.distanceBetween(
      //         user.latitude,
      //         user.longitude,
      //         place.latitude,
      //         place.longitude,
      //       ) /
      //       1000;

      //   debugPrint("${place.nameEn} distance: ${place.distance} km");

      //   return place;
      // }).toList();

      List<PlaceModel> places = data
          .map((e) {
            final place = PlaceModel.fromJson(e);

            place.distance =
                Geolocator.distanceBetween(
                  user.latitude,
                  user.longitude,
                  place.latitude,
                  place.longitude,
                ) /
                1000;

            return place;
          })
          .where((place) {
            return place.distance <= nearbyRadiusKm;
          })
          .toList();

      places.sort((a, b) => a.distance.compareTo(b.distance));

      places.sort((a, b) => a.distance.compareTo(b.distance));

      _allNearbyPlaces
        ..clear()
        ..addAll(places);

      nearbyPlaces.assignAll(places);
    } catch (e) {
      debugPrint("Nearby Places Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPlaces(String keyword) async {
    if (keyword.trim().isEmpty) {
      nearbyPlaces.assignAll(_allNearbyPlaces);

      applyFilters();

      return;
    }

    try {
      isLoading.value = true;

      final response = await service.fetchPlaces(search: keyword);

      if (response["result"] == true) {
        final List data = response["data"]["places"] ?? [];

        List<PlaceModel> result = data
            .map((e) => PlaceModel.fromJson(e))
            .toList();

        nearbyPlaces.assignAll(result);
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
