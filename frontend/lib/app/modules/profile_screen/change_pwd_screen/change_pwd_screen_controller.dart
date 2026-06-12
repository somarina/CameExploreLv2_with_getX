import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  var currentPWD = TextEditingController();
  var newPWD = TextEditingController();
  var confirmPWD = TextEditingController();

  final hideCurrent = true.obs;
  final hideNew = true.obs;
  final hideConfirm = true.obs;

  final isLoading = false.obs;

  void toggleCurrent() => hideCurrent.value = !hideCurrent.value;
  void toggleNew() => hideNew.value = !hideNew.value;
  void toggleConfirm() => hideConfirm.value = !hideConfirm.value;

  Future<void> savePassword() async {
    if (!formKey.currentState!.validate()) return;

    if (currentPWD.text.trim() == newPWD.text.trim()) {
      Get.snackbar(
        "បរាជ័យ",
        "ពាក្យសម្ងាត់ថ្មីមិនអាចដូចពាក្យសម្ងាត់ចាស់",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPWD.text.trim() != confirmPWD.text.trim()) {
      Get.snackbar(
        "បរាជ័យ",
        "ពាក្យសម្ងាត់មិនដូចគ្នា",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 🔸 Fake loading (no API)
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;

    showSuccessDialog();
  }

  void showSuccessDialog() {
    Get.defaultDialog(
      title: "ជោគជ័យ",
      middleText: "ប្តូរពាក្យសម្ងាត់បានជោគជ័យ (Local)",
      textConfirm: "យល់ព្រម",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // close dialog
        Get.back(); // back screen
      },
    );
  }

  @override
  void onClose() {
    currentPWD.dispose();
    newPWD.dispose();
    confirmPWD.dispose();
    super.onClose();
  }
}