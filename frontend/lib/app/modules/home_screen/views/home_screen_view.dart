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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
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
            SizedBox(height: 30),
            _buildTopPlaces(context),
            SizedBox(height: 30),
            _buildHotel(context),
            SizedBox(height: 30),
            _buildTravelPackage(context),
            SizedBox(height: 30),

            SizedBox(height: 60),
          ],
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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Obx(
              () => controller.isLoadingPf.value
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Bounceable(
                                onTap: () {},
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: controller.isLoadingPf.value
                                      ? null
                                      : controller.getAvatar(),
                                ),
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Text(
                                        "សួស្តី, ${controller.user.value?.name ?? 'Guest'}",
                                        style: AppFonts.fontHeader.copyWith(
                                          fontSize: 26,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "សួស្តី, Naihuoy", 
                               
                              style: AppFonts.fontHeader,
                              overflow: TextOverflow.ellipsis,
                            ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xffEAEAEA),
                                          size: 24,
                                        ),
                                        SizedBox(width: 5),

                                        // Expanded(
                                        //   child: Obx(
                                        //     () => Text(
                                        //       // controller.currentLocation.value,
                                        //       controller.currentLocation,

                                        //       style: AppFonts.fontLocation,
                                        //       overflow: TextOverflow.ellipsis,
                                        //     ),
                                        //   ),
                                        // ),
                                        Expanded(
                                          child: Text(
                                            // controller.currentLocation.value,
                                            controller.currentLocation,

                                            style: AppFonts.fontLocation,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(width: 2, color: Colors.transparent),
                  ),
                  border: OutlineInputBorder(),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: Get.width,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: Color(0xff1A1A1A),
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: .circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
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
            SizedBox(height: 8),
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
            SizedBox(height: 30),
            _buildCategory(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,

              itemBuilder: (context, index) {
                final item = controller.categories[index];
                return Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Bounceable(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff009A3F),
                          ),
                          child: Center(child: Text("icon")),
                        ),
                        SizedBox(height: 10),
                        Text(item['name'] ?? ''),
                      ],
                    ),
                  ),
                );
              },
              itemCount: controller.categories.length,
            ),
          ),
        ],
      ),
    );
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
                          category: place['category'] ?? "General",
                          title: place['name'] ?? "Unknown Place",
                          location: "${place['province'] ?? 'Cambodia'}",
                          rating: (place['rating'] != null)
                              ? double.tryParse(place['rating'].toString()) ??
                                    5.0
                              : 5.0,
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
    return Bounceable(
      onTap: () {
        Get.toNamed(Routes.DETAIL_PLACES);
      },
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CardPlace(
            width: Get.width * 0.8,
            image: "assets/images/homescreen/slider1.png",
            category: "Temple",
            title: "Angkor Wat",
            location: "Siem Reap, Cambodia",
            rating: 4.9,
            distance: "200.10 km",

            // Replace with your real place ID
            isFavorite: controller.favoriteController.favorites[1] ?? false,

            onFavorite: () {
              controller.toggleFavorite(1);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNearby(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "near_places".tr,
            style: AppFonts.fontsSubTitlew500.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Obx(
            () => ListView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.nearbyPlaces.length,
              itemBuilder: (context, index) {
                final place = controller.nearbyPlaces[index];
                return Bounceable(
                  onTap: () {
                    Get.toNamed(
                      Routes.DETAIL_PLACES,
                      arguments: controller.nearbyPlaces[index],
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            place["image_url"],
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place["name"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.fontsSubTitlew500.copyWith(
                                  fontSize: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 8),

                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleSmall!.color,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      place["province"],
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

                              SizedBox(height: 12),

                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Color(0xFFFFB800),
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    (place["rating"] ?? 0)
                                        .toDouble()
                                        .toStringAsFixed(1),
                                    style: GoogleFonts.googleSans(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.color,
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 18,
                                    color: Color(0xFFADB5BD),
                                  ),

                                  // SizedBox(width: 4),
                                  Text(
                                    "${controller.calculateDistance(place["latitude"], place["longitude"]).toStringAsFixed(2)} km",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.color,
                                    ),
                                  ),

                                  Spacer(),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      place["category"],
                                      style: TextStyle(
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
            ),
          ),
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
              Row(
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
                          category: place['category'] ?? "General",
                          title: place['name'] ?? "Unknown Place",
                          location: "${place['province'] ?? 'Cambodia'}",
                          rating: (place['rating'] != null)
                              ? double.tryParse(place['rating'].toString()) ??
                                    5.0
                              : 5.0,
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
                "hotel".tr,
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Bounceable(
                  onTap: () {
                    Get.toNamed(Routes.HOTEL_DETAIL);
                  },
                  child: Obx(
                    () => Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: CardPlace(
                        width: Get.width * 0.8,
                        image: "assets/images/homescreen/slider1.png",
                        category: "Temple",
                        title: "អង្គរវត្ត",
                        location: "សៀមរាប, ប្រទេសកម្ពុជា",
                        rating: 4.9,
                        distance: "200.10 km",
                        isFavorite: controller.favorites[index],
                        onFavorite: () => controller.toggleFavorite(index),
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

  Widget _buildTravelPackage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "travel_packeges".tr,
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
          Bounceable(
            onTap: () {
              Get.toNamed(Routes.PACKAGE_DETAIL);
            },
            child: SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Obx(
                    () => Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: CardPlace(
                        width: Get.width * 0.8,
                        image: "assets/images/homescreen/slider1.png",
                        category: "Temple",
                        title: "អង្គរវត្ត",
                        location: "សៀមរាប, ប្រទេសកម្ពុជា",
                        rating: 4.9,
                        distance: "200.10 km",
                        isFavorite: controller.favorites[index],
                        onFavorite: () => controller.toggleFavorite(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
