part of 'edit_screen_view.dart';

class EditScreenViewController extends GetxController {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final forgetPWDCtrl = TextEditingController();

  // gender condition
  final selectedGender = ''.obs;

  // -------- VALIDATION --------
  bool validateForm() {
    if (firstNameCtrl.text.isEmpty) {
      Get.snackbar("Error", "First name is required");
      return false;
    }

    if (lastNameCtrl.text.isEmpty) {
      Get.snackbar("Error", "Last name is required");
      return false;
    }

    if (!GetUtils.isEmail(emailCtrl.text)) {
      Get.snackbar("Error", "Invalid email");
      return false;
    }

    if (forgetPWDCtrl.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return false;
    }

    if (selectedGender.isEmpty) {
      Get.snackbar("Error", "Please select gender");
      return false;
    }

    return true;
  }

  void saveProfile() {
    if (!validateForm()) return;

    // API / Firebase / Local save
    Get.snackbar("Success", "Profile updated successfully");
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    forgetPWDCtrl.dispose();
    super.onClose();
  }
}