import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/button_navbar/controllers/button_navbar_controller.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
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
          physics: AlwaysScrollableScrollPhysics(),
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
        return SizedBox(
          height: Get.height * 0.8,
          child: Center(child: CircularProgressIndicator()),
        );
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
    String timeAgo(String savedAt) {
      final savedDate = DateTime.parse("${savedAt}Z").toUtc();
      final now = DateTime.now().toUtc();

      final difference = now.difference(savedDate);

      if (difference.inDays > 0) {
        final days = difference.inDays;
        return "${"saved".tr} $days ${days > 1 ? "days".tr : "day".tr} ${"ago".tr}";
      } else if (difference.inHours > 0) {
        final hours = difference.inHours;
        return "${"saved".tr} $hours ${hours > 1 ? "hours".tr : "hour".tr} ${"ago".tr}";
      } else if (difference.inMinutes > 0) {
        final minutes = difference.inMinutes;
        return "${"saved".tr} $minutes ${minutes > 1 ? "minutes".tr : "minute".tr} ${"ago".tr}";
      } else {
        return "saved_just_now".tr;
      }
    }

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
            // onTap: () {
            //   if (item["item_type"] == "place") {
            //     Get.toNamed(Routes.DETAIL_PLACES, arguments: item);
            //   }
            // },
            onTap: () async {
              final type = FavoriteItemType.values.firstWhere(
                (e) => e.name == item["item_type"],
              );

              switch (type) {
                case FavoriteItemType.place:
                  Get.toNamed(Routes.DETAIL_PLACES, arguments: item);

                  break;

                case FavoriteItemType.hotel:
                  Get.toNamed(Routes.HOTEL_DETAIL, arguments: item);

                  break;

                case FavoriteItemType.package:
                  Get.toNamed(Routes.PACKAGE_DETAIL, arguments: item);

                  break;
              }
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
                        image:
                            (item["image_url"] != null &&
                                item["image_url"].toString().isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(
                                  item["image_url"].toString(),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey.shade300,
                      ),
                    ),

                    SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Get.locale?.languageCode == "kmKH"
                                ? (item["name_km"] ?? "")
                                : (item["name_en"] ?? ""),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.fontsGeneral.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
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
                                Get.locale?.languageCode == "kmKH"
                                    ? (item["province_km"] ?? "")
                                    : (item["province"] ?? ""),
                                style: GoogleFonts.googleSans(
                                  fontSize: 15,
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
                              SizedBox(width: 5),
                              Text(item["rating"]?.toString() ?? "0.0"),
                              SizedBox(width: 10),

                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[500],
                                ),
                              ),

                              SizedBox(width: 20),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffCEDFCE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  width: 70,
                                  child: Center(
                                    child: Text(
                                      Get.locale?.languageCode == "kmKH"
                                          ? (item["category_km"] ?? "កញ្ចប់ដំណើរ")
                                          : (item["category"] ?? "Travel Package"),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                    
                                      style: GoogleFonts.googleSans(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),

                              Text(
                                timeAgo(item["saved_at"]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.googleSans(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Favorite Icon
                    Bounceable(
                      // onTap: () async {
                      //   final type = FavoriteItemType.values.firstWhere(
                      //     (e) => e.name == item["item_type"],
                      //     orElse: () => FavoriteItemType.place,
                      //   );

                      //   await controller.deleteFavorite(
                      //     item["id"].toString(),
                      //     type,
                      //   );
                      // },
                      onTap: () async {
                        final itemType = item["item_type"]?.toString();

                        if (itemType == null) return;

                        final type = FavoriteItemType.values.firstWhere(
                          (e) => e.name == itemType,
                          orElse: () => FavoriteItemType.place,
                        );

                        await controller.deleteFavorite(
                          item["id"].toString(),
                          type,
                        );
                      },
                      child: Icon(Icons.favorite, color: Colors.red),
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
              style: AppFonts.fontDescriptionsmall.copyWith(
                color: Get.theme.colorScheme.secondary,
              ),
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
