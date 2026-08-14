import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/discover_screen/custom_textfield/build_textfield.dart';
import 'package:frontend/app/modules/discover_screen/search_result_screen/search_result_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'search_result_screen_binding.dart';

class ExploreView extends GetView<SearchResultScreenController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: Bounceable(
          onTap: () => Get.back(),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: SvgPicture.asset("assets/svg/arrow_back.svg"),
          ),
        ),
        title: BuildTextfield(
          controller: controller.searchController,
          onChanged: controller.searchPlaces,
          onSubmitted: controller.searchSubmitted,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // categories
            _buildCategories(),

            SizedBox(height: 10),

            Obx(() {
              if (!controller.hasSearched.value) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${'result found'.tr} (${controller.searchResults.length})",
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // User hasn't searched yet
                if (!controller.hasSearched.value) {
                  return _buildSearchHistory(context);
                }

                // User searched but nothing matched
                if (controller.searchResults.isEmpty) {
                  return Center(child: Text('No results found'.tr));
                }

                return ListView.separated(
                  itemCount: controller.searchResults.length,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final result = controller.searchResults[index];

                    return _buildSearchResult(result, context);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.nearbyController.categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 20),
            itemBuilder: (context, index) {
              final item = controller.nearbyController.categories[index];

              return Obx(() {
                final isSelected =
                    controller.selectedCategory.value.toLowerCase() ==
                    (item["name"] ?? "").toString().toLowerCase();
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.filterByCategory(item);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Color(0xff009A3F)
                              : Colors.grey.shade200,
                        ),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: item["icon_url"] ?? "",
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,

                            // Shows while the image is loading
                            placeholder: (context, url) => SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),

                            // Shows if the image fails
                            errorWidget: (context, url, error) =>
                                Icon(Icons.category, size: 24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      Get.locale?.languageCode == "kmKH"
                          ? item["name_km"] ?? ""
                          : item["name"] ?? "",
                      style: GoogleFonts.googleSans(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Color(0xff009A3F)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, BuildContext context) {
    final imageUrl = place["image_url"]?.toString() ?? "";
    final nameEn = place["name_en"]?.toString() ?? "";
    final nameKm = place["name_km"]?.toString() ?? "";
    final province = place["province"]?.toString() ?? "";
    final provinceKm = place["province_km"]?.toString() ?? "";
    final category = place["category"]?.toString() ?? "";
    final categoryKm = place["category_km"]?.toString() ?? "";
    final rating = place["rating"] ?? 0;

    return Bounceable(
      // onTap: () async {
      //   final placeId = place["id"]?.toString();

      //   if (placeId == null || placeId.isEmpty) {
      //     print("PLACE ID IS NULL");
      //     return;
      //   }

      //   final placeData = await controller.placeServices.fetchPlaceDetail(
      //     id: placeId,
      //   );

      //   print("DETAIL DATA: $placeData");

      //   if (placeData["data"] != null) {
      //     Get.toNamed(Routes.DETAIL_PLACES, arguments: place);
      //   }
      // },
      onTap: () {
        controller.saveRecentSearch({"type": "place", "data": place});

        Get.toNamed(Routes.DETAIL_PLACES, arguments: place);
      },

      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        Get.locale?.languageCode == "kmKH" ? nameKm : nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fontsSubTitlew500.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),

                        const SizedBox(width: 5),

                        Flexible(
                          child: Text(
                            Get.locale?.languageCode == "kmKH"
                                ? provinceKm
                                : province,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.titleSmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),

                        const SizedBox(width: 5),

                        Text(rating.toString()),

                        const SizedBox(width: 15),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffCEDFCE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            Get.locale?.languageCode == "kmKH"
                                ? categoryKm
                                : category,
                            style: GoogleFonts.googleSans(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package, BuildContext context) {
    final imageUrl = package["image_url"]?.toString() ?? "";
    final nameEn = package["name_en"]?.toString() ?? "";
    final nameKm = package["name_km"]?.toString() ?? "";
    final rating = package["rating"] ?? 0;
    final duration = package["duration_days"] ?? 0;
    final price = package["price_per_person"] ?? 0;

    return Bounceable(
      onTap: () async {
        // final packageId = package["id"]?.toString();

        // if (packageId == null || packageId.isEmpty) {
        //   print("PACKAGE ID IS NULL");
        //   return;
        // }

        // // Use your existing package service
        // final packageData = await controller.travelPackageService
        //     .fetchTravelPackageById(packageId);

        // print("PACKAGE DETAIL DATA: $packageData");

        // if (packageData["data"] != null) {
        //   Get.toNamed(Routes.PACKAGE_DETAIL, arguments: packageData["data"]);
        // }
        controller.saveRecentSearch({"type": "package", "data": package});

        Get.toNamed(Routes.PACKAGE_DETAIL, arguments: package);
      },

      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        Get.locale?.languageCode == "kmKH" ? nameKm : nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fontsSubTitlew500.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          "$duration ${duration == 1 ? "day" : "days"}",
                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall?.color,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          "\$$price/person",
                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall?.color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),

                        const SizedBox(width: 5),

                        Text(rating.toString()),

                        const SizedBox(width: 15),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffCEDFCE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Package",
                            style: GoogleFonts.googleSans(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel, BuildContext context) {
    final imageUrl = hotel["image_url"]?.toString() ?? "";
    final nameEn = hotel["name_en"]?.toString() ?? "";
    final nameKm = hotel["name_km"]?.toString() ?? "";
    final province = hotel["province"]?.toString() ?? "";
    final provinceKm = hotel["province_km"]?.toString() ?? "";

    final starRating = hotel["star_rating"] ?? 0;

    return Bounceable(
      onTap: () async {
        // final hotelId = hotel["id"]?.toString();

        // if (hotelId == null || hotelId.isEmpty) {
        //   print("HOTEL ID IS NULL");
        //   return;
        // }

        // final hotelData = await controller.hotelService.fetchHotelById(hotelId);

        // print("HOTEL DETAIL DATA: $hotelData");

        // if (hotelData["data"] != null) {
        //   Get.toNamed(Routes.HOTEL_DETAIL, arguments: hotelData["data"]);
        // }
        // Get.toNamed(Routes.HOTEL_DETAIL, arguments: hotel);
        controller.saveRecentSearch({"type": "hotel", "data": hotel});

        Get.toNamed(Routes.HOTEL_DETAIL, arguments: hotel);
      },

      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        Get.locale?.languageCode == "kmKH" ? nameKm : nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fontsSubTitlew500.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),

                        const SizedBox(width: 5),

                        Flexible(
                          child: Text(
                            Get.locale?.languageCode == "kmKH"
                                ? provinceKm
                                : province,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.titleSmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),

                        const SizedBox(width: 5),

                        Text(starRating.toString()),

                        const SizedBox(width: 15),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffCEDFCE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Hotel",
                            style: GoogleFonts.googleSans(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult(Map<String, dynamic> result, BuildContext context) {
    final type = result["type"];
    final data = result["data"] as Map<String, dynamic>;

    // switch (type) {
    //   case "place":
    //     return _buildPlaceCard(data, context);

    //   case "hotel":
    //     return _buildHotelCard(data, context);

    //   case "package":
    //     return _buildPackageCard(data, context);

    //   default:
    //     return const SizedBox.shrink();
    // }
    switch (type) {
      case "place":
        return _buildPlaceCard({
          ...data,
          "_searchResultType": "place",
        }, context);

      case "hotel":
        return _buildHotelCard({
          ...data,
          "_searchResultType": "hotel",
        }, context);

      case "package":
        return _buildPackageCard({
          ...data,
          "_searchResultType": "package",
        }, context);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSearchHistory(BuildContext context) {
    if (controller.searchHistory.isEmpty) {
      return Center(
        child: Text(
          "No recent searches".tr,
          style: GoogleFonts.googleSans(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent searches".tr,
              style: GoogleFonts.googleSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: controller.clearSearchHistory,
              child: Text(
                "Clear all".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ...controller.searchHistory.map((result) {
          final type = result["type"];

          final data = result["data"] is Map
              ? Map<String, dynamic>.from(result["data"])
              : <String, dynamic>{};

          final imageUrl = data["image_url"]?.toString() ?? "";

          final nameEn = data["name_en"]?.toString() ?? "";

          final nameKm = data["name_km"]?.toString() ?? "";

          final province = data["province"]?.toString() ?? "";

          final provinceKm = data["province_km"]?.toString() ?? "";

          String title;
          String subtitle;

          if (type == "place") {
            title = Get.locale?.languageCode == "kmKH" ? nameKm : nameEn;

            subtitle = Get.locale?.languageCode == "kmKH"
                ? provinceKm
                : province;
          } else if (type == "hotel") {
            title = Get.locale?.languageCode == "kmKH" ? nameKm : nameEn;

            subtitle = Get.locale?.languageCode == "kmKH"
                ? provinceKm
                : province;
          } else if (type == "package") {
            title = Get.locale?.languageCode == "kmKH" ? nameKm : nameEn;

            subtitle = "Package";
          } else {
            // Ignore old/invalid history entries
            return const SizedBox.shrink();
          }

          return Dismissible(
            key: ValueKey("${type}_${data["id"]}"),

            direction: DismissDirection.endToStart,

            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            onDismissed: (direction) {
              controller.removeRecentSearch(type: type, itemId: data["id"]);
            },

            child: ListTile(
              contentPadding: EdgeInsets.zero,

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
              ),

              title: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),

              subtitle: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.googleSans(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              trailing: const Icon(Icons.history, size: 20),

              onTap: () {
                switch (type) {
                  case "place":
                    Get.toNamed(Routes.DETAIL_PLACES, arguments: data);
                    break;

                  case "hotel":
                    Get.toNamed(Routes.HOTEL_DETAIL, arguments: data);
                    break;

                  case "package":
                    Get.toNamed(Routes.PACKAGE_DETAIL, arguments: data);
                    break;
                }
              },
            ),
          );
        }),
      ],
    );
  }

  void openSearchResult(Map<String, dynamic> result) {
    controller.saveRecentSearch(result);

    final type = result["type"];
    final data = Map<String, dynamic>.from(result["data"] ?? {});

    switch (type) {
      case "place":
        Get.toNamed(Routes.DETAIL_PLACES, arguments: data);
        break;

      case "hotel":
        Get.toNamed(Routes.HOTEL_DETAIL, arguments: data);
        break;

      case "package":
        Get.toNamed(Routes.PACKAGE_DETAIL, arguments: data);
        break;
    }
  }
}
