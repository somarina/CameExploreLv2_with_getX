// ignore_for_file: use_null_aware_elements

import 'dart:io';

import 'package:dio/dio.dart';

import 'base_api_service.dart';

class AiServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> chat({
    required String message,
    List<Map<String, String>>? history,
    double? latitude,
    double? longitude,
  }) async {
    return await baseApi.post(
      endpoint: "/api/ai/chat",
      data: {
        "message": message,
        if (history != null) "history": history,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      },
    );
  }

  Future<dynamic> identifyImage({
    required File image,
    String? message,
    double? latitude,
    double? longitude,
  }) async {
    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
      if (message != null && message.isNotEmpty) "message": message,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
    });

    // Image analysis can take longer than the default 10s timeout, so this
    // request gets its own extended window instead of going through the
    // shared postFormData helper.
    try {
      final response = await baseApi.apiConfig.dio.post(
        "/api/ai/identify-image",
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      return response.data;
    } on DioException catch (e) {
      // Mirrors BaseApiService's error handling (returns null on failure).
      // ignore: avoid_print
      print("Error identifying image: $e");
      return null;
    }
  }
}