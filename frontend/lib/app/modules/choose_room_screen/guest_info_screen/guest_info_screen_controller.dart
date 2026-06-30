part of 'guest_info_screen_view.dart';

class GuestInfoScreenViewController extends GetxController {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var selectedPayment = "KHQR".obs;
  DateTime? checkIn;
  DateTime? checkOut;
RxString transactionDate = ''.obs;

  String get checkInText =>
      checkIn != null ? DateFormat('EEE, MMM dd').format(checkIn!) : '';

  String get checkOutText =>
      checkOut != null ? DateFormat('EEE, MMM dd').format(checkOut!) : '';

  int get nights => checkIn != null && checkOut != null
      ? checkOut!.difference(checkIn!).inDays
      : 0;



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

    final args = Get.arguments;

    checkIn = args['checkIn'];
    checkOut = args['checkOut'];
  }
}
