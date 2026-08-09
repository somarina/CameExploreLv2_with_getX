import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/button_navbar/controllers/button_navbar_controller.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/cardPlace/card_place.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../controllers/home_screen_controller.dart';

class HomeScreenView extends GetView<HomeScreenController> {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.getProfile();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () {
          return controller.getProfile();
        },
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              SizedBox(height: 20),
              _buildSlider(context),
              SizedBox(height: 30),
              _buildTrendingPlaces(context),
              SizedBox(height: 30),
              _buildNearby(context),
              SizedBox(height: 20),
              // _buildTopPlaces(context),
              // SizedBox(height: 30),
              _buildFood(context),
              SizedBox(height: 30),
              _buildRestaurant(context),
              SizedBox(height: 30),
              _buildHotel(context),
              SizedBox(height: 30),
              _buildTravelPackage(context),
              SizedBox(height: 30),

              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Bounceable(
                          onTap: () {},
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white24,
                            backgroundImage: controller.isLoadingPf.value
                                ? null
                                : controller.getAvatar(),
                            child: controller.isLoadingPf.value
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  )
                                : (controller.getAvatar() == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 45,
                                          color: Colors.white,
                                        )
                                      : null),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // User details & Location
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isLoadingPf.value
                                    ? "${"hello".tr}..."
                                    : "${"hello".tr}, ${controller.user.value?.name ?? 'Guest'}",
                                style: AppFonts.fontHeader.copyWith(
                                  fontSize: 24,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              // Interactive Location Row
                              InkWell(
                                onTap: () => controller.getCurrentLocation(),
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xffEAEAEA),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: controller.isLoadingLocation.value
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            )
                                          : Text(
                                              controller.currentLocation.value,
                                              style: AppFonts.fontLocation,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Bounceable(
                          onTap: () {},
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xffEAEAEA),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Positioned(
            bottom: 9,
            left: 20,
            right: 20,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  Get.find<ButtonNavbarController>().changePage(1);
                },
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.primaryContainer,
                  filled: true,
                  hintText: "ស្វែងរកកន្លែងទេសចរណ៍...",
                  hintStyle: AppFonts.fontBtnSearch.copyWith(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    size: 30,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      width: 2,
                      color: Colors.transparent,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Banner Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeFactor: 0.16,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                onPageChanged: (index, reason) {
                  controller.changeIndex(index);
                },
              ),
              items: controller.imgList.map((img) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(img, fit: BoxFit.cover),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Carousel Dot Indicator
            Obx(
              () => AnimatedSmoothIndicator(
                activeIndex: controller.currentIndex.value,
                count: controller.imgList.length,
                effect: ExpandingDotsEffect(
                  dotWidth: 9,
                  dotHeight: 9,
                  dotColor: Colors.grey,
                  activeDotColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Categories Section
            _buildCategory(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Obx(() {
      // 1. Loading State
      if (controller.isLoadingCategory.value) {
        return const SizedBox(
          height: 110,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // 2. Empty State
      if (controller.categories.isEmpty) {
        return SizedBox(
          height: 110,
          child: Center(
            child: Text(
              "no_categories_found".tr,
              style: GoogleFonts.googleSans(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }

      // 3. Category Horizontal List
      return SizedBox(
        height: 110,
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final item = controller.categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Bounceable(
                onTap: () {
                  Get.toNamed(Routes.NEARBY_SCREEN, arguments: item);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: item["icon_url"] ?? "",
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isKhmer
                          ? (item['name_km'] ?? item['name'] ?? '')
                          : (item['name'] ?? ''),
                      style: GoogleFonts.googleSans(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildTrendingPlaces(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Tren_places".tr,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Spacer(),
              Bounceable(
                onTap: () {
                  Get.find<ButtonNavbarController>().changePage(1);
                },
                child: Row(
                  children: [
                    Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingPf.value && controller.places.isEmpty) {
              return SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.isLoadingPlaces.value &&
                controller.trendingPlaces.isEmpty) {
              return SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.filteredPackages.isEmpty) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    "no_place_found".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.trendingPlaces.length,
                itemBuilder: (context, index) {
                  final place = controller.trendingPlaces[index];

                  return Obx(
                    () => Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Bounceable(
                        onTap: () {
                          Get.toNamed(
                            Routes.DETAIL_PLACES,
                            arguments: controller.trendingPlaces[index],
                          );
                        },
                        child: CardPlace(
                          width: Get.width * 0.8,
                          image:
                              (place['image_url'] != null &&
                                  place['image_url'].toString().startsWith(
                                    'http',
                                  ))
                              ? place['image_url']
                              : "",
                          category: controller.getCategory(place),
                          title: controller.getPlaceName(place),
                          location: controller.getAddress(place),
                          rating: (place['rating'] != null)
                              ? double.tryParse(place['rating'].toString()) ??
                                    5.0
                              : 5.0,
                          review_count: place['review_count'] ?? 0,
                          distance:
                              "${controller.calculateDistance(place["latitude"], place["longitude"]).toStringAsFixed(2)} km",
                          isFavorite: controller.favoriteController.isFavorite(
                            place["id"].toString(),
                            FavoriteItemType.place,
                          ),

                          onFavorite: () =>
                              controller.favoriteController.toggleFavorite(
                                place["id"].toString(),
                                FavoriteItemType.place,
                                context,
                              ),
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

  Widget _buildNearby(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Text(
                "near_places".tr,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Spacer(),
              Bounceable(
                onTap: () => Get.toNamed(Routes.NEARBY_SCREEN),
                child: Row(
                  children: [
                    Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dynamic State Rendering inside Obx
          Obx(() {
            // 1. Loading State
            if (controller.isLoadingPlaces.value ||
                controller.isLoadingLocation.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // 2. Empty State
            if (controller.nearbyPlaces.isEmpty) {
              return Container(
                height: 120,
                margin: const EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                child: Text(
                  "no_nearby_places_found".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
              );
            }

            // 3. Data Loaded State
            return ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.nearbyPlaces.length,
              itemBuilder: (context, index) {
                final place = controller.nearbyPlaces[index];
                final placeId = place["id"].toString();

                // Safe favorite state check
                // final isFav = index < controller.favorites.length
                //     ? controller.favorites[index]
                //     : false;
                // final isFav = controller.favoriteController.isFavorite(
                //   placeId,
                //   FavoriteItemType.place,
                // );

                return Bounceable(
                  onTap: () {
                    Get.toNamed(Routes.DETAIL_PLACES, arguments: place);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Stack Image and Favorite Button
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: place["image_url"] ?? "",
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Obx(() {
                                final isFav = controller.favoriteController
                                    .isFavorite(
                                      placeId,
                                      FavoriteItemType.place,
                                    );

                                return GestureDetector(
                                  onTap: () {
                                    controller.favoriteController
                                        .toggleFavorite(
                                          placeId,
                                          FavoriteItemType.place,
                                          context,
                                        );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav
                                          ? Colors.red
                                          : Theme.of(
                                              context,
                                            ).textTheme.titleSmall!.color,
                                      size: 18,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(width: 10),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.getPlaceName(place),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.fontsSubTitlew500.copyWith(
                                  fontSize: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Address Row
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleSmall!.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      controller.getAddress(place),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.googleSans(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.titleSmall!.color,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Rating & Distance Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFFFB800),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (place["rating"] ?? 0)
                                        .toDouble()
                                        .toString(),

                                    style: GoogleFonts.googleSans(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.color,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  const Icon(
                                    Icons.near_me_outlined,
                                    size: 18,
                                    color: Color(0xFFADB5BD),
                                  ),
                                  const SizedBox(width: 2),

                                  Text(
                                    controller.getFormattedDistance(
                                      place["latitude"],
                                      place["longitude"],
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.color,
                                    ),
                                  ),

                                  const Spacer(),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      controller.getCategory(place),
                                      style: GoogleFonts.googleSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopPlaces(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "top_place".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Spacer(),
              Bounceable(
                onTap: () {
                  Get.find<ButtonNavbarController>().changePage(1);
                },
                child: Row(
                  children: [
                    Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingPf.value && controller.places.isEmpty) {
              return SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.isLoadingPlaces.value &&
                controller.topPlaces.isEmpty) {
              return SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.topPlaces.length,
                itemBuilder: (context, index) {
                  final place = controller.topPlaces[index];
                  return Obx(
                    () => Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Bounceable(
                        onTap: () {
                          Get.toNamed(
                            Routes.DETAIL_PLACES,
                            arguments: controller.topPlaces[index],
                          );
                        },

                        child: CardPlace(
                          width: Get.width * 0.8,
                          image:
                              (place['image_url'] != null &&
                                  place['image_url'].toString().startsWith(
                                    'http',
                                  ))
                              ? place['image_url']
                              : "",
                          category: controller.getCategory(place),
                          title: controller.getPlaceName(place),
                          location: controller.getAddress(place),
                          rating: (place['rating'] != null)
                              ? double.tryParse(place['rating'].toString()) ??
                                    5.0
                              : 5.0,
                          review_count: place['review_count'] ?? 0,
                          distance:
                              "${controller.calculateDistance(place["latitude"], place["longitude"]).toStringAsFixed(2)} km",
                          isFavorite: controller.favorites[index],
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

  Widget _buildHotel(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                // "${"hotel".tr} in ${controller.currentLocation.split(',').first}",
                "${"hotel".tr} ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Bounceable(
                    onTap: () {
                      Get.find<ButtonNavbarController>().changePage(1);
                    },
                    child: Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 270,
            child: Obx(() {
              if (controller.isLoadingHotels.value) {
                return SizedBox(
                  height: 270,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.hotels.isEmpty) {
                return const Center(child: Text("No hotels found"));
              }
              if (controller.filteredPackages.isEmpty) {
                return SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      "no_hotel_found".tr,
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).textTheme.titleSmall!.color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.filteredHotels.length,
                itemBuilder: (context, index) {
                  final hotel = controller.filteredHotels[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Bounceable(
                      onTap: () {
                        Get.toNamed(Routes.HOTEL_DETAIL, arguments: hotel);
                      },
                      child: Obx(
                        () => CardPlace(
                          width: Get.width * 0.8,
                          image:
                              hotel["image_url"] ?? hotel["cover_image"] ?? "",
                          category: "hotel_category".tr,
                          title: controller.isKhmer
                              ? (hotel["name_km"] ??
                                    hotel["name_kh"] ??
                                    hotel["name_en"] ??
                                    "Hotel")
                              : (hotel["name_en"] ??
                                    hotel["name_km"] ??
                                    "Hotel"),
                          location: controller.isKhmer
                              ? (hotel["address_km"] ??
                                    hotel["address_en"] ??
                                    "")
                              : (hotel["address_en"] ??
                                    hotel["address_km"] ??
                                    ""),

                          rating:
                              (double.tryParse(
                                (hotel["rating"] ?? 0.0).toString(),
                              ) ??
                              0.0),
                          review_count:
                              int.tryParse(
                                (hotel["review_count"] ??
                                        hotel["reviews_count"] ??
                                        0)
                                    .toString(),
                              ) ??
                              0,
                          distance:
                              "${controller.calculateDistance(hotel["latitude"], hotel["longitude"]).toStringAsFixed(2)} km",
                          isFavorite: controller.favoriteController.isFavorite(
                            hotel["id"].toString(),
                            FavoriteItemType.hotel,
                          ),

                          onFavorite: () =>
                              controller.favoriteController.toggleFavorite(
                                hotel["id"].toString(),
                                FavoriteItemType.hotel,
                                context,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelPackage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Text(
                "travel_packeges".tr,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Spacer(),
              Bounceable(
                onTap: () {
                  Get.find<ButtonNavbarController>().changePage(1);
                },
                child: Row(
                  children: [
                    Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Obx(() {
            // 1. Loading State
            if (controller.isLoadingPackages.value ||
                controller.isLoadingLocation.value) {
              return const SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // 2. Empty State (Checked against filteredPackages)
            if (controller.filteredPackages.isEmpty) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    "no_packages_found".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            // 3. Loaded Data List
            return SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.filteredPackages.length,
                itemBuilder: (context, index) {
                  final package = controller.filteredPackages[index];

                  // Safe check for favorites list length
                  final isFav = index < controller.favorites.length
                      ? controller.favorites[index]
                      : false;

                  // Localization for title
                  final String packageTitle = controller.isKhmer
                      ? (package["name_km"] ?? package["name_en"] ?? "")
                      : (package["name_en"] ?? package["name_km"] ?? "");

                  // Dynamic Location Fallback (NO MORE HARDCODED SIEM REAP)
                  final String packageLocation =
                      package["address_en"] ??
                      package["address_km"] ??
                      package["location"] ??
                      package["province"] ??
                      controller.currentLocation.value;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Bounceable(
                      onTap: () {
                        Get.toNamed(Routes.PACKAGE_DETAIL, arguments: package);
                      },
                      child: CardPlace(
                        width: Get.width * 0.8,
                        image: package["image_url"] ?? "",
                        category: "Travel-Package".tr,
                        title: packageTitle,
                        location: packageLocation,
                        rating: (package["rating"] ?? 0).toDouble(),
                        review_count: package["review_count"] ?? 0,
                        distance:
                            "\$${package["price_per_person"] ?? 0}/person",
                        isFavorite: controller.favoriteController.isFavorite(
                          package["id"].toString(),
                          FavoriteItemType.package,
                        ),

                        onFavorite: () =>
                            controller.favoriteController.toggleFavorite(
                              package["id"].toString(),
                              FavoriteItemType.package,
                              context,
                            ),
                        showNavigationIcon: false,
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

  Widget _buildFood(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "food".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Spacer(),
              Bounceable(
                onTap: () {
                  Get.find<ButtonNavbarController>().changePage(1);
                },
                child: Row(
                  children: [
                    Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingPlaces.value &&
                controller.foodPlaces.isEmpty) {
              return const SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.foodPlaces.isEmpty) {
              return const SizedBox(
                height: 270,
                child: Center(child: Text("No food items found")),
              );
            }

            return SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.foodPlaces.length,
                itemBuilder: (context, index) {
                  final place = controller.foodPlaces[index];

                  // final isFav = index < controller.favorites.length
                  //     ? controller.favorites[index]
                  //     : false;

                  // Outer Obx handles updates, no inner Obx needed here
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Bounceable(
                      onTap: () {
                        Get.toNamed(
                          Routes.DETAIL_PLACES,
                          arguments: controller.foodPlaces[index],
                        );
                      },
                      child: Obx(() {
                        final placeId = place["id"].toString();

                        final isFavorite = controller.favoriteController
                            .isFavorite(placeId, FavoriteItemType.place);

                        return CardPlace(
                          width: Get.width * 0.8,
                          image:
                              (place['image_url'] != null &&
                                  place['image_url'].toString().startsWith(
                                    'http',
                                  ))
                              ? place['image_url']
                              : "",
                          category: controller.getCategory(place),
                          title: controller.getPlaceName(place),
                          location: controller.getAddress(place),
                          distance: "",
                          rating: (place["rating"] ?? 0).toDouble(),
                          review_count: place['review_count'] ?? 0,
                          isFavorite: isFavorite,
                          onFavorite: () =>
                              controller.favoriteController.toggleFavorite(
                                placeId,
                                FavoriteItemType.place,
                                context,
                              ),
                        );
                      }),
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

  Widget _buildRestaurant(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Restaurant".tr,
                style: AppFonts.fontsSubTitlew500.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Spacer(),
              Bounceable(
                onTap: () {
                  Get.find<ButtonNavbarController>().changePage(1);
                },
                child: Row(
                  children: [
                    Text(
                      "see_all".tr,
                      style: AppFonts.fontsSubTitlew500.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            // Show loader while fetching initial data
            if (controller.isLoadingPlaces.value && controller.places.isEmpty) {
              return const SizedBox(
                height: 270,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Empty state handler
            if (controller.restaurantPlaces.isEmpty) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    "no_restaurant_found".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.restaurantPlaces.length,
                itemBuilder: (context, index) {
                  final place = controller.restaurantPlaces[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Bounceable(
                      onTap: () {
                        Get.toNamed(Routes.DETAIL_PLACES, arguments: place);
                      },
                      child: CardPlace(
                        width: Get.width * 0.8,
                        image:
                            (place['image_url'] != null &&
                                place['image_url'].toString().startsWith(
                                  'http',
                                ))
                            ? place['image_url']
                            : "",
                        category: controller.getCategory(place),
                        title: controller.getPlaceName(place),
                        location: controller.getAddress(place),
                        rating: (place['rating'] != null)
                            ? double.tryParse(place['rating'].toString()) ?? 5.0
                            : 5.0,
                        review_count: place['review_count'] ?? 0,
                        distance: controller.getFormattedDistance(
                          place["latitude"],
                          place["longitude"],
                        ),
                        isFavorite: controller.favoriteController.isFavorite(
                          place["id"].toString(),
                          FavoriteItemType.place,
                        ),

                        onFavorite: () =>
                            controller.favoriteController.toggleFavorite(
                              place["id"].toString(),
                              FavoriteItemType.place,
                              context,
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
}
