import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/favorite_service.dart';
import 'package:frontend/app/core/api/services/hotels_services.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/core/api/services/travel_package_services.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:get/get.dart';

class FavScreen2ViewController extends GetxController {
  final FavoriteService favoriteService = FavoriteService();
  final favoriteController = Get.find<FavoriteScreenController>();
  final placesService = PlacesServices();
  final hotelService = HotelServices();
  final travelPackagesSservice = TravelPackageServices();

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

    renameCtrl.addListener(() {
      canRename.value = renameCtrl.text.trim().isNotEmpty;

      print("RENAME TEXT: ${renameCtrl.text}");
      print("CAN RENAME: ${canRename.value}");
    });

    getFavoriteItems();
  }

  @override
  void onClose() {
    renameCtrl.dispose();
    renameFocusNode.dispose();
    super.onClose();
  }

  Future<void> getFavoriteItems() async {
    try {
      isLoading.value = true;
      final stopwatch = Stopwatch()..start();

      final response = await favoriteService.getFavoriteItems(listId.value);

      stopwatch.stop();

      print(
        "🔥 GET FAVORITE ITEMS TOOK: "
        "${stopwatch.elapsedMilliseconds} ms",
      );

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
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final id = listId.value;

      final response = await favoriteService.deleteFavoriteList(id);

      print("Delete Response: $response");

      final favoriteController = Get.find<FavoriteScreenController>();

      // Remove locally — no need to reload from API
      favoriteController.favoriteLists.removeWhere(
        (list) => list["id"]?.toString() == id,
      );

      favoriteController.activityCounts.remove(id);
      favoriteController.listImages.remove(id);

      favoriteController.favoriteLists.refresh();
      favoriteController.activityCounts.refresh();
      favoriteController.listImages.refresh();

      Get.back();
    } catch (e) {
      debugPrint("Delete Error: $e");

      Get.snackbar(
        "Error",
        "Failed to delete list",
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

  String buildShareText() {
    final buffer = StringBuffer();

    buffer.writeln(listName.value);
    buffer.writeln();

    if (favoriteItems.isEmpty) {
      buffer.writeln("This list is empty.");
      return buffer.toString();
    }

    for (int i = 0; i < favoriteItems.length; i++) {
      final item = favoriteItems[i];

      final name = item["name"]?.toString() ?? "Unknown";
      final province = item["province"]?.toString() ?? "";

      buffer.writeln("${i + 1}. $name");

      if (province.isNotEmpty) {
        buffer.writeln("   $province");
      }

      buffer.writeln();
    }

    return buffer.toString().trim();
  }
}
