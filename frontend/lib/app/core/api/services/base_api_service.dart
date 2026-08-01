import 'dart:io';

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

  // Future<dynamic> postFormData({
  //   required String endpoint,
  //   required FormData data,
  // }) async {
  //   try {
  //     var response = await apiConfig.dio.post(
  //       endpoint,
  //       data: data,
  //       options: Options(contentType: "multipart/form-data"),
  //     );
  //     return response.data;
  //   } on DioException catch (e) {
  //     debugPrint("Error ${e.toString()}");
  //   }
  // }

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
  Future<dynamic> postFormDataFiles({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      var response = await apiConfig.dio.post(
        endpoint,
        data: data,
        options: Options(contentType: "application/json"),
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint("Error ${e.toString()}");
    }
  }


Future<dynamic> postFormDataFiles2({
    required String endpoint,
    required Map<String, File> files,
  }) async {
    try {
      final Map<String, dynamic> formMap = {};

      // Convert File objects into Dio MultipartFile entries
      for (var entry in files.entries) {
        formMap[entry.key] = await MultipartFile.fromFile(
          entry.value.path,
          filename: entry.value.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      var response = await apiConfig.dio.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint("Error in postFormDataFiles: ${e.toString()}");
      return null;
    }
  }

}
