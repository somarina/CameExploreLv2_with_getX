part of 'comment_screen_view.dart';

class CommentScreenViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();

  final selectedRating = 0.obs;
  final selectedCategory = ''.obs;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  final isLoading = false.obs;

  void setRating(int value) => selectedRating.value = value;
  void setCategory(String value) => selectedCategory.value = value;

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> submitFeedback() async {
    try {
      isLoading.value = true;

      if (selectedRating.value == 0 ||
          selectedCategory.value.isEmpty ||
          nameCtrl.text.isEmpty ||
          emailCtrl.text.isEmpty ||
          commentCtrl.text.isEmpty) {
        isLoading.value = false;
        Get.snackbar("Error", "All fields are required");
        return;
      }

      if (!isValidEmail(emailCtrl.text)) {
        isLoading.value = false;
        Get.snackbar("Error", "Invalid email address");
        return;
      }

      final response = await ProfileServices().feedbackService(
        rating: selectedRating.value,
        review_type: selectedCategory.value,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        comment: commentCtrl.text.trim(),
      );

      if (response["id"] != null) {
        Get.back();
        Get.snackbar("Success", "Feedback sent successfully");
      } else {
        Get.snackbar("Error", "Failed to send feedback");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    commentCtrl.dispose();
    super.onClose();
  }
}
