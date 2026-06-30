import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/services/places_services.dart';

class SearchScreenController extends GetxController {

  final PlacesServices _placesServices = PlacesServices();
  RxBool isLoading = false.obs;

  RxList mostSearchPlaces = [].obs;
  RxList popularPlaces = [].obs;

  @override
  void onInit() {
    super.onInit();
    getDiscoverHome();
  }

  Future<void> getDiscoverHome() async {
  try {
    isLoading.value = true;

    final response =
        await _placesServices.fetchDiscoverHome();

    mostSearchPlaces.value =
        response['data']['most_search'] ?? [];

    popularPlaces.value =
        response['data']['popular_places'] ?? [];
  } catch (e) {
    debugPrint(e.toString());
  } finally {
    isLoading.value = false;
  }
}
}
