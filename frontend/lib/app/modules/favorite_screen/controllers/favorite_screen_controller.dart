import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/favorite_service.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

enum FavoriteItemType { place, hotel, package }

class FavoriteScreenController extends GetxController {
  final FavoriteService favoriteService = FavoriteService();

  RxBool isLoading = false.obs;
  RxList favoriteLists = [].obs;
  RxBool canCreateList = false.obs;
  RxList favoriteItems = [].obs;
  RxString selectedListId = "".obs;
  String currentListId = "";
  RxMap<String, int> activityCounts = <String, int>{}.obs;
  RxMap<String, String> listImages = <String, String>{}.obs;

  final TextEditingController createListCtrl = TextEditingController();

  final FocusNode createListFocusNode = FocusNode();
  final box = GetStorage();

  bool get isGuest => box.read("token") == null;

  @override
  void onInit() {
    super.onInit();

    createListCtrl.addListener(() {
      canCreateList.value = createListCtrl.text.trim().isNotEmpty;
    });

    // getFavoriteLists();
    loadFavoriteStatus();
  }

  @override
  void onReady() async {
    super.onReady();
    loadFavoriteStatus();

    await getFavoriteLists();
  }

  /// GET FAVORITE LISTS
  // Future<void> getFavoriteLists() async {
  //   try {
  //     isLoading.value = true;

  //     final response = await favoriteService.getFavoriteLists();

  //     favoriteLists.value = response ?? [];

  //     // activityCounts.clear();
  //     // listImages.clear();

  //     for (final list in favoriteLists) {
  //       final listId = list["id"].toString();

  //       final items = await favoriteService.getFavoriteItems(listId);

  //       activityCounts[listId] = items.length;

  //       if (items.isNotEmpty) {
  //         // Pick a random image
  //         final random = Random();

  //         list["cover_image"] =
  //             items[random.nextInt(items.length)]["image_url"];
  //       } else {
  //         list["cover_image"] = null;
  //       }
  //     }

