import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/base_api_service.dart';

enum ReviewType { place, package, hotel }

class PlaceReviewService {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchReviews(
    String id, {
    ReviewType type = ReviewType.place,
  }) async {
    final endpoint = "api/reviews/${type.name}/$id";
    return await baseApi.get(endpoint: endpoint);
  }

  /// Uploads images using individual form keys ('file1', 'file2', ...)
  Future<List<String>> uploadImages({
    required List<File> files,
    required String targetId,
    required ReviewType type,
  }) async {
    if (files.isEmpty) return [];

    final endpoint = "api/reviews/upload-images/${type.name}/$targetId";

    // 1. Map files to file1, file2, file3...
    final Map<String, File> fileMap = {};
    for (int i = 0; i < files.length; i++) {
      fileMap['file${i + 1}'] = files[i];
    }

    // 2. Post multipart form data
    final response = await baseApi.postFormDataFiles2(
      endpoint: endpoint,
      files: fileMap,
    );

    debugPrint("Upload Images API Response: $response");

    if (response != null) {
      // Check if URLs are under response["data"]["images"]
      if (response['data'] != null && response['data']['images'] is List) {
        return List<String>.from(response['data']['images']);
      }

      // Fallback: Check if URLs are under response["images"] directly
      if (response['images'] is List) {
        return List<String>.from(response['images']);
      }

      // Fallback: Check if URLs are under response["urls"] directly
      if (response['urls'] is List) {
        return List<String>.from(response['urls']);
      }
    }

    return [];
  }

  Future<dynamic> createReview({
    required Map<String, dynamic> data,
    required String id,
    ReviewType type = ReviewType.place,
  }) async {
    final endpoint = "api/reviews/${type.name}/$id";

    // JSON post request
    return await baseApi.post(endpoint: endpoint, data: data);
  }
}
