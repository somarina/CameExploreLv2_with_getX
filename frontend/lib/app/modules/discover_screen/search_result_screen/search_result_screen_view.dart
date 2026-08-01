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
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // categories
            _buildCategories(),

            SizedBox(height: 10),

            Obx(() {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Result found (${controller.searchResults.length})",
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      // fontWeight: FontWeight.bold,
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
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      "No places found",
                      style: GoogleFonts.googleSans(fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.refreshSearchResults();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) => SizedBox(height: 15),

                    itemBuilder: (context, index) {
                      final place = controller.searchResults[index];

                      return _buildPlaceCard(place, context);
                    },
                  ),
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

  Widget _buildPlaceCard(place, BuildContext context) {
    return Bounceable(
      onTap: () async {
        final placeData = await controller.placesService.fetchPlaceDetail(
          id: place.id.toString(),
        );
        print("DETAIL DATA: $placeData");

        if (placeData["data"] != null) {
          Get.toNamed(Routes.DETAIL_PLACES, arguments: placeData["data"]);
        }
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: place.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 15),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        Get.locale?.languageCode == "kmKH"
                            ? place.nameKm
                            : place.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fontsSubTitlew500.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 5),
                        Text(
                          Get.locale?.languageCode == "kmKH"
                              ? place.provinceKm
                              : place.province,

                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall?.color,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text("${place.distance.toStringAsFixed(1)} km"),
                      ],
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        SizedBox(width: 5),

                        Text(place.rating.toString()),

                        SizedBox(width: 15),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),

                        SizedBox(width: 10),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffCEDFCE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            Get.locale?.languageCode == "kmKH"
                                ? place.categoryKm
                                : place.category,

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
}
