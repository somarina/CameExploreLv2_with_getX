part of 'package_checkout_screen_view.dart';

class PackageCheckoutScreenViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final noteLength = 0.obs;
  double price = 0;
  int adultCount = 1;
  double total = 0;

  var selectedPayment = "KHQR".obs;
  Map<String, dynamic> bookingData = {};

  final PackageBookingServices _bookingService = PackageBookingServices();
  var isLoadingUser = true.obs;
  var isBookingLoading = false.obs;

  
  final userPfCtrl = Get.find<UserProfileScreenViewController>();
  Future<void> loadUserInfo() async {
    try {
      isLoadingUser.value = true;
      await userPfCtrl.getProfile();

      final user = userPfCtrl.user;
      final names = user.name.trim().split(' ');

      firstNameCtrl.text = names.isNotEmpty ? names.first : '';
      lastNameCtrl.text = names.length > 1 ? names.sublist(1).join(' ') : '';
      emailCtrl.text = user.email;
      phoneCtrl.text = user.phone;
    } finally {
      isLoadingUser.value = false;
    }
  }

  Future<bool> createBooking() async {
    try {
      final DateTime? date = bookingData["date"] as DateTime?;
      if (date == null) {
        Get.snackbar("Error", "Please select a valid date.");
        return false;
      }

      final response = await _bookingService.bookPackage(
        packageId: bookingData["id"]?.toString() ?? "",
        startDate: date,
        numberOfPeople: adultCount,
        guestNote: noteCtrl.text.trim(),
      );

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    }
  }

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
    loadUserInfo();
    if (Get.arguments != null) {
      bookingData = Map<String, dynamic>.from(Get.arguments);

      price = (bookingData["price"] ?? 0).toDouble();
      adultCount = bookingData["adultCount"] ?? 1;

      total = price * adultCount;
    }
  }
}
