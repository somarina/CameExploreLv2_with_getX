part of 'package_checkout_screen_view.dart';

class PackageCheckoutScreenViewController extends GetxController {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  double price = 0;
  int adultCount = 1;
  double total = 0;

  var selectedPayment = "KHQR".obs;
  Map<String, dynamic> bookingData = {};
  bool validateGuestInfo() {
    if (firstNameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter first name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter last name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (emailCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      Get.snackbar(
        "Error",
        "Please enter a valid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter mobile number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Cambodia phone number validation
    if (!RegExp(r'^(0|855)?[1-9][0-9]{7,8}$').hasMatch(phoneCtrl.text.trim())) {
      Get.snackbar(
        "Error",
        "Please enter a valid mobile number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      bookingData = Map<String, dynamic>.from(Get.arguments);

      price = (bookingData["price"] ?? 0).toDouble();
      adultCount = bookingData["adultCount"] ?? 1;

      total = price * adultCount;
    }
  }
}
