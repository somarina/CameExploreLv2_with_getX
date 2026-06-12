import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'comment_screen_binding.dart';
part 'comment_screen_controller.dart';

class CommentScreenView extends GetView<CommentScreenViewController> {
  const CommentScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.theme.scaffoldBackgroundColor,

        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "Feedback",
          style: GoogleFonts.kantumruyPro(
            color: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [_mainCard(), SizedBox(height: 20), _contact()],
          ),
        ),
      ),
    );
  }

  Widget _mainCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? null : Get.theme.scaffoldBackgroundColor,
        border: Get.isDarkMode
            ? Border.all(color: Get.theme.colorScheme.primary)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "Do you like our Application?",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Your feedback helps us improve the app.",
                  style: GoogleFonts.spaceGrotesk(
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
              "Rate",
              style: GoogleFonts.spaceGrotesk(
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
                _chip(text: "Function"),
                _chip(text: "Design"),
                _chip(text: "Speed"),
                _chip(text: "Usage"),
                _chip(text: "Other"),
              ],
            ),
          ),
          SizedBox(height: 20),
          _label("Name"),
          _textField(controller.fullNameController),

          const SizedBox(height: 20),

          _label("Email"),
          _textField(controller.emailController),

          const SizedBox(height: 20),

          _label("Feedback"),
          _feedbackField(),

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
                "Comments",
                style: GoogleFonts.spaceGrotesk(
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
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: .bold),
  );

  Widget _textField(TextEditingController controller) {
    return TextFormField(
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

  Widget _feedbackField() {
    return TextFormField(
      controller: controller.feedbackController,
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

  Widget _contact() {
    return Container(
      width: Get.width * 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? null : Get.theme.scaffoldBackgroundColor,
        border: Get.isDarkMode
            ? Border.all(color: Get.theme.colorScheme.primary)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _label("Contact us"),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Email : ",
                  style: GoogleFonts.spaceGrotesk(fontSize: 16),
                ),
                TextSpan(
                  text: "support@example.com",
                  style: GoogleFonts.spaceGrotesk(
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
                  text: "Phone : ",
                  style: GoogleFonts.spaceGrotesk(fontSize: 16),
                ),
                TextSpan(
                  text: "+855 12 345 678",
                  style: GoogleFonts.spaceGrotesk(
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
