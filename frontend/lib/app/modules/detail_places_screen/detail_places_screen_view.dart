import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            /// Title + Rating
            _buildContentTitle(context),
            SizedBox(height: 30),

            /// About
            _buildContentAbout(context),
            SizedBox(height: 30),

            /// Opening Hours
            _buildContentOpenHour(context),
            SizedBox(height: 30),

            /// Gallery
            _buildContentGallery(context),
            SizedBox(height: 30),

            //contact
            if (controller.phone != null) ...[
              _buildContact(context),
              SizedBox(height: 30),
            ],
            //location
            _buildLocation(context),
            SizedBox(height: 40),

            //nearby
            _buildNearby(context),
            SizedBox(height: 30),

            //reviews
            _buildReview(context),
            SizedBox(height: 30),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildNearby(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "near_places".tr,
              style: GoogleFonts.googleSans(
                fontSize: 20,
                fontWeight: .w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 20),
        SizedBox(
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
                    isFavorite: controller.homeCtrl.favorites[index],
                    onFavorite: () => controller.homeCtrl.toggleFavorite(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
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
                            controller.place['name'] ?? "Unknown Place",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.googleSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                /// ADDRESS
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${controller.place['province']}, Cambodia",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.googleSans(color: Colors.grey[700]),
                      ),
                      Spacer(),
                      Icon(Icons.navigation, size: 16, color: Colors.grey[700]),
                      Text(
                        "${controller.homeCtrl.calculateDistance(controller.place["latitude"], controller.place["longitude"]).toStringAsFixed(2)} km",

                        style: GoogleFonts.googleSans(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18),

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
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 18,
                ),
                SizedBox(width: 12),
                Text(
                  "(+855) ${controller.place['phoneNum']}",
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: .w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Spacer(),
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
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "gallary".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),

        SizedBox(height: 20),

        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 0),
            itemCount: 3,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/homescreen/slider1.png",
                  width: Get.width * .4,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentOpenHour(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "opening_hours".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),
        Container(
          // margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  children: [
                    Icon(
                      Icons.access_time_sharp,
                      color: Colors.green,
                      size: 24,
                    ),

                    SizedBox(width: 12),
                    Row(
                      children: [
                        Text(
                          "open_".tr,
                          style: GoogleFonts.googleSans(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          " • 5am - 5pm",
                          style: GoogleFonts.googleSans(
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall!.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),

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
                  SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.openingHours.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.openingHours[index];

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
        ),
      ],
    );
  }

  Widget _buildContentAbout(BuildContext context) {
    return Column(
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
          controller.place['description'],
          style: GoogleFonts.googleSans(
            color: Theme.of(context).textTheme.titleSmall!.color,
            height: 1.8,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContentTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                controller.place['name'] ?? "Unknown Place",
                style: GoogleFonts.googleSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Icon(Icons.star, color: Colors.amber.shade700, size: 24),
            SizedBox(width: 4),
            Text(
              controller.place['rating'].toString(),
              style: GoogleFonts.googleSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
            Text(
              " (500+)",
              style: GoogleFonts.googleSans(
                fontSize: 16,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        /// Location
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.green, size: 26),
            SizedBox(width: 6),
            Text(
              "${controller.place['province']}, Cambodia",
              style: GoogleFonts.googleSans(
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontSize: 14,
              ),
            ),
            Spacer(),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              "${controller.homeCtrl.calculateDistance(controller.place["latitude"], controller.place["longitude"]).toStringAsFixed(2)} km",

              style: GoogleFonts.googleSans(
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
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
                      ShareParams(text: "Check out this amazing place!"),
                    );
                  },
                  child: _circleButton("assets/svg/normalShare.svg", context),
                ),
                SizedBox(width: 16),
                _circleButton("assets/svg/normalFav.svg", context),
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
              PageView(
                onPageChanged: controller.currentIndex.call,
                children: [
                  Image.asset(
                    "assets/images/homescreen/slider1.png",
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    "assets/images/homescreen/slider2.png",
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    "assets/images/homescreen/slider3.png",
                    fit: BoxFit.cover,
                  ),
                ],
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
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "review".tr,
          style: AppFonts.fontsSubTitlew500.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRating(context),
              CustomButton(
                title: "write_review".tr,
                onTap: () {
                  Get.toNamed(Routes.PACKAGE_REVIEW);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ReviewCard(
                userName: "Anonymous User",
                date: "${"stayed_in".tr} Apr 2026",
                rating: "7/10",
                review:
                    "Overall, I love the atmosphere but just some rooms have problems with doors and toilets and also not recommend ...",
                images: [
                  "https://images.unsplash.com/photo-1566073771259-6a8506099945",
                  "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa",
                  "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267",
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20, top: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "4.9",
                    style: GoogleFonts.googleSans(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                  Text(
                    "2,847",
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                    ),
                  ),
                  Text(
                    "reviews",
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(nStar: "5", value: 0.9, context: context),
                    _buildRatingBar(nStar: "4", value: 0.7, context: context),
                    _buildRatingBar(nStar: "3", value: 0.5, context: context),
                    _buildRatingBar(nStar: "2", value: 0.3, context: context),
                    _buildRatingBar(nStar: "1", value: 0.1, context: context),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
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
