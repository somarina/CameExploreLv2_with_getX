part of 'package_detail_screen_view.dart';

class PackageDetailScreenViewController extends GetxController {
  final currentIndex = 0.obs;
  final isImportantExpanded = false.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  final adultCount = 1.obs;

  final showAvailability = false.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void increaseAdult() {
    adultCount.value++;
  }

  void decreaseAdult() {
    if (adultCount.value > 1) {
      adultCount.value--;
    }
  }

  void checkAvailability() {
    if (selectedDate.value == null) {
      Get.snackbar(
        "select_date_err_title_".tr, 
        "select_date_err_body_".tr,   
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    showAvailability.value = true;
  }

  String get formattedDate {
    if (selectedDate.value == null) {
      return "select_date_package_".tr;
    }

    return DateFormat(
      'dd MMMM yyyy',
    ).format(selectedDate.value!);
  }

  String get formattedTime {
    if (selectedTime.value == null) {
      return "starting_time_".tr;
    }

    return selectedTime.value!.format(Get.context!);
  }
}