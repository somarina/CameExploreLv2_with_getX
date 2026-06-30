import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/profile_services.dart';
import 'package:frontend/app/modules/auth/login_screen/controllers/login_screen_controller.dart';
import 'package:frontend/app/modules/profile_screen/userProfile_screen/user_profile_screen_view.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  var userProfileController = Get.find<UserProfileScreenViewController>();
  var loginController = Get.find<LoginScreenController>();
  var newpassCtrl = TextEditingController();
  var currentpassCtrl = TextEditingController();
  var cfpassCtrl = TextEditingController();
  var isLoading = false.obs;

  var isCurrentHidden = true.obs;
  var isNewHidden = true.obs;
  var isConfirmHidden = true.obs;
  
  Future<void> changePassword() async {
    try {
      isLoading.value = true;

      if (currentpassCtrl.text.isEmpty ||
          newpassCtrl.text.isEmpty ||
          cfpassCtrl.text.isEmpty) {
        Get.snackbar("Error", "All fields are required");
        return;
      }

      if (newpassCtrl.text != cfpassCtrl.text) {
        Get.snackbar("Error", "Password confirmation does not match");
        return;
      }

      var response = await ProfileServices().changePasswordService(
        current_password: currentpassCtrl.text,
        new_password: newpassCtrl.text,
        confirm_password: cfpassCtrl.text,
      );
      if (response["result"] == true) {
        await userProfileController.getProfile();

        Get.back();

        Get.snackbar("Success", "Password changed successfully");
      } else {
        Get.snackbar(
          "Error",
          response["messaeg"] ?? "Current password is incorrect",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
  @override
  void onClose() {
    currentpassCtrl.dispose();
    newpassCtrl.dispose();
    cfpassCtrl.dispose();
    super.onClose();
  }
}
  // final formKey = GlobalKey<FormState>();

  // var currentPWD = TextEditingController();
  // var newPWD = TextEditingController();
  // var confirmPWD = TextEditingController();

  // final hideCurrent = true.obs;
  // final hideNew = true.obs;
  // final hideConfirm = true.obs;

  // final isLoading = false.obs;

  // void toggleCurrent() => hideCurrent.value = !hideCurrent.value;
  // void toggleNew() => hideNew.value = !hideNew.value;
  // void toggleConfirm() => hideConfirm.value = !hideConfirm.value;

  // Future<void> savePassword() async {
  //   if (!formKey.currentState!.validate()) return;

  //   if (currentPWD.text.trim() == newPWD.text.trim()) {
  //     Get.snackbar(
  //       "បរាជ័យ",
  //       "ពាក្យសម្ងាត់ថ្មីមិនអាចដូចពាក្យសម្ងាត់ចាស់",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return;
  //   }

  //   if (newPWD.text.trim() != confirmPWD.text.trim()) {
  //     Get.snackbar(
  //       "បរាជ័យ",
  //       "ពាក្យសម្ងាត់មិនដូចគ្នា",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return;
  //   }

  //   // 🔸 Fake loading (no API)
  //   isLoading.value = true;
  //   await Future.delayed(const Duration(seconds: 2));
  //   isLoading.value = false;

  //   showSuccessDialog();
  // }

  // void showSuccessDialog() {
  //   Get.defaultDialog(
  //     title: "ជោគជ័យ",
  //     middleText: "ប្តូរពាក្យសម្ងាត់បានជោគជ័យ (Local)",
  //     textConfirm: "យល់ព្រម",
  //     confirmTextColor: Colors.white,
  //     onConfirm: () {
  //       Get.back(); // close dialog
  //       Get.back(); // back screen
  //     },
  //   );
  // }

  // @override
  // void onClose() {
  //   currentPWD.dispose();
  //   newPWD.dispose();
  //   confirmPWD.dispose();
  //   super.onClose();
  

