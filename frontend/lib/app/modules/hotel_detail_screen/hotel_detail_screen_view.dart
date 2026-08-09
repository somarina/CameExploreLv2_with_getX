import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/api/services/review_hotel_services.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery/gallery_view.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery_seeall/gallery_seeall_view.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

part 'hotel_detail_screen_binding.dart';
part 'hotel_detail_screen_controller.dart';

class HotelDetailScreenView extends GetView<HotelDetailScreenViewController> {
  const HotelDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomBar(context),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Stack(
          children: [
            _buildHeader(context),
            _buildThreeIcons(context),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Rating
            _buildContentTitle(context),
            SizedBox(height: 10),

            _buildAmenities(context),
            SizedBox(height: 20),

            _buildLocation(context),
            SizedBox(height: 30),

            _buildNearby(context),
            SizedBox(height: 20),

            _buildContact(context),
            SizedBox(height: 30),
            _buildContentGallery(context),
            SizedBox(height: 30),

            _buildReviews(context),
            SizedBox(height: 20),

            _buildPolicy(context),
            SizedBox(height: 20),
            // SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bounceable(
          onTap: () async {
            // Await the return value from the reviews screen
            final result = await Get.toNamed(
              Routes.REVIEW_HOTEL,
              arguments: controller.hotel,
            );

            // If a review was added/updated or returned true, refetch reviews
            if (result == true) {
              controller.getHotelReviews();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "review".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Obx(
          () => Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: controller.overallScore.value.toStringAsFixed(1),
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: " / 5.0",
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "good".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${controller.reviewCount.value} ${'reviews'.tr}",
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Obx(
          () => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextRatingRow(
                      context,
                      "cleaniness".tr,
                      double.tryParse(
                            controller.breakdown["cleanliness"].toString(),
                          ) ??
                          0.0,
                    ),
                    const SizedBox(height: 10),
                    _buildTextRatingRow(
                      context,
                      "location".tr,
                      double.tryParse(
                            controller.breakdown["location"].toString(),
                          ) ??
                          0.0,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 50),

              // Right Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextRatingRow(
                      context,
                      "service".tr,
                      double.tryParse(
                            controller.breakdown["staff"].toString(),
                          ) ??
                          0.0,
                    ),
                    const SizedBox(height: 10),
                    _buildTextRatingRow(
                      context,
                      "amenities".tr,
                      double.tryParse(
                            controller.breakdown["value"].toString(),
                          ) ??
                          0.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildReviewItem(context),
      ],
    );
  }

  Widget _buildTextRatingRow(BuildContext context, String label, double score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Text(
          score.toStringAsFixed(1),
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context) {
    // 1. Get the HomeScreenController instance
    final profileController = Get.find<HomeScreenController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.reviewsList.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              "no_reviews_yet".tr,
              style: GoogleFonts.googleSans(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      // 2. Access the current user model reactively inside Obx
      final currentUser = profileController.user.value;

      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // --- LIMITED TO 2 ITEMS MAXIMUM ---
        itemCount: controller.reviewsList.length.clamp(0, 2),
        itemBuilder: (context, index) {
          final item = controller.reviewsList[index];

          // Check for nested user object from review payload
          final Map<String, dynamic>? userObj = item["user"] is Map
              ? Map<String, dynamic>.from(item["user"])
              : null;

          // Match review owner with logged in user or fallback to payload
          final String reviewUserId = (item["user_id"] ?? userObj?["id"] ?? "")
              .toString();
          final bool isCurrentUser =
              currentUser != null &&
              (currentUser.id == reviewUserId || reviewUserId.isEmpty);

          // Get dynamic Name
          final String userName = isCurrentUser && currentUser.name.isNotEmpty
              ? currentUser.name
              : (userObj?["name"] ??
                    userObj?["username"] ??
                    item["user_name"] ??
                    item["username"] ??
                    "Anonymous User");

          // Get dynamic Avatar
          final String userAvatar =
              isCurrentUser && currentUser.avatar.isNotEmpty
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
          final List<String> images = List<String>.from(item["images"] ?? []);

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
    });
  }

  Widget _buildPolicy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "policies".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.access_time_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "checkin_out".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "checkin_".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "checkout_".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "front_desk".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "main_guest".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/child.svg",
              width: 24,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "child_policies".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "child_policies_stay".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "child_policies_fees".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/Restaurant.svg",
              width: 24,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "breakfast_title".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "breakfast_availability".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "breakfast_fees".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/pet.svg",
              width: 24,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "pet".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "pet_allowance".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "pet_service_animals".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentGallery(BuildContext context) {
    if (controller.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
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
              return GestureDetector(
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
    );
  }

  Widget _buildContact(BuildContext context) {
    // Hide the entire contact section if both phone and email are missing/null
    if (!controller.hasContactInfo) {
      return const SizedBox.shrink();
    }

    final phone = controller.phoneNum;
    final email = controller.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "contact".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 20),

        // Phone Row
        if (phone != null && phone.trim().isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "(+855) $phone",
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Email Row
        if (email != null && email.trim().isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNearby(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bounceable(
          onTap: () => controller.showNearbyBottomSheet(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "nearby_poplular".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Obx(() {
          if (controller.isPlacesLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final displayNearby = controller.nearbyPlaces.take(3).toList();
          final displayTrending = controller.trendingPlaces.take(3).toList();

          if (displayNearby.isEmpty && displayTrending.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "No places found nearby.",
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 NEARBY PLACES (TOP 3)
              if (displayNearby.isNotEmpty) ...[
                Text(
                  "near_places".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayNearby.length,
                  itemBuilder: (context, index) {
                    return controller._buildPlaceItem(
                      context,
                      displayNearby[index],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              // 🔥 TRENDING PLACES (TOP 3)
              if (displayTrending.isNotEmpty) ...[
                Text(
                  "trending".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTrending.length,
                  itemBuilder: (context, index) {
                    return controller._buildPlaceItem(
                      context,
                      displayTrending[index],
                    );
                  },
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLocation(BuildContext context) {
    final latitude = controller.hotel["latitude"] ?? 0;
    final longitude = controller.hotel["longitude"] ?? 0;

    final address = controller.address;

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

        SizedBox(height: 10),

        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 5),

          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),

          child: Padding(
            padding: EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// MAP CARD
                Container(
                  width: double.infinity,
                  height: 160,

                  decoration: BoxDecoration(
                    color: Color(0xffE8EEF3),
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

                        child: Container(
                          padding: EdgeInsets.symmetric(
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
                                color: Colors.black.withOpacity(.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),

                          child: Text(
                            controller.hotel["name_en"] ?? "",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                /// ADDRESS + COPY
                Container(
                  padding: EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    children: [
                      /// 60% ADDRESS
                      Expanded(
                        flex: 6,

                        child: Text(
                          address,

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.googleSans(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ),

                      SizedBox(width: 10),

                      /// 30% LAT LNG
                      Expanded(
                        flex: 3,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Lat: $latitude",
                              style: GoogleFonts.googleSans(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),

                            Text(
                              "Lng: $longitude",
                              style: GoogleFonts.googleSans(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 1,

                        child: Bounceable(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: "$latitude,$longitude"),
                            );

                            Get.snackbar(
                              "Copied",
                              "Coordinates copied",
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 1),
                              colorText: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            );
                          },

                          child: Icon(
                            Icons.copy,
                            color: Colors.green,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18),

                /// GET DIRECTION BUTTON
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

                      onTap: () {
                        controller.openGoogleMaps();
                      },

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.navigation, color: Colors.white),

                          SizedBox(width: 8),

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
    );
  }

  Widget _buildAmenities(BuildContext context) {
    Widget amenityIcon(String? iconUrl) {
      if (iconUrl == null || iconUrl.isEmpty) {
        return SizedBox(
          width: 16,
          height: 16,

          child: Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      return SvgPicture.network(
        iconUrl,
        width: 16,
        height: 16,
        placeholderBuilder: (context) {
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      );
    }

    Widget amenityItem(dynamic amenity) {
      String name = "";
      String? iconUrl;

      // API returns Map
      if (amenity is Map) {
        name = amenity["name"] ?? "";
        iconUrl = amenity["icon_url"];
      }
      // API returns String
      else if (amenity is String) {
        name = amenity;
        iconUrl = null;
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 12),

        child: Row(
          children: [
            amenityIcon(iconUrl),

            SizedBox(width: 10),

            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.googleSans(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    List amenities = controller.hotel["amenities"] ?? [];

    int half = (amenities.length / 2).ceil();

    List left = amenities.take(half).toList();
    List right = amenities.skip(half).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          "popular_amenities".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              child: Column(
                children: left.map((e) {
                  return amenityItem(e);
                }).toList(),
              ),
            ),

            SizedBox(width: 20),

            Expanded(
              child: Column(
                children: right.map((e) {
                  return amenityItem(e);
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                controller.hotelName,
                style: GoogleFonts.googleSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 6),

        /// Location
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.green, size: 26),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                controller.address,
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  fontSize: 12,
                ),
              ),
            ),

            SizedBox(width: 4),
            // Bounceable(
            //   onTap: () {},
            //   child: Text(
            //     "view_map".tr,
            //     style: GoogleFonts.googleSans(
            //       color: Theme.of(context).colorScheme.primary,
            //       fontSize: 14,
            //       decoration: TextDecoration.underline,
            //       fontWeight: FontWeight.w600,
            //       decorationColor: Theme.of(context).colorScheme.primary,
            //     ),
            //   ),
            // ),
          ],
        ),

        Divider(),
        Column(
          children: [
            SizedBox(height: 6),
            Obx(
              () => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          );
                        }

                        return Text(
                          "${controller.overallScore.value.toStringAsFixed(1)} / 5.0",
                          style: GoogleFonts.googleSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "good".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${controller.reviewCount.value} ${'reviews'.tr}",
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "the staff were extremely friendly, welcoming, and helpful.".tr,
              style: GoogleFonts.googleSans(
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Divider(),
      ],
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

  Widget _buildThreeIcons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
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
                    SharePlus.instance.share(
                      ShareParams(text: "Check out this amazing hotel!"),
                    );
                  },
                  child: _circleButton("assets/svg/normalShare.svg", context),
                ),
                SizedBox(width: 16),
                // _circleButton("assets/svg/normalFav.svg", context),
                Obx(() {
                  final isFav = controller.favCtrl.isFavorite(
                    controller.hotel["id"].toString(),
                    FavoriteItemType.hotel,
                  );

                  return Bounceable(
                    onTap: () {
                      controller.favCtrl.toggleFavorite(
                        controller.hotel["id"].toString(),
                        FavoriteItemType.hotel,
                        context,
                      );
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          size: 26,
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Get.height * .36,
          width: Get.width,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: controller.images.length,
                onPageChanged: controller.currentIndex.call,
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
                      count: 3,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        expansionFactor: 3,
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 110,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "start_at".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "USD ",
                    style: GoogleFonts.googleSans(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${controller.rooms.isNotEmpty ? controller.rooms.first["price_per_night"] : 0}\$",
                    style: GoogleFonts.googleSans(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Spacer(),

          SizedBox(
            height: 50,
            width: Get.width * 0.5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Get.toNamed(Routes.CHOOSE_ROOM, arguments: controller.hotel);
              },
              child: Text(
                "choose_room".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
