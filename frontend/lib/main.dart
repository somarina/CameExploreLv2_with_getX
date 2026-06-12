import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/localization/app_translatation.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/core/api/services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignIn.instance.initialize(
    serverClientId:
        "1038064506820-tfiojqrdrabj7sv9qqfvacdeb636ot1o.apps.googleusercontent.com",
  );

  await GetStorage.init();

  runApp(const MainApp());

  // MOVED AFTER runApp — GetX is now ready
  final appLinks = AppLinks();

  // When app is already open
  appLinks.uriLinkStream.listen((uri) {
    if (uri.scheme == 'camexplore' && uri.host == 'telegram-login') {
      _handleTelegramCallback(uri.queryParameters);
    }
  });

  // When app was closed and reopened by deep link
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null &&
      initialUri.scheme == 'camexplore' &&
      initialUri.host == 'telegram-login') {
    // Delay to let app fully initialize first
    await Future.delayed(const Duration(seconds: 1));
    _handleTelegramCallback(initialUri.queryParameters);
  }
}

void _handleTelegramCallback(Map<String, String> params) async {
  debugPrint('TELEGRAM CALLBACK PARAMS: $params');

  // Guard: make sure params are not empty
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

      //  Small delay to ensure navigator is ready
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
    var isdark = box.read("isdark")?? false;
    
    return GetMaterialApp(
      
      // theme
      theme: AppColors.lightMode(),
      darkTheme: AppColors.darkMode(),
      themeMode: isdark? ThemeMode.dark : ThemeMode.light, // ☀️🌙 Auto
      
      // language
      translations: AppTranslatation(),
      locale: Locale("kmKH"),
      fallbackLocale:  Locale("enUS"),
      debugShowCheckedModeBanner: false,
      
      // Call Screen
      initialRoute: Routes.SPLASH_SCREEN,
      getPages: AppPages.routes,
    );
  }
}