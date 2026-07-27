import 'package:dashboard/app/localization/app_translatation.dart';
import 'package:dashboard/app/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/controllers/theme_controller.dart'; // adjust path to where you put it
import 'app/modules/admin_screen/views/widgets/boot_shimmer_screen.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootShimmerScreen());

  await GetStorage.init();
  Get.put(ThemeController(), permanent: true); // <-- this line must run

  await Future.delayed(const Duration(milliseconds: 500));

  runApp(DashboardApp(
    startRoute: _resolveStartRoute(),
  ));
}

String _resolveStartRoute() {
  final token = GetStorage().read<String>('dashboard_token');
  return (token != null && token.isNotEmpty)
      ? Routes.ADMIN_SCREEN
      : Routes.LOGIN_SCREEN;
}

class DashboardApp extends StatelessWidget {
  final String startRoute;
  const DashboardApp({super.key, required this.startRoute});

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

        initialRoute: startRoute,
        getPages: AppPages.routes,
      );
    });
  }
}
