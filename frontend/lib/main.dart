import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/app/localization/app_translatation.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/core/api/services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Google Sign In
  await GoogleSignIn.instance.initialize(
    serverClientId:
        "1038064506820-tfiojqrdrabj7sv9qqfvacdeb636ot1o.apps.googleusercontent.com", // ← replace this
  );

  await GetStorage.init();

  // ── Telegram deep link handler ──────────────────────────────────────────
  final appLinks = AppLinks();

  // When app is already open and Telegram returns
  appLinks.uriLinkStream.listen((uri) {
    if (uri.scheme == 'camexplore' && uri.host == 'telegram-login') {
      _handleTelegramCallback(uri.queryParameters);
    }
  });

  // When app was closed and Telegram opens it
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null &&
      initialUri.scheme == 'camexplore' &&
      initialUri.host == 'telegram-login') {
    _handleTelegramCallback(initialUri.queryParameters);
  }

  runApp(const MainApp());
}

// ── Handle Telegram callback data ───────────────────────────────────────────
void _handleTelegramCallback(Map<String, String> params) async {
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

    if (response["result"] == true) {
      box.write('token', response["data"]["token"] ?? '');
      box.write('userId', response["data"]["id"] ?? '');
      box.write('userName', response["data"]["name"] ?? '');
      box.write('userEmail', response["data"]["email"] ?? '');
      box.write('userAvatar', response["data"]["avatar"] ?? '');
      box.write('isLogin', true);
      box.write('userMode', 'user');
      Get.offAllNamed('/button-navigation');
    } else {
      Get.snackbar(
        'Telegram Login Failed',
        response["message"] ?? 'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
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
    return GetMaterialApp(
      // language
      translations: AppTranslatation(),
      locale: Locale("kmKH"), // enUS
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.LOGIN_SCREEN,
      getPages: AppPages.routes,
    );
  }
}
