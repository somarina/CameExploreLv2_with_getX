import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

part 'package_write_review_binding.dart';
part 'package_write_review_controller.dart';

class PackageWriteReviewView extends GetView<PackageWriteReviewViewController> {
  const PackageWriteReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "write_review".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildOverallRate(context),
            SizedBox(height: 20),
            _reviewCard(context),
            SizedBox(height: 20),
            _photoCard(context),
            SizedBox(height: 30),
            _submitButton(),
            SizedBox(height: 16),
            Text(
              "review_public_notice".tr,
              style: GoogleFonts.googleSans(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRate(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "overall_rating".tr, // Key for "Overall rating"
            style: GoogleFonts.googleSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          SizedBox(height: 28),

          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () => controller.setRating(index + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36,
                      color: index < controller.rating.value
                          ? Colors.amber
                          : Color(0xFFD1D5DB),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          Obx(
            () => Text(
              controller.rating.value == 0
                  ? "tap_star_hint"
                        .tr // Key for "Tap a star to rate"
                  : "you_rated_status".trArgs([
                      "${controller.rating.value}/5",
                    ]), // Localized arguments support
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(BuildContext context) {
    return _card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "review".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                " *",
                style: GoogleFonts.googleSans(color: Colors.red, fontSize: 24),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            controller: controller.reviewController,
            maxLines: 5,
            maxLength: 250,
            decoration: InputDecoration(
              hintText: "share_experience_hint".tr,
              hintStyle: GoogleFonts.googleSans(
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
              filled: true,
              fillColor: controller.themeCtrl.getDark()
                  ? Color(0xFF1a1a1a)
                  : Color(0xffF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: controller.themeCtrl.getDark()
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      )
                    : BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: controller.themeCtrl.getDark()
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      )
                    : BorderSide.none,
              ),
              counterText: "",
            ),
          ),
         
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => Text(
                "${controller.reviewLength.value}/250",
                style: GoogleFonts.googleSans(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(BuildContext context) {
    return _card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "add_photos".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: "  (optional)".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Obx(() {
            return Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                ...List.generate(controller.selectedImages.length, (index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          controller.selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                if (controller.selectedImages.length < 5)
                  Bounceable(
                    onTap: controller.pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall!.color,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "add_photo".tr,
                            style: GoogleFonts.googleSans(
                              color: Theme.of(
                                context,
                              ).textTheme.titleSmall!.color,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.selectedImages.length}/5",
                            style: GoogleFonts.googleSans(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CustomButton(title: "submit_review".tr, margin: EdgeInsets.all(0));
  }

  Widget _card({required Widget child, required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
