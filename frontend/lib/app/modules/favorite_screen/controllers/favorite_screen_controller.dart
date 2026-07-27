import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/favorite_service.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreenController extends GetxController {
  final FavoriteService favoriteService = FavoriteService();

  RxBool isLoading = false.obs;
  RxList favoriteLists = [].obs;
  RxBool canCreateList = false.obs;
  RxList favoriteItems = [].obs;
  RxString selectedListId = "".obs;
  String currentListId = "";

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

  RxMap<String, String> placeListMap = <String, String>{}.obs;

  bool isFavorite(String placeId) {
    return placeListMap.containsKey(placeId);
  }

  void showSavedSnackbar(
    String placeId,
    BuildContext context,
    String listName,
  ) {
    Get.snackbar(
      "Saved",
      "Added to $listName",
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          showSelectListBottomSheet(placeId, context);
        },
        child: const Text("Change"),
      ),
    );
  }

  void showSelectListBottomSheet(String placeId, BuildContext context) {
    final currentListId = placeListMap[placeId];

    final List<Map<String, dynamic>> sortedLists = [...favoriteLists];

    if (currentListId != null) {
      sortedLists.sort((a, b) {
        if (a["id"].toString() == currentListId) return -1;
        if (b["id"].toString() == currentListId) return 1;
        return 0;
      });
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Text(
                      "Cancel".tr,
                      style: AppFonts.fontsGeneral.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "Select a list".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      Get.back();

                      Future.delayed(const Duration(milliseconds: 200), () {
                        AppBottomSheets.showBottomSheet(
                          title: "Create a new list".tr,
                          label: "list name".tr,
                        );
                      });
                    },
                    icon: Icon(
                      Icons.add,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: sortedLists.length + 1,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  if (index == sortedLists.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();

                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () {
                                AppBottomSheets.showBottomSheet(
                                  title: "Create a new list".tr,
                                  label: "list name".tr,
                                );
                              },
                            );
                          },
                          child: Text("Create a new list".tr),
                        ),
                      ),
                    );
                  }

                  final list = sortedLists[index];

                  return Obx(() {
                    final isSelected =
                        placeListMap[placeId] == list["id"].toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        movePlaceToList(
                          placeId,
                          list["id"].toString(),
                          list["name"].toString(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(Icons.image_outlined),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                list["name"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if (isSelected)
                              Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> movePlaceToList(
    String placeId,
    String listId,
    String listName,
  ) async {
    try {
      final currentList = placeListMap[placeId];

      // Already in this list
      if (currentList == listId) {
        Get.back();

        Get.snackbar(
          "Already saved",
          "This place is already in '$listName'.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Move from old list to new list
      if (currentList != null) {
        await favoriteService.deleteFavoriteItem(
          listId: currentList,
          placeId: placeId,
        );
      }

      await favoriteService.addFavoriteItem(listId: listId, placeId: placeId);

      placeListMap[placeId] = listId;
      placeListMap.refresh();

      if (currentListId == currentList) {
        await getFavoriteItems(currentList!);
      }

      if (currentListId == listId) {
        await getFavoriteItems(listId);
      }

      Get.back();

      showSavedSnackbar(placeId, Get.context!, listName);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to move place",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleFavorite(String placeId, BuildContext context) async {
    if (isFavorite(placeId)) {
      final listId = placeListMap[placeId]!;

      placeListMap.remove(placeId);
      placeListMap.refresh();

      await deleteFavorite(listId: listId, placeId: placeId);

      Get.snackbar(
        "Removed",
        "Removed from favorites",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      showSelectListBottomSheet(placeId, context);
    }
  }

  Future<void> getFavoriteItems(String listId) async {
    currentListId = listId;

    final response = await favoriteService.getFavoriteItems(listId);

    favoriteItems.value = response ?? [];
  }

  Future<void> deleteFavorite({
    required String listId,
    required String placeId,
  }) async {
    print("Delete List ID: $listId");
    print("Delete Place ID: $placeId");

    await favoriteService.deleteFavoriteItem(listId: listId, placeId: placeId);

    await getFavoriteItems(listId);
  }

  Future<void> loadFavoriteStatus() async {
    placeListMap.clear();

    await getFavoriteLists();

    for (final list in favoriteLists) {
      final items = await favoriteService.getFavoriteItems(
        list["id"].toString(),
      );

      for (final item in items) {
        placeListMap[item["place_id"].toString()] = list["id"].toString();
      }
    }
  }

  @override
  void onClose() {
    createListCtrl.dispose();
    createListFocusNode.dispose();
    super.onClose();
  }
}
