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

  String get checkInText => checkIn != null ? DateFormat('EEE, MMM dd').format(checkIn!) : '';
  String get checkOutText => checkOut != null ? DateFormat('EEE, MMM dd').format(checkOut!) : '';

  int get nights => checkIn != null && checkOut != null ? checkOut!.difference(checkIn!).inDays : 0;

  bool validateGuestInfo() {
    if (firstNameCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_first_name".tr);
      return false;
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_last_name".tr);
      return false;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_email".tr);
      return false;
    }

    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      _showErrorSnackBar("err_valid_email".tr);
      return false;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_phone".tr);
      return false;
    }

    // Cambodia phone number regex validation
    if (!RegExp(r'^(0|855)?[1-9][0-9]{7,8}$').hasMatch(phoneCtrl.text.trim())) {
      _showErrorSnackBar("err_valid_phone".tr);
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "error".tr,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      checkIn = args['checkIn'];
      checkOut = args['checkOut'];
    }
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}