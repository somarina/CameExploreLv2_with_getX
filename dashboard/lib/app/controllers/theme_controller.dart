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
  }
}