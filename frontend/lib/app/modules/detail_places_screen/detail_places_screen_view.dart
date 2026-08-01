import 'dart:math' as Math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/api/services/review_place.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery/gallery_view.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery_seeall/gallery_seeall_view.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:frontend/app/widgets/cardPlace/card_place.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

part 'detail_places_screen_binding.dart';
part 'detail_places_screen_controller.dart';

class DetailPlacesScreenView extends GetView<DetailPlacesScreenViewController> {
  const DetailPlacesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    print(controller.place);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: controller.scrollController,
        physics: ClampingScrollPhysics(),
        child: Stack(
          children: [
            /// Header Image
            _buildHeader(context),

            /// Top Buttons
            _buildThreeIcons(context),

            /// Content
            _buildcontent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildcontent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Get.height * .32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Rating
            _buildContentTitle(context),
            const SizedBox(height: 30),

            /// About
            _buildContentAbout(context),
            const SizedBox(height: 30),

            /// Opening Hours
            _buildContentOpenHour(context),
            Obx(
              () =>
                  controller.openingHours.trim().isNotEmpty &&
                      controller.openingHours != "N/A"
                  ? const SizedBox(height: 30)
                  : const SizedBox.shrink(),
            ),

            /// Entry Fee
            _buildEntryFee(context),
            Obx(
              () =>
                  (controller.place['entry_fee']
                          ?.toString()
                          .trim()
                          .isNotEmpty ??
                      false)
                  ? const SizedBox(height: 30)
                  : const SizedBox.shrink(),
            ),

            /// Tags
            _buildTags(context),
            Obx(
              () => controller.tags.isNotEmpty
                  ? const SizedBox(height: 30)
                  : const SizedBox.shrink(),
            ),

            /// Gallery
            _buildContentGallery(context),
            const SizedBox(height: 30),

            /// Contact
            Obx(
              () => controller.phone != null
                  ? Column(
                      children: [
                        _buildContact(context),
                        const SizedBox(height: 30),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            /// Location
            _buildLocation(context),
            const SizedBox(height: 40),

            /// Nearby
            _buildNearby(context),
            const SizedBox(height: 30),

            /// Reviews
            _buildReview(context),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryFee(BuildContext context) {
    return Obx(() {
      final entryFee = controller.place['entry_fee']?.toString().trim() ?? '';

      // Hide widget if entry_fee is empty
      if (entryFee.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "entry_fee".tr,
            style: GoogleFonts.googleSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _feeRow(Icons.public, "foreign_adult".tr, entryFee, context),
                const SizedBox(height: 10),
                _feeRow(
                  Icons.child_care,
                  "foreign_child".tr,
                  "free".tr,
                  context,
                ),
                const SizedBox(height: 10),
                _feeRow(Icons.flag, "cambodian_citizen".tr, "free".tr, context),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _feeRow(
    IconData icon,
    String title,
    String price,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),

        Text(
          title,
          style: GoogleFonts.googleSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                price,
                textAlign: TextAlign.right,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.googleSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    final controller = Get.find<DetailPlacesScreenViewController>();

    if (controller.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tags",
            style: GoogleFonts.googleSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: controller.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.googleSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNearby(BuildContext context) {
    final String category = controller
        .getCategory(controller.place)
        .toLowerCase();

    final bool isFoodCategory = category == 'food' || category == 'ម្ហូប';

    final String sectionTitle = isFoodCategory
        ? "recommended_food".tr
        : "near_places".tr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sectionTitle,
                style: GoogleFonts.googleSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingPlaces.value &&
                controller.nearbyPlaces.isEmpty) {
              return const SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.nearbyPlaces.isEmpty) {
              return SizedBox(
                height: 270,
                child: Center(
                  child: Text(
                    isFoodCategory
                        ? "no_recommended_food_found".tr
                        : "no_nearby_places_found".tr,
                    style: GoogleFonts.googleSans(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 270,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: controller.nearbyPlaces.length,
                itemBuilder: (context, index) {
                  final rawPlace = controller.nearbyPlaces[index];
                  if (rawPlace is! Map) return const SizedBox.shrink();

                  final nearbyPlace = Map<String, dynamic>.from(rawPlace);

                  return Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Bounceable(
                        onTap: () {
                          controller.updateSelectedPlace(nearbyPlace);
                        },
                        child: CardPlace(
                          width: Get.width * 0.8,
                          image:
                              (nearbyPlace['image_url'] != null &&
                                  nearbyPlace['image_url']
                                      .toString()
                                      .startsWith('http'))
                              ? nearbyPlace['image_url'].toString()
                              : (nearbyPlace['image'] ?? ""),
                          category: controller.getCategory(nearbyPlace),
                          title: controller.getPlaceName(nearbyPlace),
                          location: controller.getAddress(nearbyPlace),
                          rating: (nearbyPlace['rating'] != null)
                              ? double.tryParse(
                                      nearbyPlace['rating'].toString(),
                                    ) ??
                                    5.0
                              : 5.0,
                          review_count: nearbyPlace['review_count'] ?? 0,
                          distance:
                              "${controller.calculateDistance(controller.place["latitude"], controller.place["longitude"], nearbyPlace["latitude"], nearbyPlace["longitude"]).toStringAsFixed(2)} km",
                          isFavorite: index < controller.favorites.length
                              ? controller.favorites[index]
                              : false,
                          onFavorite: () => controller.toggleFavorite(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Obx(() {
      final String address = controller.homeCtrl.getAddress(controller.place);
      final String category = controller
          .getCategory(controller.place)
          .toLowerCase();

      // Check if the place belongs to the Food category
      final bool isFoodCategory = category == 'food' || category == 'ម្ហូប';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "location".tr,
            style: GoogleFonts.googleSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 10),

          if (isFoodCategory) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.isNotEmpty ? address : "N/A",
                      style: GoogleFonts.googleSans(
                        fontSize: 14,
                        height: 1.5,
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// MAP CARD
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xffE8EEF3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/location_icon.gif',
                            width: 70,
                            height: 70,
                          ),
                          Positioned(
                            bottom: 18,
                            left: 16,
                            right: 16,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  controller.homeCtrl.getPlaceName(
                                    controller.place,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.googleSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// ADDRESS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.googleSans(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.navigation,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          Text(
                            "${controller.homeCtrl.calculateDistance(controller.place["latitude"], controller.place["longitude"]).toStringAsFixed(2)} km",
                            style: GoogleFonts.googleSans(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    /// BUTTON
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => controller.openGoogleMaps(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.navigation, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "get_direction".tr,
                                style: GoogleFonts.googleSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildContact(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "contact".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () =>
              controller.callPhone(controller.place['phoneNum'].toString()),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  "(+855) ${controller.place['phoneNum']}",
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentGallery(BuildContext context) {
    if (controller.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "gallary".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Spacer(),
              Bounceable(
                onTap: () {
                  Get.to(
                    () => const GallerySeeallView(),
                    binding: GallerySeeallViewBinding(),
                    arguments: {"placePhotos": controller.images},
                  );
                },
                child: Text(
                  "${"see_all".tr} (${controller.images.length})",
                  style: GoogleFonts.googleSans(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Bounceable(
                  onTap: () {
                    Get.to(
                      () => GalleryView(
                        images: controller.images,
                        initialIndex: index,
                      ),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: Hero(
                    tag: controller.images[index],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        controller.images[index],
                        width: Get.width * .4,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return SizedBox(
                            width: Get.width * .4,
                            height: 120,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: Get.width * .4,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentOpenHour(BuildContext context) {
    return Obx(() {
      final rawHours = controller.openingHours.trim();

      // Hide widget completely if empty or N/A
      if (rawHours.isEmpty || rawHours == "N/A") {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "opening_hours".tr,
            style: GoogleFonts.googleSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_sharp,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "open_".tr,
                            style: GoogleFonts.googleSans(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              " • $rawHours",
                              style: GoogleFonts.googleSans(
                                color: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.isExpanded.toggle();
                      },
                      icon: Icon(
                        controller.isExpanded.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                if (controller.isExpanded.value) ...[
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.weeklyOpeningHours.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.weeklyOpeningHours[index];
                      final bool isToday = item["day"] == controller.today;

                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              item["day"]!.tr,
                              style: GoogleFonts.googleSans(
                                fontSize: isToday ? 14 : 12,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isToday
                                    ? Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.color
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            item["time"]!,
                            style: GoogleFonts.googleSans(
                              fontSize: isToday ? 14 : 12,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday
                                  ? Theme.of(
                                      context,
                                    ).textTheme.titleSmall!.color
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildContentAbout(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "about_".tr,
            style: GoogleFonts.googleSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            controller.homeCtrl.getDescription(controller.place),
            style: GoogleFonts.googleSans(
              color: Theme.of(context).textTheme.titleSmall!.color,
              height: 1.8,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTitle(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.homeCtrl.getPlaceName(controller.place),
                  style: GoogleFonts.googleSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Icon(Icons.star, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 4),
              Text(
                controller.rating > 0 ? controller.rating.toString() : "0.0",
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                ),
              ),

              Text(
                " (${controller.reviewCount}) ${'reviews'.tr}",

                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThreeIcons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Bounceable(
              onTap: () {
                Get.back();
              },
              child: _circleButton("assets/svg/normalBack.svg", context),
            ),
            Row(
              children: [
                Bounceable(
                  onTap: () {
                    final data = controller.place;

                    final String nameEn = data['name_en'] ?? '';
                    final String nameKm = data['name_km'] ?? '';
                    final String imageUrl = data['image_url'] ?? '';

                    SharePlus.instance.share(
                      ShareParams(
                        title: nameEn,
                        text: "$nameEn\n$nameKm\n\n$imageUrl",
                      ),
                    );
                  },
                  child: _circleButton("assets/svg/normalShare.svg", context),
                ),
                const SizedBox(width: 16),
                _circleButton("assets/svg/normalFav.svg", context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (controller.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(
      () => Column(
        children: [
          SizedBox(
            height: Get.height * .36,
            width: Get.width,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: controller.images.length,
                  onPageChanged: controller.changeIndex,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: controller.images[index],
                      width: Get.width,
                      height: Get.height * .36,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  bottom: 46,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Obx(
                      () => AnimatedSmoothIndicator(
                        activeIndex: controller.currentIndex.value,
                        count: controller.images.length,
                        effect: ExpandingDotsEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          expansionFactor: 3,
                          spacing: 6,
                          dotColor: Colors.white.withOpacity(.5),
                          activeDotColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(String asset, BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: 26,
          height: 26,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildReview(BuildContext context) {
    final profileController = Get.find<HomeScreenController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "review".tr,
          style: AppFonts.fontsSubTitlew500.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRating(context),
              CustomButton(
                title: "write_review".tr,
                onTap: () => controller.navigateToWriteReview(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        /// Live Dynamic Review List
        Obx(() {
          if (controller.isLoadingReviews.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.reviewsList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  "no_reviews_yet".tr,
                  style: GoogleFonts.googleSans(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          final currentUser = profileController.user.value;

          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.reviewsList.length,
            itemBuilder: (context, index) {
              final item = controller.reviewsList[index];

              final Map<String, dynamic>? userObj = item["user"] is Map
                  ? Map<String, dynamic>.from(item["user"])
                  : null;

              // Check if review belongs to current logged in user or extract from payload
              final String reviewUserId =
                  (item["user_id"] ?? userObj?["id"] ?? "").toString();
              final bool isCurrentUser =
                  currentUser != null &&
                  (currentUser.id == reviewUserId || reviewUserId.isEmpty);

              final String userName = isCurrentUser
                  ? (currentUser.name.isNotEmpty
                        ? currentUser.name
                        : "Anonymous User")
                  : (userObj?["name"] ??
                        userObj?["username"] ??
                        item["user_name"] ??
                        item["username"] ??
                        "Anonymous User");

              final String userAvatar = isCurrentUser
                  ? currentUser.avatar
                  : (userObj?["avatar"] ??
                        userObj?["profile_image"] ??
                        item["user_avatar"] ??
                        item["user_profile"] ??
                        item["avatar"] ??
                        "");

              // --- TIME AGO FORMATTING ---
              final String rawDate = item["created_at"]?.toString() ?? "";
              final String formattedDate = controller.formatTimeAgo(rawDate);

              final String ratingText = "${item["rating"] ?? 0}/5";
              final String comment = item["comment"] ?? "";
              final List<String> images = List<String>.from(
                item["images"] ?? [],
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ReviewCard(
                  userName: userName,
                  avatar: userAvatar,
                  date: formattedDate,
                  rating: ratingText,
                  review: comment,
                  images: images,
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      controller.rating > 0
                          ? controller.rating.toString()
                          : "0.0",
                      style: GoogleFonts.googleSans(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < controller.rating.round()
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    Text(
                      controller.reviewCount.toString(),
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                    Text(
                      "reviews_title".tr,
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(nStar: "5", value: 1, context: context),
                    _buildRatingBar(nStar: "4", value: 0.75, context: context),
                    _buildRatingBar(nStar: "3", value: 0.5, context: context),
                    _buildRatingBar(nStar: "2", value: 0.25, context: context),
                    _buildRatingBar(nStar: "1", value: 0.1, context: context),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRatingBar({
    required String nStar,
    required double value,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            nStar,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),
          SizedBox(width: 5),
          Icon(Icons.star, size: 16, color: Colors.grey),
          SizedBox(width: 5),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
