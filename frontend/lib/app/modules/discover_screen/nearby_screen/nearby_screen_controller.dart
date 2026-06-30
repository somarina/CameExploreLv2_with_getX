import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/services/places_services.dart';

class NearbyScreenController extends GetxController {
  final TextEditingController searchController =
      TextEditingController();

  final PlacesServices _placesServices = PlacesServices();

  RxBool isLoading = false.obs;
  RxList places = [].obs;

  Future<void> searchPlace(String keyword) async {
    try {
      isLoading.value = true;

      final response = await _placesServices.fetchPlaces(
        search: keyword,
      );

      places.value = response['data'] ?? [];
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
