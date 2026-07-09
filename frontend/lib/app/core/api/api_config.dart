import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String kBaseUrl = 'http://10.0.2.2:8000';

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
              // headers: {"Content-Type": "application/json"},
              headers: {
                "Content-Type": "application/json",
                "ngrok-skip-browser-warning": "true", // ← add this
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
            ),
          )
          ..interceptors.add(PrettyDioLogger(requestBody: true));
  }
}
