import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();

  late final RxBool isDarkMode;

  @override
  void onInit() {
    super.onInit();
    final bool saved = (_box.read('isDarkMode') as bool?) ?? true;
    isDarkMode = saved.obs;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write('isDarkMode', isDarkMode.value);

    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Get.changeThemeMode() alone only updates ThemeData/ThemeMode - it
    // doesn't rebuild widgets that read plain colors (like AdminColors)
    // instead of Theme.of(context). Get.updateLocale() (used for language)
    // calls this internally, which is why language switching already
    // reaches every screen. Doing the same here makes theme switching
    // behave the same way across the whole admin dashboard.
    Get.forceAppUpdate();
  }
}