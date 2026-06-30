import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/favorite_service.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:get/get.dart';

class FavScreen2ViewController extends GetxController {
  final FavoriteService favoriteService = FavoriteService();

  RxString listName = ''.obs;
  RxString listId = ''.obs;
  RxBool canRename = false.obs;
  RxList favoriteItems = [].obs;

  var renameCtrl = TextEditingController();
  FocusNode renameFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    listName.value = Get.arguments['listName'] ?? '';
    listId.value = Get.arguments['listId'] ?? '';

    renameCtrl.addListener(() {
      canRename.value = renameCtrl.text.trim().isNotEmpty;
    });
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

      Get.snackbar("Error", "Failed to delete list", snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,);
    }
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
