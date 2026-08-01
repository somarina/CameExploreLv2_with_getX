import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/button_navbar/controllers/button_navbar_controller.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:frontend/app/modules/favorite_screen/fav_screen_2/fav_screen_2_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

part 'fav_screen_2_binding.dart';

class FavScreen2View extends GetView<FavScreen2ViewController> {
  const FavScreen2View({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),

                Row(
                  children: [
                    _circleButton(
                      theme,
                      child: SvgPicture.asset(
                        "assets/svg/normalBack.svg",
                        width: 26,
                        height: 26,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () => Get.back(),
                    ),

                    Spacer(),

                    Obx(
                      () => Text(
                        controller.listName.value,
                        style: AppFonts.fontsGeneral.copyWith(
                          fontSize: 18,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Spacer(),

                    _circleButton(
                      theme,
                      child: Icon(
                        Icons.share,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(text: controller.listName.value),
                        );
                      },
                    ),

                    SizedBox(width: 10),

                    _circleButton(
                      theme,
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: _showOptionsBottomSheet,
                    ),
                  ],
                ),

                _buildEmptyList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(
    ThemeData theme, {
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    final theme = Get.theme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: () {
                Get.back();

                controller.renameCtrl.text = controller.listName.value;

                AppBottomSheets.showBottomSheet(
                  title: "Rename list".tr,
                  label: "Enter new list name".tr,
                  controller: controller.renameCtrl,
                  focusNode: controller.renameFocusNode,
                  onDone: () async {
                    await controller.renameFavoriteList();
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.edit, color: theme.colorScheme.primary),
                  const SizedBox(width: 15),
                  Text(
                    "Rename list".tr,
                    style: AppFonts.fontsGeneral.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _deleteWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyList(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.favoriteItems.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            height: Get.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "This list is empty".tr,
                  style: AppFonts.fontsSubTitle.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    Get.find<ButtonNavbarController>().changePage(0);

                    Get.offAllNamed(Routes.BUTTON_NAVBAR);

                    await controller.favoriteController.getFavoriteItems(
                      controller.listId.value,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black26,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    "Find things to do".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return _buildFavList(context);
    });
  }

  Widget _buildFavList(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 20),
        shrinkWrap: true,
        itemCount: controller.favoriteItems.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = controller.favoriteItems[index];
          debugPrint(item.toString());

          return Bounceable(
            onTap: () {
              final placeData = {
                "id": item["place_id"] ?? "",

                // Name
                "name_en": item["name"] ?? "",
                "name_km": item["name"] ?? "",

                // Description
                "description_en": item["description"] ?? "",
                "description_km": item["description"] ?? "",

                // Province
                "province": item["province"] ?? "",
                "province_km": item["province"] ?? "",

                // Category
                "category": item["category"] ?? "",
                "category_km": item["category"] ?? "",

                // Image
                "image_url": item["image_url"] ?? "",

                // Location
                "latitude": (item["latitude"] ?? 0).toDouble(),
                "longitude": (item["longitude"] ?? 0).toDouble(),

                // Rating
                "rating": (item["rating"] ?? 0).toDouble(),

                // Optional fields used by Detail Screen
                "phoneNum": item["phoneNum"] ?? "",
              };

              Get.toNamed(Routes.DETAIL_PLACES, arguments: placeData);
            },
            child: Card(
              color: theme.colorScheme.primaryContainer,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: item["image_url"] != null
                            ? DecorationImage(
                                image: NetworkImage(item["image_url"]),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey.shade300,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["name"] ?? "",
                            style: AppFonts.fontsGeneral.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: theme.primaryColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                item["province"] ?? "",
                                style: GoogleFonts.googleSans(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.color,
                                ),
                              ),
                              Text(
                                ", Cambodia",
                                style: GoogleFonts.googleSans(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.color,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, size: 20, color: Colors.amber),
                              Text(item["rating"]?.toString() ?? "0.0"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Favorite Icon
                    Bounceable(
                      onTap: () async {
                        await controller.deleteFavorite(
                          item["place_id"].toString(),
                        );
                      },
                      child: const Icon(Icons.favorite, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _deleteWidget() {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          AlertDialog(
            backgroundColor: Get.theme.colorScheme.primaryContainer,
            title: Text(
              "Delete list".tr,
              style: AppFonts.fontsGeneral.copyWith(
                color: Get.theme.colorScheme.secondary,
              ),
            ),
            content: Text(
              "delete_list_confirm".trParams({
                'listName': controller.listName.value,
              }),
              style: AppFonts.fontDescriptionsmall,
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text(
                  "Cancel".tr,
                  style: GoogleFonts.googleSans(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await controller.deleteFavoriteList();

                  Get.back();
                  Get.back();
                  Get.back();
                },
                child: Text(
                  "Delete".tr,
                  style: GoogleFonts.googleSans(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.delete, color: Colors.red),
          const SizedBox(width: 15),
          Text(
            "Delete list".tr,
            style: AppFonts.fontsGeneral.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
