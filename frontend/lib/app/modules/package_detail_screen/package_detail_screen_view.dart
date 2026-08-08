import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/api/services/review_place.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery/gallery_view.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery_seeall/gallery_seeall_view.dart';
import 'package:frontend/app/modules/detail_places_screen/detail_places_screen_view.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            _buildHeader(context),
            _buildThreeIcons(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Get.height * .32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContentTitle(context),
            const SizedBox(height: 30),

            _buildAboutSection(context),
            const SizedBox(height: 10),

            _buildContentGallery(context),
            const SizedBox(height: 20),

            _buildTags(context),
            const SizedBox(height: 30),

            _buildCheckBtn(context),
            const SizedBox(height: 20),

            _buildItinerary(context),
            const SizedBox(height: 20),
            // _buildImportantInfo(context),
            const SizedBox(height: 30),

            _buildReview(context),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    if (controller.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            const Spacer(),
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
    );
  }

  Widget _buildCheckBtn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "\$${controller.price.toStringAsFixed(0)} ",
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
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  children: [
                    Container(
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
                              onTap: () {
                                controller.increaseAdult(context);
                              },
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
                    const SizedBox(height: 4),
                    Text(
                      "${"max_people".tr}: ${controller.maxPeople}",
                      style: GoogleFonts.googleSans(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: "check_availability".tr,
            margin: EdgeInsets.zero,
            onTap: controller.checkAvailability,
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (!controller.showAvailability.value) {
              return const SizedBox.shrink();
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
                const SizedBox(height: 16),
                SizedBox(
                  height: 480,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 1,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                "free_cancellation_package".tr,
                style: GoogleFonts.googleSans(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 10),
              Text("⏰", style: GoogleFonts.googleSans(fontSize: 16)),
              const SizedBox(width: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.packageName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.schedule_outlined,
            "${controller.duration} ${'days'.tr}",
            context,
          ),
          _infoRow(Icons.language, "English / Khmer", context),
          _infoRow(Icons.credit_card, "book_now_pay_later".tr, context),
          _infoRow(
            Icons.event_available,
            "free_cancellation_package".tr,
            context,
          ),
          Divider(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            height: 20,
          ),
          const SizedBox(height: 6),
          Text(
            "starting_time".tr,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // --- DYNAMIC START TIME SELECTION CHIPS ---
          Obx(() {
            final times = controller.startTimes;
            if (times.isEmpty) {
              return const SizedBox.shrink();
            }

            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: times.map((time) {
                final isSelected = controller.selectedStartTime.value == time;
                return GestureDetector(
                  onTap: () => controller.selectedStartTime.value = time,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.googleSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 40),
          Obx(
            () => Text(
              "\$${(controller.price * controller.adultCount.value).toStringAsFixed(2)}",
              style: GoogleFonts.googleSans(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: "continue_btn".tr,
            onTap: () {
              Get.toNamed(
                Routes.PACKAGE_CHECKOUT,
                arguments: {
                  "id": controller.package["id"],
                  "title": controller.packageName,
                  "image": controller.image.isNotEmpty
                      ? controller.image
                      : "",
                  "language": "English",
                  "startTime": controller.selectedStartTime.value,
                  "date": controller.selectedDate.value,
                  "adultCount": controller.adultCount.value,
                  "price": controller.price,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        Get.toNamed(
          Routes.ITINERARY,
          arguments: {"package": controller.package},
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                const Spacer(),
                Text(
                  "see_itinerary".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        duration: const Duration(milliseconds: 200),
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
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: controller.isImportantExpanded.value
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        "what_to_bring".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _bullet("bullet_shoes".tr, context),
                      _bullet("bullet_camera".tr, context),
                      _bullet("bullet_clothes".tr, context),
                      const SizedBox(height: 16),
                      Text(
                        "know_before_you_go".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          _infoBullet("bullet_ticket_info".tr, context),
                          const SizedBox(height: 12),
                          _infoBullet("bullet_arrival_info".tr, context),
                          const SizedBox(height: 12),
                          _infoBullet("bullet_wheelchair_info".tr, context),
                          const SizedBox(height: 12),
                          _infoBullet("bullet_child_info".tr, context),
                          const SizedBox(height: 12),
                          _infoBullet("bullet_clothing_info".tr, context),
                          const SizedBox(height: 12),
                          _infoBullet("bullet_itinerary_adjust".tr, context),
                        ],
                      ),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
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
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            "•",
            style: GoogleFonts.googleSans(
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
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
        const SizedBox(width: 10),
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
        const SizedBox(height: 20),
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
        // _infoItem(
        //   Icons.access_time_outlined,
        //   "title_duration_range".tr,
        //   "${controller.duration} ${'days'.tr}",
        //   context,
        // ),
        _infoItem(
          Icons.groups_outlined,
          "title_live_guide".tr,
          "sub_live_guide_info".tr,
          context,
        ),
        _infoItem(
          Icons.language_outlined,
          "title_languages_offered".tr,
          "English / Khmer",
          context,
        ),
        _infoItem(
          Icons.directions_bus_outlined,
          "title_pickup_included".tr,
          "sub_pickup_info".tr,
          context,
        ),
        // _infoItem(
        //   Icons.group_add_outlined,
        //   "title_private_group".tr,
        //   // "max_people_count".trArgs([controller.maxPeople.toString()]),
        //   "",
        //   context,
        // ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(width: 10),
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
                  const SizedBox(height: 6),
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
        Obx(
          () => Row(
            children: [
              Expanded(
                child: Text(
                  controller.packageName,
                  style: GoogleFonts.googleSans(
                    fontSize: 24,
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
                " (${controller.reviewCount.toString()})",
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.green,
              size: 26,
            ),
            const SizedBox(width: 6),

            // --- DYNAMIC LOCATION DISPLAY ---
            Obx(
              () => Text(
                controller.packageLocation,
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  fontSize: 14,
                ),
              ),
            ),

            const Spacer(),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
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
                Bounceable(
                  onTap: () {
                    SharePlus.instance.share(
                      ShareParams(text: "Check out this amazing package!"),
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
          child: Obx(() {
            final imagesList = controller.images;
            if (imagesList.isEmpty) {
              return Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              );
            }
            return Stack(
              children: [
                PageView.builder(
                  itemCount: imagesList.length,
                  onPageChanged: controller.currentIndex.call,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: imagesList[index],
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
                    child: AnimatedSmoothIndicator(
                      activeIndex: controller.currentIndex.value,
                      count: imagesList.length,
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
              ],
            );
          }),
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

          // Read reactive user data from HomeScreenController
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            nStar,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 5),
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
