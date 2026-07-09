import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

part 'package_detail_screen_binding.dart';
part 'package_detail_screen_controller.dart';

class PackageDetailScreenView
    extends GetView<PackageDetailScreenViewController> {
  const PackageDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
            SizedBox(height: 30),

            _buildAboutSection(context),
            SizedBox(height: 10),

            _buildCheckBtn(context),
            SizedBox(height: 20),

            _buildItinerary(context),
            SizedBox(height: 20),
            _buildImportantInfo(context),
            SizedBox(height: 30),

            // reviews
            _buildReview(context),
            SizedBox(height: 30),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "from".tr,
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ),

          SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "\$16",
                    style: GoogleFonts.googleSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  TextSpan(
                    text: "per_adult".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.titleSmall!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => InkWell(
                    onTap: () => controller.pickDate(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall!.color,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            controller.selectedDate.value == null
                                ? "select_date_package".tr
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(controller.selectedDate.value!),
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: controller.decreaseAdult,
                          borderRadius: BorderRadius.circular(20),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(
                              Icons.remove,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        Text(
                          controller.adultCount.value.toString(),
                          style: GoogleFonts.googleSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),

                        InkWell(
                          onTap: controller.increaseAdult,
                          borderRadius: BorderRadius.circular(20),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          CustomButton(
            title: "check_availability".tr,
            margin: EdgeInsets.zero,
            onTap: controller.checkAvailability,
          ),
          SizedBox(height: 20),

          Obx(() {
            if (!controller.showAvailability.value) {
              return SizedBox();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "available_options_count".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  height: 460,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: Get.width * .75,
                          child: _availabilityCard(context),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 18, color: Colors.grey.shade700),
              SizedBox(width: 4),
              Text(
                "free_cancellation_package".tr,
                style: GoogleFonts.googleSans(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),

              SizedBox(width: 10),

              Text("⏰", style: GoogleFonts.googleSans(fontSize: 16)),

              SizedBox(width: 4),

              Text(
                "book_now_pay_later".tr,
                style: GoogleFonts.googleSans(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "package_sunrise_tour".tr,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _infoRow(Icons.schedule_outlined, "duration_hours".tr, context),
          _infoRow(Icons.language, "guide_language".tr, context),
          _infoRow(Icons.credit_card, "book_now_pay_later".tr, context),
          _infoRow(
            Icons.event_available,
            "free_cancellation_package".tr,
            context,
          ),

          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          SizedBox(height: 10),
          Text(
            "starting_time".tr,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "4:30 AM",
              style: GoogleFonts.googleSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "\$16.00",
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: "continue_btn".tr,
            onTap: () {
              Get.toNamed(
                Routes.PACKAGE_CHECKOUT,
                arguments: {
                  "title": "package_sunrise_tour".tr,
                  "image": "assets/images/homescreen/slider1.png",
                  "language": "English",
                  "startTime": "04:30 AM",
                  "date": controller.selectedDate.value,
                  "adultCount": controller.adultCount.value,
                  "price": 16.0,
                },
              );
            },
            margin: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.googleSans(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerary(BuildContext context) {
    return Bounceable(
      onTap: () {
        Get.toNamed(Routes.ITINERARY);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  "itinerary".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Spacer(),
                Text(
                  "see_itinerary".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantInfo(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.isImportantExpanded.toggle();
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "important_information".tr,
                          style: GoogleFonts.googleSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),

                      AnimatedRotation(
                        turns: controller.isImportantExpanded.value ? 0 : 0.5,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 30,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedCrossFade(
                  duration: Duration(milliseconds: 10),
                  crossFadeState: controller.isImportantExpanded.value
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,

                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),

                      /// WHAT TO BRING
                      Text(
                        "what_to_bring".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),

                      SizedBox(height: 10),

                      _bullet("bullet_shoes".tr, context),
                      _bullet("bullet_camera".tr, context),
                      _bullet("bullet_clothes".tr, context),

                      SizedBox(height: 16),

                      /// KNOW BEFORE YOU GO
                      Text(
                        "know_before_you_go".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),

                      SizedBox(height: 20),

                      Column(
                        children: [
                          _infoBullet("bullet_ticket_info".tr, context),
                          SizedBox(height: 12),
                          _infoBullet("bullet_arrival_info".tr, context),
                          SizedBox(height: 12),
                          _infoBullet("bullet_wheelchair_info".tr, context),
                          SizedBox(height: 12),
                          _infoBullet("bullet_child_info".tr, context),
                          SizedBox(height: 12),
                          _infoBullet("bullet_clothing_info".tr, context),
                          SizedBox(height: 12),
                          _infoBullet("bullet_itinerary_adjust".tr, context),
                        ],
                      ),
                    ],
                  ),

                  secondChild: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBullet(String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            "•",
            style: GoogleFonts.googleSans(
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),

        SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: GoogleFonts.googleSans(
              fontSize: 12,
              height: 1.7,
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "•",
          style: GoogleFonts.googleSans(
            fontSize: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.googleSans(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "about_this_activity".tr,
          style: GoogleFonts.googleSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),

        SizedBox(height: 20),

        _infoItem(
          Icons.calendar_month_outlined,
          "free_cancellation_package".tr,
          "sub_cancel_info".tr,
          context,
        ),

        _infoItem(
          Icons.location_on_outlined,
          "title_reserve_pay_later".tr,
          "sub_reserve_info".tr,
          context,
        ),

        _infoItem(
          Icons.access_time_outlined,
          "title_duration_range".tr,
          "sub_duration_info".tr,
          context,
        ),

        _infoItem(
          Icons.groups_outlined,
          "title_live_guide".tr,
          "sub_live_guide_info".tr,
          context,
        ),

        _infoItem(
          Icons.language_outlined,
          "title_languages_offered".tr,
          "sub_languages_info".tr,
          context,
        ),

        _infoItem(
          Icons.directions_bus_outlined,
          "title_pickup_included".tr,
          "sub_pickup_info".tr,
          context,
        ),

        _infoItem(
          Icons.group_add_outlined,
          "title_private_group".tr,
          "",
          context,
        ),
      ],
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.googleSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.googleSans(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
                "angkor_wat_title".tr,
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
              "4.9",
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
              "siem_reap_cambodia".tr,
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
              "km_away_text".tr,
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
                _circleButton("assets/svg/normalShare.svg", context),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "reviews_title".tr,
          style: GoogleFonts.googleSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 16),
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
          physics: NeverScrollableScrollPhysics(),
          itemCount: 3,
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
                    "reviews_title".tr,
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
