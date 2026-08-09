import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_textfield/build_textfield.dart';

class SearchScreenView extends GetView<SearchScreenController> {
  const SearchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: SizedBox(
          height: 50,
          child: BuildTextfield(
            readOnly: true,
            onTap: () {
              Get.toNamed(Routes.NEARBY_SCREEN);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Most search".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(height: 200, child: _buildMostSearch()),
              SizedBox(height: 20),
              Text(
                "Popular places".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20),
              _buildPopularPlaces(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularPlaces() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.popularPlaces.isEmpty) {
        return const Center(child: Text("No data"));
      }

      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.popularPlaces.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final place = controller.popularPlaces[index];
          return Bounceable(
            onTap: () {
              Get.toNamed(Routes.DETAIL_PLACES, arguments: place.toJson());
            },
            child: Container(
              width: Get.width,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        place.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              Get.locale?.languageCode == "kmKH"
                                  ? place.nameKm
                                  : place.nameEn,
                            
                              maxLines: 1,
                              style: AppFonts.fontsSubTitlew500.copyWith(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                Get.locale?.languageCode == "kmKH"
                                    ? place.provinceKm
                                    : place.province,
                                style: GoogleFonts.googleSans(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.color,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),

                              Text(
                                place.rating.toString(),
                                style: GoogleFonts.googleSans(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.color,
                                ),
                              ),

                              const SizedBox(width: 10),

                              SizedBox(
                                width: 160,
                                child: Text(
                                  "${place.searchCount} ${"people searched this".tr}",
                                  style: GoogleFonts.googleSans(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleSmall!.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMostSearch() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.mostSearch.isEmpty) {
        return Center(child: Text("No data"));
      }

      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.mostSearch.length,
        separatorBuilder: (context, index) => SizedBox(width: 15),
        itemBuilder: (context, index) {
          final place = controller.mostSearch[index];
          return Bounceable(
            onTap: () {
              Get.toNamed(Routes.DETAIL_PLACES, arguments: place.toJson());
            },
            child: Container(
              width: 160,
              height: 220,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          place.imageUrl,
                          width: 160,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 160,
                            height: 120,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(
                                place.rating.toString(),
                                style: GoogleFonts.googleSans(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      bottom: 10,
                      top: 5,
                      right: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text(
                              Get.locale?.languageCode == "kmKH"
                                  ? place.provinceKm
                                  : place.province,

                              style: GoogleFonts.googleSans(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.color,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          "${place.searchCount} ${"searches".tr}",
                          style: GoogleFonts.googleSans(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
