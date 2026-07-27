import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_textfield/build_textfield.dart';

class NearbyScreenView extends GetView<NearbyScreenController> {
  const NearbyScreenView({super.key});
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                // Obx(
                //   () => Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //     child: SizedBox(
                //       height: 100,
                //       child: ListView.separated(
                //         scrollDirection: Axis.horizontal,
                //         itemCount: controller.categories.length,
                //         separatorBuilder: (_, __) => SizedBox(width: 20),
                //         itemBuilder: (context, index) {
                //           final item = controller.categories[index];

                //           return Column(
                //             children: [
                //               GestureDetector(
                //                 onTap: () {},
                //                 child: Container(
                //                   width: 60,
                //                   height: 60,
                //                   decoration: BoxDecoration(
                //                     shape: BoxShape.circle,
                //                     // color: Color(0xff009A3F),
                //                   ),
                //                   child: Center(
                //                     child: Image.network(
                //                       item["icon_url"] ?? "",
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(height: 10),
                //               Text(
                //                 Get.locale?.languageCode == 'kmKH'
                //                     ? (item["name_km"] ?? item["name"] ?? "")
                //                     : (item["name"] ?? ""),
                //                 style: GoogleFonts.googleSans(),
                //               ),
                //             ],
                //           );
                //         },
                //       ),
                //     ),
                //   ),
                // ),

                // REPLACE YOUR EXISTING CATEGORY LIST Obx BLOCK WITH THIS:
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          final item = controller.categories[index];

                          return Obx(() {
                            final isSelected =
                                controller.selectedCategory.value
                                    .toLowerCase() ==
                                (item["name"] ?? "").toString().toLowerCase();
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.filterByCategory(
                                      item["name"] ?? "",
                                    );
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xff009A3F)
                                          : Colors.grey.shade200,
                                    ),
                                    child: Center(
                                      child: CachedNetworkImage(
                                        imageUrl: item["icon_url"] ?? "",
                                        width: 32,
                                        height: 32,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.category,
                                              size: 24,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["name"] ?? "",
                                  style: GoogleFonts.googleSans(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xff009A3F)
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      "Nearby",
                      style: GoogleFonts.googleSans(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width: 35),
                    Text(
                      "Activities near your current location",
                      style: GoogleFonts.googleSans(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Obx(() {
                  if (controller.nearbyPlaces.isEmpty) {
                    return SizedBox.shrink();
                  }

                  final nearestPlace = controller.nearbyPlaces.first;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 50),

                      Text(
                        "${nearestPlace.distance.toStringAsFixed(1)} km away",
                        style: GoogleFonts.googleSans(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.titleSmall!.color,
                        ),
                      ),

                      SizedBox(width: 10),

                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[500],
                        ),
                      ),

                      SizedBox(width: 10),

                      Text(
                        "${controller.nearbyPlaces.length} places",
                        style: GoogleFonts.googleSans(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.titleSmall!.color,
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor),
                SizedBox(height: 10),
                _buildNearbyPlaces(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPlaces(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.nearbyPlaces.isEmpty) {
        return Center(
          child: Text(
            "No nearby places found",
            style: GoogleFonts.googleSans(
              fontSize: 12,
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),
        );
      }

      return ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.nearbyPlaces.length,
        separatorBuilder: (_, __) =>
            Divider(height: 30, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final place = controller.nearbyPlaces[index];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Bounceable(
                    onTap: () {
                      print(place.toJson());
                      Get.toNamed(
                        Routes.DETAIL_PLACES,
                        arguments: place.toJson(),
                      );
                    },
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade300,
                        image: DecorationImage(
                          image: NetworkImage(place.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isFav = controller.favoriteController.isFavorite(
                        place.id,
                      );

                      return GestureDetector(
                        onTap: () {
                          controller.favoriteController.toggleFavorite(
                            place.id,
                            context,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? Colors.red
                                : Theme.of(context).textTheme.titleSmall!.color,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Get.locale?.languageCode == "kmKH"
                          ? place.nameKm
                          : place.nameEn,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            children: [
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
                              SizedBox(width: 10),
                              Text(
                                "${place.distance.toStringAsFixed(1)} km",
                                style: GoogleFonts.googleSans(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.star, size: 18, color: Colors.amber),
                        SizedBox(width: 5),
                        Text(
                          "4.5",
                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall?.color,
                          ),
                        ),

                        SizedBox(width: 10),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[500],
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
            ],
          );
        },
      );
    });
  }
}
