import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../routes/app_pages.dart';

// const String kBaseUrl = 'http://127.0.0.1:8000/';
// const String kBaseUrl = 'https://camexplore-api.onrender.com/';
const String kBaseUrl = 'https://cam-explore-v2-backend-v2.vercel.app/';

const String kTelegramBotId = '8720092780';

class ApiConfig {
  late Dio dio;

  String? token;

  void getToken() {
    var box = GetStorage();
    token = box.read("token");
  }

  ApiConfig() {
    getToken();
    dio =
        Dio(
            BaseOptions(
              baseUrl: kBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                "Content-Type": "application/json",
                "ngrok-skip-browser-warning": "true",
              },
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                final token = GetStorage().read<String>('token');
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
              onError: (error, handler) {
                if (error.response?.statusCode == 401) {
                  final box = GetStorage();
                  final isGuest = box.read('userMode') == 'guest';
                  final hadToken = (box.read<String>('token') ?? '').isNotEmpty;

                  // Guests never had a session to expire — a 401 here just
                  // means they hit a login-only endpoint. Don't wipe their
                  // guest state or bounce them to Login.
                  if (!isGuest && hadToken) {
                    box.erase();
                    if (Get.currentRoute != Routes.LOGIN_SCREEN) {
                      Get.offAllNamed(Routes.LOGIN_SCREEN);
                      Get.snackbar(
                        "Session expired",
                        "Please log in again.",
                      );
                    }
                  }
                }
                return handler.next(error);
              },
            ),
          )
          ..interceptors.add(PrettyDioLogger(requestBody: true));
  }
}