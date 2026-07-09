import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/favorite_service.dart';
import 'package:get/get.dart';

class FavoriteScreenController extends GetxController {
  final FavoriteService favoriteService = FavoriteService();

  RxBool isLoading = false.obs;
  RxList favoriteLists = [].obs;
  RxBool canCreateList = false.obs;


  final TextEditingController createListCtrl = TextEditingController();

  final FocusNode createListFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    createListCtrl.addListener(() {
      canCreateList.value = createListCtrl.text.trim().isNotEmpty;
    });

    getFavoriteLists();
  }

  /// GET FAVORITE LISTS
  Future<void> getFavoriteLists() async {
    try {
      isLoading.value = true;

      final response = await favoriteService.getFavoriteLists();

      print("Get Response: $response");

      favoriteLists.value = response ?? [];
    } catch (e) {
      debugPrint("Get Favorite Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// CREATE FAVORITE LIST
  Future<void> createFavoriteList() async {
    try {
      if (createListCtrl.text.trim().isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter list name",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }

      isLoading.value = true;

      final response = await favoriteService.createFavoriteList(
        capitalizeFirst(createListCtrl.text.trim()),
      );

      print("Create Response: $response");

      createListCtrl.clear();

      await getFavoriteLists();

      print("Favorite Lists: $favoriteLists");

      Get.back();

      Get.snackbar(
        "Success",
        "Favorite list created successfully",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint("Create Favorite Error: $e");

      Get.snackbar(
        "Error",
        "Failed to create favorite list",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }

  final favorites = List.generate(20, (_) => false).obs;  
  void toggleFavorite(int index) {
    favorites[index] = !favorites[index];
  }

  @override
  void onClose() {
    createListCtrl.dispose();
    createListFocusNode.dispose();
    super.onClose();
  }
}
