import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/favorite_service.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:get/get.dart';

class FavScreen2ViewController extends GetxController {
  final FavoriteService favoriteService = FavoriteService();
  final favoriteController = Get.find<FavoriteScreenController>();

  RxString listName = ''.obs;
  RxString listId = ''.obs;
  RxBool canRename = false.obs;
  RxList favoriteItems = [].obs;

  RxBool isLoading = false.obs;
  RxList favoriteLists = [].obs;

  var renameCtrl = TextEditingController();
  FocusNode renameFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    print("Arguments: ${Get.arguments}");

    listName.value = Get.arguments['listName'] ?? '';
    listId.value = Get.arguments['listId'] ?? '';

    print("List ID: ${listId.value}");

    getFavoriteItems();
  }

  Future<void> getFavoriteItems() async {
    try {
      isLoading.value = true;

      final response = await favoriteService.getFavoriteItems(listId.value);

      print("Fav2 response: $response");

      if (response["result"] == true) {
        final data = response["data"];

        if (data is List) {
          favoriteItems.assignAll(data);
        } else {
          favoriteItems.clear();
        }
      }

      print("Fav2 count: ${favoriteItems.length}");
    } catch (e) {
      print("Fav2 get error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renameFavoriteList() async {
    try {
      if (renameCtrl.text.trim().isEmpty) return;

      final newName = capitalizeFirst(renameCtrl.text.trim());

      await favoriteService.renameFavoriteList(
        listId: listId.value,
        name: newName,
      );

      listName.value = newName;

      // Refresh previous screen
      Get.find<FavoriteScreenController>().getFavoriteLists();

      renameCtrl.clear();

      Get.back();

      Get.snackbar(
        'Success',
        'List renamed successfully',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint(e.toString());

      Get.snackbar(
        'Error',
        'Failed to rename list',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> deleteFavoriteList() async {
    try {
      final response = await favoriteService.deleteFavoriteList(listId.value);

      print("Delete Response: $response");

      // Refresh previous screen
      Get.find<FavoriteScreenController>().getFavoriteLists();

      Get.back(); // Close current screen

      // Get.snackbar("Success", "List deleted successfully", snackPosition: SnackPosition.BOTTOM,
      //   colorText: Colors.white,
      //   backgroundColor: Colors.green,);
    } catch (e) {
      debugPrint("Delete Error: $e");

      Get.snackbar(
        "Error",
        "Failed to delete list",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> deleteFavorite(String itemId, FavoriteItemType itemType) async {
    await favoriteService.deleteFavoriteItem(
      listId: listId.value,
      itemId: itemId,
    );

    favoriteItems.removeWhere(
      (item) =>
          item["id"].toString() == itemId && item["item_type"] == itemType.name,
    );

    favoriteItems.refresh();

    favoriteController.favoriteItemsMap.remove("${itemType.name}_$itemId");

    favoriteController.favoriteItemsMap.refresh();

    await favoriteController.getFavoriteLists();
  }
}
