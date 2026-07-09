import 'package:dashboard/app/localization/app_translatation.dart';
import 'package:dashboard/app/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/controllers/theme_controller.dart'; // adjust path to where you put it
import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true); // <-- this line must run
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'CamExplore Dashboard',
        debugShowCheckedModeBanner: false,

        // --- Translation setup ---
        translations: AppTranslatation(),
        locale: LocalizationService().getLocale(),
        fallbackLocale: Locale('enUS'),

        // --- Theme setup ---
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),

        // initialRoute: Routes.LOGIN_SCREEN,
        initialRoute: Routes.ADMIN_SCREEN,
        getPages: AppPages.routes,
      );
    });
  }
}
