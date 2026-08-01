import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/review_hotel_services.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

part 'reviews_hotel_screen_binding.dart';
part 'reviews_hotel_screen_controller.dart';

class ReviewsHotelScreenView extends GetView<ReviewsHotelScreenViewController> {
  const ReviewsHotelScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Obx(
          () => Text(
            "${controller.reviewCount.value} ${'review'.tr}",
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.secondary,
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// Dynamic Rating Summary Block
              Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "good".tr,
                            style: GoogleFonts.googleSans(
                              color: const Color(0xFF078C2E),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: controller.overallScore.value.toStringAsFixed(1),
                                  style: GoogleFonts.googleSans(
                                    color: const Color(0xFF078C2E),
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: " / 5.0",
                                  style: GoogleFonts.googleSans(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ratingBar(
                            "cleaniness".tr,
                            double.tryParse(
                                  controller.breakdown["cleanliness"]
                                      .toString(),
                                ) ??
                                0.0,
                            context,
                          ),
                          const SizedBox(height: 10),
                          _ratingBar(
                            "location".tr,
                            double.tryParse(
                                  controller.breakdown["location"].toString(),
                                ) ??
                                0.0,
                            context,
                          ),
                          const SizedBox(height: 10),
                          _ratingBar(
                            "service".tr,
                            double.tryParse(
                                  controller.breakdown["staff"].toString(),
                                ) ??
                                0.0,
                            context,
                          ),
                          const SizedBox(height: 10),
                          _ratingBar(
                            "amenities".tr,
                            double.tryParse(
                                  controller.breakdown["value"].toString(),
                                ) ??
                                0.0,
                            context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              CustomButton(
                title: "write_review".tr,
                margin: EdgeInsets.all(0),
                onTap: () async {
                  final result = await Get.toNamed(
                    Routes.WRITE_REVIEW,
                    arguments: controller.hotel,
                  );
                  if (result == true) {
                    controller.getHotelReviews();
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildReviewItem(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context) {
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

  Widget _ratingBar(String title, double rating, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.googleSans(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: rating / 5.0,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF009A3F)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
