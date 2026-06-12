part of 'comment_screen_view.dart';

class CommentScreenViewController extends GetxController {
  final selectedRating = 0.obs;
  final selectedCategory = ''.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final feedbackController = TextEditingController();

  void setRating(int value) {
    selectedRating.value = value;
  }

  void setCategory(String value) {
    selectedCategory.value = value;
  }

  void submitFeedback() {
    if (selectedRating.value == 0) {
      return;
    }

    if (selectedCategory.value.isEmpty) {
      return;
    }

    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        feedbackController.text.isEmpty) {
      return;
    }

    Future.delayed(const Duration(seconds: 3), () {
      Get.back();
    });
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    feedbackController.dispose();
    super.onClose();
  }
}
