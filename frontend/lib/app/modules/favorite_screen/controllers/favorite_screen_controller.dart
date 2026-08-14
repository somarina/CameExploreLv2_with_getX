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

  String? pendingItemId;
  FavoriteItemType? pendingItemType;
  BuildContext? pendingContext;

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

    loadFavoriteStatus();
  }

  /// GET FAVORITE LISTS
  Future<void> getFavoriteLists() async {
    try {
      isLoading.value = true;

      final response = await favoriteService.getFavoriteLists();

      // favoriteLists.value = response ?? [];
      favoriteLists.value = List<Map<String, dynamic>>.from(response ?? []);

      // Remove counts for deleted lists
      final validIds = favoriteLists
          .map((list) => list["id"].toString())
          .toSet();

      activityCounts.removeWhere((key, value) => !validIds.contains(key));

      // for (var i = 0; i < favoriteLists.length; i++) {
      //   final list = favoriteLists[i];

      //   final listId = list["id"].toString();

      //   final itemResponse = await favoriteService.getFavoriteItems(listId);

      //   final items = itemResponse["data"] ?? [];

      //   favoriteLists[i]["cover_image"] = items.isNotEmpty
      //       ? items.first["image_url"]
      //       : null;

      //   activityCounts[listId] = items.length;
      // }
      // // Notify GetX about changes
      // favoriteLists.refresh();
      // activityCounts.refresh();

      // print("Final activityCounts: $activityCounts");
      for (var i = 0; i < favoriteLists.length; i++) {
        final list = favoriteLists[i];
        final listId = list["id"].toString();

        final itemResponse = await favoriteService.getFavoriteItems(listId);

        final items = itemResponse["data"] is List
            ? itemResponse["data"] as List
            : [];

        favoriteLists[i]["cover_image"] = items.isNotEmpty
            ? items.first["image_url"]
            : null;

        activityCounts[listId] = items.length;
      }

      favoriteLists.refresh();
      activityCounts.refresh();

      print("Final activityCounts: $activityCounts");
    } catch (e) {
      debugPrint("Get Favorite Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// CREATE FAVORITE LIST
  Future createFavoriteList() async {
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

      final newListName = capitalizeFirst(createListCtrl.text.trim());

      // Create list
      final response = await favoriteService.createFavoriteList(newListName);

      print("Create Response: $response");

      final newListId = response["list_id"]?.toString();

      if (newListId == null || newListId.isEmpty) {
        throw Exception("New list ID is missing");
      }

      // Add pending item
      if (pendingItemId != null && pendingItemType != null) {
        // Save values before closing anything
        final savedItemId = pendingItemId!;
        final savedItemType = pendingItemType!;
        final savedContext = pendingContext;

        // IMPORTANT: actually add item to new list
        await favoriteService.addFavoriteItem(
          listId: newListId,
          itemId: savedItemId,
          type: savedItemType,
        );

        // Update local state immediately
        activityCounts[newListId] = 1;
        activityCounts.refresh();

        final key = "${savedItemType.name}_$savedItemId";

        favoriteItemsMap[key] = newListId;
        favoriteItemsMap.refresh();

        // Clear pending values
        pendingItemId = null;
        pendingItemType = null;
        pendingContext = null;

        // Close CREATE LIST bottom sheet
        // Get.back();

        // Show snackbar after sheet closes
        if (savedContext != null) {
          Future.delayed(const Duration(milliseconds: 150), () {
            showSavedSnackbar(
              savedItemId,
              savedItemType,
              savedContext,
              newListName,
            );
          });
        }
      }

      // Clear text
      createListCtrl.clear();

      // Add new list locally
      favoriteLists.add({
        "id": newListId,
        "name": newListName,
        "cover_image": null,
      });

      favoriteLists.refresh();

      // Refresh counts/images WITHOUT blocking snackbar
      getFavoriteLists();

      print("Favorite Lists: $favoriteLists");
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
    favoriteItemsMap[key];
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

          Future.delayed(const Duration(milliseconds: 100), () {
            showSelectListBottomSheet(itemId, itemType, Get.context!);
          });
        },
        child: const Text("Change"),
      ),
    );
  }

  void showSelectListBottomSheet(
    String itemId,
    FavoriteItemType itemType,
    BuildContext context,
  ) {
    pendingItemId = itemId;
    pendingItemType = itemType;
    pendingContext = context;

    final key = "${itemType.name}_$itemId";

    final currentListId = favoriteItemsMap[key];

    // final List<Map<String, dynamic>> sortedLists = [...favoriteLists];
    final sortedLists = [...favoriteLists];

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
                      if (isGuest) {
                        showLoginDialog(context); // _showLoginDialog(context)
                        return;
                      }
                      final savedItemId = pendingItemId;
                      final savedItemType = pendingItemType;
                      final savedContext = pendingContext;

                      Get.back();

                      Future.delayed(const Duration(milliseconds: 100), () {
                        pendingItemId = savedItemId;
                        pendingItemType = savedItemType;
                        pendingContext = savedContext;

                        AppBottomSheets.showBottomSheet(
                          title: "Create a new list".tr,
                          label: "List name".tr,
                          controller: createListCtrl,
                          focusNode: createListFocusNode,
                          mode: BottomSheetMode.create,
                          onDone: () async {
                            if (isLoading.value) return;

                            await createFavoriteList();

                            Get.back();
                          },
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

            Obx(() {
              final sortedLists = [...favoriteLists];
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Expanded(
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

                              // Future.delayed(Duration(milliseconds: 100), () {
                              //   AppBottomSheets.showBottomSheet(
                              //     title: "Create a new list".tr,
                              //     label: "list name".tr,
                              //     controller: createListCtrl,
                              //     focusNode: createListFocusNode,
                              //     onDone: () async {
                              //       await createFavoriteList();
                              //     },
                              //   );
                              // });
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  AppBottomSheets.showBottomSheet(
                                    title: "Create a list".tr,
                                    controller: createListCtrl,
                                    focusNode: createListFocusNode,
                                    mode: BottomSheetMode.create,
                                    label: "List name".tr,
                                    onDone: () async {
                                      if (isLoading.value) return;
                                      Get.back();
                                      await createFavoriteList();
                                    },
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

                        onTap: () async {
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
                                  print("UI listId: $listId");
                                  print("UI count: ${activityCounts[listId]}");
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
                                            color: theme
                                                .textTheme
                                                .titleSmall
                                                ?.color,
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
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showLoginDialog(BuildContext context) {
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

  Future moveItemToList(
    String itemId,
    FavoriteItemType itemType,
    String listId,
    String listName,
    BuildContext context,
  ) async {
    final key = "${itemType.name}_$itemId";

    try {
      isLoading.value = true;
      final oldListId = favoriteItemsMap[key];

      // Already in this list
      if (oldListId == listId) {
        Get.back();
        return;
      }

      // Remove from old list
      if (oldListId != null) {
        await favoriteService.deleteFavoriteItem(
          listId: oldListId.toString(),
          itemId: itemId,
        );
      }

      // Add to new list
      await favoriteService.addFavoriteItem(
        listId: listId,
        itemId: itemId,
        type: itemType,
      );

      // Update local state immediately
      favoriteItemsMap[key] = listId;
      favoriteItemsMap.refresh();

      // Close bottom sheet
      Get.back();

      // Show snackbar immediately
      showSavedSnackbar(itemId, itemType, context, listName);

      // Refresh counts/images in background
      if (oldListId != null) {
        updateSingleFavoriteList(oldListId.toString());
      }

      updateSingleFavoriteList(listId);
    } catch (e) {
      print("Move item error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSingleFavoriteList(String listId) async {
    try {
      final itemResponse = await favoriteService.getFavoriteItems(listId);

      final items = itemResponse["data"] ?? [];

      final index = favoriteLists.indexWhere(
        (list) => list["id"].toString() == listId,
      );

      if (index != -1) {
        favoriteLists[index]["cover_image"] = items.isNotEmpty
            ? items.first["image_url"]
            : null;

        activityCounts[listId] = items.length;

        favoriteLists.refresh();
        activityCounts.refresh();
      }
    } catch (e) {
      print("Update single list error: $e");
    }
  }

  Future<void> toggleFavorite(
    String itemId,
    FavoriteItemType itemType,
    BuildContext context,
  ) async {
    if (isGuest) {
      showLoginDialog(context);
      return;
    }
    final key = "${itemType.name}_$itemId";

    // if (isFavorite(itemId, itemType)) {
    //   final listId = favoriteItemsMap[key];

    //   if (listId == null) return;

    //   favoriteItemsMap.remove(key);
    //   favoriteItemsMap.refresh();

    //   await deleteFavorite(listId: listId, itemId: itemId);

    //   Get.snackbar(
    //     "Removed",
    //     "Removed from favorites",
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
    if (isFavorite(itemId, itemType)) {
      final listId = favoriteItemsMap[key];

      if (listId == null) return;

      // Update UI immediately
      favoriteItemsMap.remove(key);
      favoriteItemsMap.refresh();

      // Show feedback immediately
      Get.snackbar(
        "Removed",
        "Removed from favorites",
        snackPosition: SnackPosition.BOTTOM,
      );

      // Delete in background
      deleteFavorite(listId: listId, itemId: itemId);
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
          final items = List<Map<String, dynamic>>.from(data);

          for (var item in items) {
            final itemId = item["id"]?.toString();
            final itemType = item["item_type"]?.toString();

            if (itemId != null && itemType != null) {
              favoriteItemsMap["${itemType}_$itemId"] = listId;
            }
          }

          favoriteItemsMap.refresh();

          activityCounts[listId] = items.length;
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

      // Remove item locally
      favoriteItems.removeWhere((item) => item["id"]?.toString() == itemId);

      // Update activity count immediately
      final currentCount = activityCounts[listId] ?? 0;

      if (currentCount > 0) {
        activityCounts[listId] = currentCount - 1;
      }

      // If list is now empty, remove its cover image too
      if ((activityCounts[listId] ?? 0) == 0) {
        activityCounts.remove(listId);
        listImages.remove(listId);
      }

      // Make sure GetX updates listeners
      activityCounts.refresh();
      listImages.refresh();
    } catch (e) {
      print("Delete favorite error: $e");
    }
  }

  Future<void> loadFavoriteStatus() async {
    try {
      favoriteItemsMap.clear();

      await getFavoriteLists();

      final futures = favoriteLists.map((list) {
        return favoriteService.getFavoriteItems(list["id"].toString());
      }).toList();

      final responses = await Future.wait(futures);

      for (int i = 0; i < responses.length; i++) {
        final response = responses[i];
        final list = favoriteLists[i];

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
    } catch (e) {
      print("Load favorite status error: $e");
    }
  }

  @override
  void onClose() {
    createListCtrl.dispose();
    createListFocusNode.dispose();
    super.onClose();
  }
}
