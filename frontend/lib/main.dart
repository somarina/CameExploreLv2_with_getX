import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/localization/app_translatation.dart';
import 'package:frontend/app/modules/auth/login_screen/controllers/login_screen_controller.dart';
import 'package:frontend/app/modules/booking_screen/controllers/booking_screen_controller.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_controller.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
 
import 'app/core/constants/app_colors/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // GetStorage is fast — keep it before runApp
  await GetStorage.init();

  // Show UI immediately — don't block on Firebase or GoogleSignIn
  runApp(const MainApp());

  // Heavy init AFTER first frame is visible
  _initServicesInBackground();

  Get.put(ThemeModeViewController());
  Get.put(LoginScreenController());
  Get.lazyPut(() => HomeScreenController());
  Get.lazyPut(() => FavoriteScreenController());
  Get.lazyPut(() => SearchScreenController());
  Get.lazyPut(() => BookingScreenController());
}

Future<void> _initServicesInBackground() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GoogleSignIn.instance.initialize(
      serverClientId:
          "1038064506820-tfiojqrdrabj7sv9qqfvacdeb636ot1o.apps.googleusercontent.com",
    );
  } catch (e) {
    debugPrint('Background init error: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var box = GetStorage();
    var isdark = box.read("isdark") ?? false;
    var language = box.read("language") ?? "enUS";

    return GetMaterialApp(
      // theme
      theme: AppColors.lightMode(),
      darkTheme: AppColors.darkMode(),
      themeMode: isdark ? ThemeMode.dark : ThemeMode.light,

      // language
      translations: AppTranslatation(),
      // locale: Locale("kmKH"),
      fallbackLocale: Locale("enUS"),
      debugShowCheckedModeBanner: false,
      locale: language == "kmKH" ? Locale("kmKH") : Locale("enUS"),

      // routes
      // initialRoute: Routes.SPLASH_SCREEN,
      initialRoute: Routes.SPLASH_SCREEN,
      // initialRoute: Routes.LOGIN_SCREEN,
      getPages: AppPages.routes,
    );
  }
}