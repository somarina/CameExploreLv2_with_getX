import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

import '../api_config.dart';

class BaseApiService {
  final ApiConfig apiConfig = ApiConfig();

  Future<dynamic> post({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      var response = await apiConfig.dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
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
    }
  }

  Future<dynamic> delete({required String endpoint}) async {
    try {
      var response = await apiConfig.dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
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
    }
  }

  Future<dynamic> postFormData({
    required String endpoint,
    required FormData data,
  }) async {
    try {
      var response = await apiConfig.dio.post(
        endpoint,
        data: data,
        options: Options(contentType: "multipart/form-data"),
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
    }
  }



  
}
