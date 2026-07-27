import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

import '../api_config.dart';

class BaseApiService {
  final ApiConfig apiConfig = ApiConfig();

  // Backend always responds with {"result": bool, "message": str, "data": {}},
  // even on errors (see the exception handlers in main.py), so on a
  // DioException we return that same body instead of swallowing it —
  // callers can read response['message'] either way.
  dynamic _errorBody(DioException e) {
    if (e.response?.data != null) return e.response!.data;
    return {
      "result": false,
      "message": e.message ?? "Could not reach the server",
      "data": {},
    };
  }

  Future<dynamic> post({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      var response = await apiConfig.dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
      return _errorBody(e);
    }
  }

  Future<dynamic> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      var response = await apiConfig.dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
      return _errorBody(e);
    }
  }

  Future<dynamic> delete({required String endpoint}) async {
    try {
      var response = await apiConfig.dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
      return _errorBody(e);
    }
  }

  Future<dynamic> put({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      var response = await apiConfig.dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
      return _errorBody(e);
    }
  }
}
