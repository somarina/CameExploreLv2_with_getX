import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/category_service.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/place_model.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/api/services/places_services.dart';

class NearbyScreenController extends GetxController {
  final PlacesServices service = PlacesServices();
  final CategoryService categoryService = CategoryService();

  final favoriteController = Get.find<FavoriteScreenController>();

  final TextEditingController searchController = TextEditingController();

  RxBool isLoading = true.obs;
  RxList places = [].obs;
  RxList categories = [].obs;

  RxList<PlaceModel> nearbyPlaces = <PlaceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyPlaces();
    getPlaces();
    getCategories();
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

  Future<void> getPlaces() async {
    try {
      isLoading.value = true;

      final response = await service.fetchPlaces();

      print("Response type: ${response.runtimeType}");
      print("Response: $response");

      if (response is Map<String, dynamic>) {
        print("Data type: ${response["data"].runtimeType}");
      }
    } catch (e) {
      debugPrint("Get Places Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNearbyPlaces() async {
    try {
      isLoading.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position user = await Geolocator.getCurrentPosition();

      final response = await service.fetchPlaces();

      final List<dynamic> data = (response["data"]?["items"] as List?) ?? [];

      List<PlaceModel> places = data.map((e) {
        PlaceModel place = PlaceModel.fromJson(e);

        place.distance =
            Geolocator.distanceBetween(
              user.latitude,
              user.longitude,
              place.latitude,
              place.longitude,
            ) /
            1000;

        return place;
      }).toList();

      places.sort((a, b) => a.distance.compareTo(b.distance));

      nearbyPlaces.assignAll(places);
    } catch (e) {
      debugPrint("Nearby Places Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPlaces(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        fetchNearbyPlaces();
        return;
      }

      isLoading.value = true;

      final response = await service.fetchPlaces(search: keyword);

      if (response["result"] == true) {
        final List<dynamic> data = response["data"]["places"] ?? [];

        nearbyPlaces.assignAll(
          data.map((e) => PlaceModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onSearchChanged(String value) async {
    if (value.trim().isEmpty) {
      fetchNearbyPlaces();
      return;
    }

    await searchPlaces(value);
  }
}
