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

  // your existing methods...

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

    places.assignAll(response);
  } catch (e) {
    debugPrint("Get Places Error: $e");
  } finally {
    isLoading.value = false;
  }
}

  Future<void> fetchNearbyPlaces() async {
    try {
      isLoading(true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position user = await Geolocator.getCurrentPosition();

      print(user.latitude);
      print(user.longitude);

      final response = await service.getPlaces();

      List<PlaceModel> places = response.map<PlaceModel>((e) {
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
      print(e);
    } finally {
      isLoading(false);
    }
  }
}
