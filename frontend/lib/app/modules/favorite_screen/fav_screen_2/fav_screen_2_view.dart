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
                  mode: BottomSheetMode.rename,
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
    // final theme = Theme.of(context);
    // String timeAgo(String savedAt) {
    //   final savedDate = DateTime.parse("${savedAt}Z").toUtc();
    //   final now = DateTime.now().toUtc();

    //   final difference = now.difference(savedDate);

    //   if (difference.inDays > 0) {
    //     final days = difference.inDays;
    //     return "${"saved".tr} $days ${days > 1 ? "days".tr : "day".tr} ${"ago".tr}";
    //   } else if (difference.inHours > 0) {
    //     final hours = difference.inHours;
    //     return "${"saved".tr} $hours ${hours > 1 ? "hours".tr : "hour".tr} ${"ago".tr}";
    //   } else if (difference.inMinutes > 0) {
    //     final minutes = difference.inMinutes;
    //     return "${"saved".tr} $minutes ${minutes > 1 ? "minutes".tr : "minute".tr} ${"ago".tr}";
    //   } else {
    //     return "saved_just_now".tr;
    //   }
    // }

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
            onTap: () async {
              final type = FavoriteItemType.values.firstWhere(
                (e) => e.name == item["item_type"],
              );

              switch (type) {
                case FavoriteItemType.place:
                  final placeId = item["id"]?.toString();

                  if (placeId == null || placeId.isEmpty) return;

                  final placeData = await controller.placesService
                      .fetchPlaceDetail(id: placeId);

                  if (placeData["data"] != null) {
                    Get.toNamed(
                      Routes.DETAIL_PLACES,
                      arguments: placeData["data"],
                    );
                  }
                  break;

                case FavoriteItemType.hotel:
                  final hotelId = item["id"]?.toString();

                  if (hotelId == null || hotelId.isEmpty) return;

                  final hotelData = await controller.hotelService
                      .fetchHotelById(hotelId);

                  if (hotelData["data"] != null) {
                    Get.toNamed(
                      Routes.HOTEL_DETAIL,
                      arguments: hotelData["data"],
                    );
                  }
                  break;

                case FavoriteItemType.package:
                  final packageId = item["id"]?.toString();

                  if (packageId == null || packageId.isEmpty) return;

                  final packageData = await controller.travelPackagesSservice
                      .fetchTravelPackageById(packageId);

                  if (packageData["data"] != null) {
                    Get.toNamed(
                      Routes.PACKAGE_DETAIL,
                      arguments: packageData["data"],
                    );
                  }
                  break;
              }
            },
            child: _buildFavoriteCard(context, item),
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _favoriteImage(item),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _favoriteName(context, item),

                  const SizedBox(height: 8),

                  _locationRow(context, item["province"], item["province_km"]),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(item["rating"]?.toString() ?? "0.0"),
                      const SizedBox(width: 10),

                      _categoryChip(
                        context,
                        item["category"],
                        item["category_km"],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _savedTime(item),
                ],
              ),
            ),

            _favoriteDeleteButton(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _favoriteImage(item),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _favoriteName(context, item),

                  const SizedBox(height: 8),

                  _locationRow(
                    context,
                    item["province"] ?? item["location"],
                    item["province_km"],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(item["rating"]?.toString() ?? "0.0"),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _savedTime(item),
                ],
              ),
            ),

            _favoriteDeleteButton(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _favoriteImage(item),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _favoriteName(context, item),

                  const SizedBox(height: 8),

                  if (item["province"] != null || item["location"] != null)
                    _locationRow(
                      context,
                      item["province"] ?? item["location"],
                      item["province_km"],
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.luggage,
                        size: 19,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),

                      Text(
                        Get.locale?.languageCode == "kmKH"
                            ? "កញ្ចប់ដំណើរ"
                            : "Travel Package",
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _savedTime(item),
                ],
              ),
            ),

            _favoriteDeleteButton(context, item),
          ],
        ),
      ),
    );
  }

  Widget _favoriteImage(Map<String, dynamic> item) {
    final imageUrl = item["image_url"]?.toString() ?? "";

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade300,
        image: imageUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl.isEmpty
          ? const Icon(Icons.image_not_supported, color: Colors.grey)
          : null,
    );
  }

  Widget _favoriteName(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    final name = Get.locale?.languageCode == "kmKH"
        ? item["name_km"]
        : item["name_en"];

    return Text(
      name?.toString() ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.fontsGeneral.copyWith(color: theme.colorScheme.secondary),
    );
  }

  Widget _locationRow(
    BuildContext context,
    dynamic province,
    dynamic provinceKm,
  ) {
    final theme = Theme.of(context);

    final location = Get.locale?.languageCode == "kmKH"
        ? provinceKm ?? province
        : province ?? provinceKm;

    return Row(
      children: [
        Icon(Icons.location_on, size: 18, color: theme.primaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location?.toString() ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.googleSans(
              fontSize: 15,
              color: theme.textTheme.titleSmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(
    BuildContext context,
    dynamic category,
    dynamic categoryKm,
  ) {
    final theme = Theme.of(context);

    final text = Get.locale?.languageCode == "kmKH"
        ? categoryKm ?? category
        : category ?? categoryKm;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffCEDFCE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text?.toString() ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.googleSans(
          fontSize: 14,
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _savedTime(Map<String, dynamic> item) {
    final savedAt = item["saved_at"]?.toString();

    if (savedAt == null || savedAt.isEmpty) {
      return const SizedBox.shrink();
    }

    final savedDate = DateTime.parse("${savedAt}Z").toUtc();
    final now = DateTime.now().toUtc();
    final difference = now.difference(savedDate);

    String text;

    if (difference.inDays > 0) {
      final days = difference.inDays;
      text =
          "${"saved".tr} $days ${days > 1 ? "days".tr : "day".tr} ${"ago".tr}";
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      text =
          "${"saved".tr} $hours ${hours > 1 ? "hours".tr : "hour".tr} ${"ago".tr}";
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      text =
          "${"saved".tr} $minutes ${minutes > 1 ? "minutes".tr : "minute".tr} ${"ago".tr}";
    } else {
      text = "saved_just_now".tr;
    }

    return Row(
      children: [
        const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.googleSans(
              fontSize: 14,
              color: Get.theme.textTheme.titleSmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _favoriteDeleteButton(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return Bounceable(
      onTap: () async {
        final itemType = item["item_type"]?.toString();

        if (itemType == null) return;

        final type = FavoriteItemType.values.firstWhere(
          (e) => e.name == itemType,
          orElse: () => FavoriteItemType.place,
        );

        await controller.deleteFavorite(item["id"].toString(), type);
      },
      child: const Icon(Icons.favorite, color: Colors.red),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Map<String, dynamic> item) {
    switch (item["item_type"]?.toString()) {
      case "hotel":
        return _buildHotelCard(context, item);

      case "package":
        return _buildPackageCard(context, item);

      case "place":
      default:
        return _buildPlaceCard(context, item);
    }
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
