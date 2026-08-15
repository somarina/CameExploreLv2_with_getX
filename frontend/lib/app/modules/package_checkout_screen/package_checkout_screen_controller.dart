part of 'package_checkout_screen_view.dart';

class PackageCheckoutScreenViewController extends GetxController {
  // Existing controllers & variables ...
  var themeCtrl = Get.find<ThemeModeViewController>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final cardHolderCtrl = TextEditingController();
  final cardNumberCtrl = TextEditingController();
  final cardExpiryCtrl = TextEditingController();
  final cardCvvCtrl = TextEditingController();
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

  // --- NEW: Timer & Invoice Upload State ---
  RxInt remainingSeconds = 180.obs; // 3 minutes = 180 seconds
  Timer? _timer;
  Rx<XFile?> uploadedInvoice = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  void startPaymentTimer() {
    remainingSeconds.value = 180;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void stopPaymentTimer() {
    _timer?.cancel();
  }

  String get formattedTimer {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> pickInvoiceImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      uploadedInvoice.value = image;
      Get.snackbar(
        "Success",
        "Invoice uploaded successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
  // ----------------------------------------

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

  bool validateCard() {
    if (cardHolderCtrl.text.trim().isEmpty ||
        cardNumberCtrl.text.replaceAll(' ', '').length < 12 ||
        cardExpiryCtrl.text.trim().isEmpty ||
        cardCvvCtrl.text.trim().length < 3) {
      Get.snackbar(
        "Error",
        "Please enter valid card details.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  Future<bool> createBooking({
    String? paymentMethod,
    String? paymentStatus,
  }) async {
    final method = paymentMethod ?? selectedPayment.value;
    final status = paymentStatus ?? (method == "VISA" ? "paid" : "pending");

    if (method == "KHQR" && uploadedInvoice.value == null) {
      Get.snackbar(
        "Invoice Required",
        "Please upload your payment invoice before finishing.",
        // backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isBookingLoading.value = true;
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
        paymentMethod: method,
        paymentStatus: status,
      );

      if (response == null) return false;

      final bookingId =
          response['data']?['_id'] ??
          response['data']?['id'] ??
          response['booking_id'] ??
          response['id'];

      // Actually send the picked receipt image to the server so a human
      // (package owner/admin) can review it. Without this call the image
      // only ever lived on-device and payment_status could never move
      // past "pending".
      if (method == "KHQR" &&
          uploadedInvoice.value != null &&
          bookingId != null) {
        try {
          await _bookingService.uploadPaymentProof(
            bookingId: bookingId.toString(),
            imagePath: uploadedInvoice.value!.path,
          );
        } catch (e) {
          Get.snackbar(
            "Receipt Upload Failed",
            "Booking saved, but the receipt didn't upload. Please re-upload it from My Bookings.",
            colorText: Colors.white,
          );
        }
      }

      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    } finally {
      isBookingLoading.value = false;
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
    if (emailCtrl.text.trim().isEmpty ||
        !GetUtils.isEmail(emailCtrl.text.trim())) {
      Get.snackbar(
        "Error",
        "Please enter a valid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (phoneCtrl.text.trim().isEmpty ||
        !RegExp(r'^(0|855)?[1-9][0-9]{7,8}$').hasMatch(phoneCtrl.text.trim())) {
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
    noteCtrl.addListener(() {
      noteLength.value = noteCtrl.text.length;
    });

    if (Get.arguments != null) {
      bookingData = Map<String, dynamic>.from(Get.arguments);
      price = (bookingData["price"] ?? 0).toDouble();
      adultCount = bookingData["adultCount"] ?? 1;
      total = price * adultCount;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    noteCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    cardHolderCtrl.dispose();
    cardNumberCtrl.dispose();
    cardExpiryCtrl.dispose();
    cardCvvCtrl.dispose();
    super.onClose();
  }
}
