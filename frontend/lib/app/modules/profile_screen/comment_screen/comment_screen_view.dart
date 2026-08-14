import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/api/services/profile_services.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'comment_screen_binding.dart';
part 'comment_screen_controller.dart';

class CommentScreenView extends GetView<CommentScreenViewController> {
  const CommentScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "feedback".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _mainCard(context),
              SizedBox(height: 20),
              _contact(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        color: controller.themeCtrl.getDark() ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "do_you_like_app".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "do_you_like_app_desc".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          /// ⭐ Rating
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => controller.setRating(index + 1),
                  icon: Icon(
                    index < controller.selectedRating.value
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orange,
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              "review_type".tr,
              style: GoogleFonts.googleSans(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 10,
              children: [
                _chip(text: "type1".tr),
                _chip(text: "type2".tr),
                _chip(text: "type3".tr),
                _chip(text: "type4".tr),
                _chip(text: "type5".tr),
              ],
            ),
          ),
          SizedBox(height: 20),
          _label("name".tr, context),
          _textField(controller.nameCtrl, context),

          const SizedBox(height: 20),

          _label("email".tr, context),
          _textField(controller.emailCtrl, context),

          const SizedBox(height: 20),

          _label("feedback".tr, context),
          _feedbackField(context),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "submit_review".tr,
                style: GoogleFonts.googleSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required String text}) {
    final isSelected = controller.selectedCategory.value == text;
    return GestureDetector(
      onTap: () => controller.setCategory(text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.googleSans(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _label(String text, BuildContext context) => Text(
    text,
    style: GoogleFonts.googleSans(
      fontSize: 16,
      fontWeight: .bold,
      color: Theme.of(context).colorScheme.secondary,
    ),
  );

  Widget _textField(TextEditingController controller, BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontWeight: .w500,
        color: Theme.of(context).colorScheme.secondary,
      ),
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.lightPrimaryColor, // focus color
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _feedbackField(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontWeight: .w500,
        color: Theme.of(context).colorScheme.secondary,
      ),
      controller: controller.commentCtrl,
      maxLines: 5,
      maxLength: 250,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.lightPrimaryColor, // focus color
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _contact(BuildContext context) {
    return Container(
      width: Get.width * 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        color: controller.themeCtrl.getDark() ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _label("contact_us".tr, context),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "email".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                TextSpan(
                  text: " : support@example.com",
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: AppColors.lightPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "phone".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                TextSpan(
                  text: " : +855 12 345 678",
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: AppColors.lightPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