  //     activityCounts.refresh();
  //     listImages.refresh();
  //   } catch (e) {
  //     debugPrint("Get Favorite Error: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> getFavoriteLists() async {
    try {
      isLoading.value = true;

      final response = await favoriteService.getFavoriteLists();

      favoriteLists.value = response ?? [];

      activityCounts.clear();

      for (final list in favoriteLists) {
        final listId = list["id"].toString();

        final response = await favoriteService.getFavoriteItems(listId);

        final items = response["data"] ?? [];

        if (items.isNotEmpty) {
          final random = Random();

          list["cover_image"] =
              items[random.nextInt(items.length)]["image_url"];
        } else {
          list["cover_image"] = null;
        }

        activityCounts[listId] = items.length;
      }

      activityCounts.refresh();
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

  RxMap<String, dynamic> favoriteItemsMap = <String, dynamic>{}.obs;

  bool isFavorite(String itemId, FavoriteItemType itemType) {
    final key = "${itemType.name}_$itemId";
    return favoriteItemsMap.containsKey(key);
  }

  void showSavedSnackbar(
    String itemId,
    FavoriteItemType itemType,
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

          showSelectListBottomSheet(itemId, itemType, context);
        },
        child: Text("Change"),
      ),
    );
  }

  void showSelectListBottomSheet(
    String itemId,
    FavoriteItemType itemType,
    BuildContext context,
  ) {
    final key = "${itemType.name}_$itemId";

    final currentListId = favoriteItemsMap[key];

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      // if (isGuest) {
                      //   _showLoginDialog(context);
                      //   return;
                      // }
                      if (isGuest) {
                        _showLoginDialog(
                          context,
                        ); // _showLoginDialog(context)
                        return;
                      }
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
                  // Create new list button
                  if (index == sortedLists.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
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
                          child: Text(
                            "Create a new list".tr,
                            style: GoogleFonts.googleSans(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final list = sortedLists[index];

                  return Obx(() {
                    final isSelected =
                        favoriteItemsMap[key] == list["id"].toString();
                    final theme = Theme.of(context);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),

                      onTap: () {
                        moveItemToList(
                          itemId,
                          itemType,
                          list["id"].toString(),
                          list["name"].toString(),
                          context,
                        );
                      },

                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: list["cover_image"] == null
                                  ? const Icon(Icons.image_outlined)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        list["cover_image"],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),

                            SizedBox(width: 16),

                            Expanded(
                              child: Obx(() {
                                final listId = list["id"]?.toString() ?? "";
                                final count = activityCounts[listId] ?? 0;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: SizedBox(
                                    width: 200,
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      list["name"]?.toString() ?? "",
                                      style: AppFonts.fontsGeneral.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    "$count ${count == 1 ? 'activity' : 'activities'}",
                                    style: AppFonts.fontDescriptionsmall
                                        .copyWith(
                                          color:
                                              theme.textTheme.titleSmall?.color,
                                        ),
                                  ),
                                );
                              }),
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

  void _showLoginDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          "Login Required".tr,
          style: AppFonts.fontHeader.copyWith(
            fontSize: 18,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        content: Text(
          "Please log in or create an account to save items to your favorites."
              .tr,
          style: AppFonts.fontDescription.copyWith(
            color: Theme.of(context).textTheme.titleSmall!.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel".tr,
              style: GoogleFonts.googleSans(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed("/login-screen");
            },
            child: Text("Login".tr),
          ),
        ],
      ),
    );
  }

  // Future<void> moveItemToList(
  //   String itemId,
  //   FavoriteItemType itemType,
  //   String listId,
  //   String listName,
  //   BuildContext context,
  // ) async {
  //   final key = "${itemType.name}_$itemId";

  //   try {
  //     await favoriteService.addFavoriteItem(
  //       listId: listId,
  //       itemId: itemId,
  //       type: itemType,
  //     );

  //     // await getFavoriteLists();

  //     // favoriteItemsMap[key] = listId;
  //     // favoriteItemsMap.refresh();
  //     await favoriteService.addFavoriteItem(
  //       listId: listId,
  //       itemId: itemId,
  //       type: itemType,
  //     );

  //     // update count immediately
  //     activityCounts[listId] = (activityCounts[listId] ?? 0) + 1;

  //     activityCounts.refresh();

  //     favoriteItemsMap[key] = listId;
  //     favoriteItemsMap.refresh();

  //     await getFavoriteLists();

  //     Get.back();

  //     showSavedSnackbar(itemId, itemType, context, listName);
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  Future<void> moveItemToList(
    String itemId,
    FavoriteItemType itemType,
    String listId,
    String listName,
    BuildContext context,
  ) async {
    final key = "${itemType.name}_$itemId";

    print("ADDING FAVORITE KEY: $key");

    try {
      await favoriteService.addFavoriteItem(
        listId: listId,
        itemId: itemId,
        type: itemType,
      );

      favoriteItemsMap[key] = listId;

      favoriteItemsMap.refresh();

      print("UPDATED MAP:");
      print(favoriteItemsMap);

      await getFavoriteLists();

      Get.back();

      showSavedSnackbar(itemId, itemType, context, listName);
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleFavorite(
    String itemId,
    FavoriteItemType itemType,
    BuildContext context,
  ) async {
    if (isGuest) {
      _showLoginDialog(context);
      return;
    }
    final key = "${itemType.name}_$itemId";

    if (isFavorite(itemId, itemType)) {
      final listId = favoriteItemsMap[key];

      if (listId == null) return;

      favoriteItemsMap.remove(key);
      favoriteItemsMap.refresh();

      await deleteFavorite(listId: listId, itemId: itemId);

      Get.snackbar(
        "Removed",
        "Removed from favorites",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      showSelectListBottomSheet(itemId, itemType, context);
    }
  }

  Future<void> getFavoriteItems(String listId) async {
    try {
      final response = await favoriteService.getFavoriteItems(listId);

      print("Favorite response: $response");

      if (response["result"] == true) {
        final data = response["data"];

        if (data is List) {
          favoriteItems.assignAll(List<Map<String, dynamic>>.from(data));

          // Update favorite status map
          favoriteItemsMap.clear();

          for (var item in favoriteItems) {
            final itemId = item["id"]?.toString();
            final itemType = item["item_type"]?.toString();

            if (itemId != null && itemType != null) {
              final key = "${itemType}_$itemId";

              favoriteItemsMap[key] = listId;
            }
          }

          favoriteItemsMap.refresh();

          // Update activity count for this list
          activityCounts[listId] = favoriteItems.length;
          activityCounts.refresh();
        } else {
          favoriteItems.clear();

          favoriteItemsMap.clear();

          activityCounts[listId] = 0;

          activityCounts.refresh();
        }

        print("Favorite count: ${favoriteItems.length}");
        print("Activity count: ${activityCounts[listId]}");
      } else {
        favoriteItems.clear();

        activityCounts[listId] = 0;

        activityCounts.refresh();
      }
    } catch (e) {
      print("Get Favorite Error: $e");
    }
  }

  Future<void> deleteFavorite({
    required String listId,
    required String itemId,
  }) async {
    try {
      print("Delete List ID: $listId");
      print("Delete Item ID: $itemId");

      await favoriteService.deleteFavoriteItem(listId: listId, itemId: itemId);

      await getFavoriteItems(listId);
      await getFavoriteLists();
    } catch (e) {
      print("Delete favorite error: $e");
    }
  }

  // Future<void> loadFavoriteStatus() async {
  //   favoriteItemsMap.clear();

  //   await getFavoriteLists();

  //   for (final list in favoriteLists) {
  //     final items = await favoriteService.getFavoriteItems(
  //       list["id"].toString(),
  //     );

  //     for (final item in items) {
  //       favoriteItemsMap["place_${item["place_id"]}"] = list["id"].toString();
  //     }
  //   }
  // }

  Future<void> loadFavoriteStatus() async {
    favoriteItemsMap.clear();

    await getFavoriteLists();

    for (final list in favoriteLists) {
      final response = await favoriteService.getFavoriteItems(
        list["id"].toString(),
      );

      if (response["result"] == true) {
        final items = response["data"] ?? [];

        for (final item in items) {
          final id = item["id"]?.toString();
          final type = item["item_type"]?.toString();

          if (id != null && type != null) {
            favoriteItemsMap["${type}_$id"] = list["id"].toString();
          }
        }
      }
    }

    favoriteItemsMap.refresh();

    print("Favorite map: $favoriteItemsMap");
  }

  @override
  void onClose() {
    createListCtrl.dispose();
    createListFocusNode.dispose();
    super.onClose();
  }
}
