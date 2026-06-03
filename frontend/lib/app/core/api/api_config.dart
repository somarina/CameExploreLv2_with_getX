import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiConfig {
  late Dio dio;

  String? token;

  void getToken() {
    var box = GetStorage();
    token = box.read("token");
  }

  ApiConfig() {
    getToken();
    dio = Dio(
      BaseOptions(
        // Android emulator → 10.0.2.2:8000
        // Real device → your PC IP e.g. 192.168.1.x:8000
        // Production → your Railway URL
        // baseUrl: "http://10.0.2.2:8000",
        
        // baseUrl: "http://10.0.2.2:8000",
        baseUrl: "https://staleness-antirust-shrapnel.ngrok-free.dev",
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    )..interceptors.add(PrettyDioLogger(requestBody: true));
  }
}
