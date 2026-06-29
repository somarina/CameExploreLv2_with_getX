import 'package:flutter/material.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
          "Write a review",
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
            // _placeCard(),
            // SizedBox(height: 20),
            _buildOverallRate(context),
            SizedBox(height: 20),
            _reviewCard(context),
            SizedBox(height: 20),
            _photoCard(context),
            SizedBox(height: 30),
            _submitButton(),
            SizedBox(height: 16),
            Text(
              "Your review will be published publicly",
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
            "Overall rating",
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
                  ? "Tap a star to rate"
                  : "You rated ${controller.rating.value}/5",
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
                "Your review",
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
            maxLength: 6,
            decoration: InputDecoration(
              hintText: "Share your experience",
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
                "${controller.reviewLength.value}/6",
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
                  text: "Add photos",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: "  (optional)",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                ),
                SizedBox(height: 10),
                Text(
                  "Add photo",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CustomButton(title: "Submit Review", margin: EdgeInsets.all(0));
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
