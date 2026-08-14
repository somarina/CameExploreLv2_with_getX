import 'package:dashboard/app/localization/app_translatation.dart';
import 'package:dashboard/app/localization/localization_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/controllers/theme_controller.dart'; // adjust path to where you put it
import 'app/modules/admin_screen/views/widgets/boot_shimmer_screen.dart';
import 'app/routes/app_pages.dart';
import 'app/core/web/maps_script_loader.dart';

const String _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

// Applied app-wide via GetMaterialApp.scrollBehavior below. Removes the
// visible scrollbar thumb/track from every scrollable in the app (sidebar,
// tables, lists, dialogs, etc.) without changing scroll behavior itself —
// mouse wheel, trackpad, touch drag, and keyboard scrolling all still work
// exactly as before.
class _NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  // Keep mouse-drag-to-scroll working on web/desktop (default Flutter
  // behavior only allows touch/stylus to initiate drag scrolling).
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootShimmerScreen());

  // Wait for the Google Maps JS script to finish loading (web only; no-op
  // elsewhere) before mounting the real app, so any screen with a
  // GoogleMap never builds before `google.maps` actually exists.
  final mapsReady = injectGoogleMapsScript(_googleMapsApiKey);

  await GetStorage.init();
  Get.put(ThemeController(), permanent: true); // <-- this line must run

  await mapsReady;

  runApp(DashboardApp(
    startRoute: _resolveStartRoute(),
  ));
}

String _resolveStartRoute() {
  final token = GetStorage().read<String>('dashboard_token');
  if (token == null || token.isEmpty) {
    return Routes.LOGIN_SCREEN;
  }

  final activeRole = GetStorage().read<String>('dashboard_active_role') ?? '';
  return activeRole.toLowerCase() == 'company'
      ? Routes.COMPANY_SCREEN
      : Routes.ADMIN_SCREEN;
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
        scrollBehavior: _NoScrollbarBehavior(),

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
        // initialRoute: Routes.COMPANY_SCREEN,
        getPages: AppPages.routes,
      );
    });
  }
}