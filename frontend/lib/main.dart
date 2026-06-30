import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:frontend/app/localization/app_translatation.dart';
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

  // Deep link setup — safe here since runApp already ran
  _setupDeepLinks();
}
 
void _setupDeepLinks() {
  final appLinks = AppLinks();

  appLinks.uriLinkStream.listen((uri) {
    if (uri.scheme == 'camexplore' && uri.host == 'telegram-login') {
      _handleTelegramCallback(uri.queryParameters);
    }
  });

  appLinks.getInitialLink().then((initialUri) async {
    if (initialUri != null &&
        initialUri.scheme == 'camexplore' &&
        initialUri.host == 'telegram-login') {
      await Future.delayed( Duration(seconds: 1));
      _handleTelegramCallback(initialUri.queryParameters);
    }
  });
}

void _handleTelegramCallback(Map<String, String> params) async {
  debugPrint('TELEGRAM CALLBACK PARAMS: $params');

  if (params['hash'] == null || params['id'] == null) {
    debugPrint('Missing required Telegram params');
    return;
  }

  final authServices = AuthServices();
  final box = GetStorage();

  try {
    var response = await authServices.telegramLoginService(
      telegramData: {
        'id': int.tryParse(params['id'] ?? '0') ?? 0,
        'first_name': params['first_name'] ?? '',
        'last_name': params['last_name'] ?? '',
        'username': params['username'] ?? '',
        'photo_url': params['photo_url'] ?? '',
        'auth_date': int.tryParse(params['auth_date'] ?? '0') ?? 0,
        'hash': params['hash'] ?? '',
      },
    );

    if (response != null && response["result"] == true) {
      box.write('token', response["data"]["token"] ?? '');
      box.write('userId', response["data"]["id"] ?? '');
      box.write('userName', response["data"]["name"] ?? '');
      box.write('userEmail', response["data"]["email"] ?? '');
      box.write('userAvatar', response["data"]["avatar"] ?? '');
      box.write('userRole', response["data"]["role"] ?? 'user');
      box.write('isLogin', true);
      box.write('userMode', 'user');

      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/button-navigation');
    } else {
      Get.snackbar(
        'Telegram Login Failed',
        response?["message"] ?? 'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    debugPrint('TELEGRAM LOGIN ERROR: $e');
    Get.snackbar(
      'Telegram Login Failed',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var box = GetStorage();
    var isdark = box.read("isdark") ?? false;

    return GetMaterialApp(
      // theme
      theme: AppColors.lightMode(),
      darkTheme: AppColors.darkMode(),
      themeMode: isdark ? ThemeMode.dark : ThemeMode.light,
      

      // language
      translations: AppTranslatation(),
      locale: Locale("kmKH"),
      fallbackLocale: Locale("enUS"),
      debugShowCheckedModeBanner: false,

      // routes
      initialRoute: Routes.SPLASH_SCREEN,
      // initialRoute: Routes.HOME_SCREEN,
      // initialRoute: Routes.USERPROFILE_SCREEN,
      getPages: AppPages.routes,
    );
  }
}
