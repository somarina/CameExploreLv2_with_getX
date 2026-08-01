import 'dart:io';
import 'package:frontend/app/core/api/services/base_api_service.dart';

class HotelReviewServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchReviews(String hotelId) async {
    return await baseApi.get(
      endpoint: "api/reviews/hotel/$hotelId",
    );
  }

  /// Uploads up to 5 photos to Cloudinary for hotels
  Future<List<String>> uploadImages({
    required List<File> files,
    required String hotelId,
  }) async {
    if (files.isEmpty) return [];

    // Explicitly pass target_type as 'hotel'
    final endpoint = "api/reviews/upload-images/hotel/$hotelId";

    final Map<String, File> fileMap = {};
    for (int i = 0; i < files.length; i++) {
      fileMap['file${i + 1}'] = files[i];
    }

    final response = await baseApi.postFormDataFiles2(
      endpoint: endpoint,
      files: fileMap,
    );

    if (response != null && response['data'] != null && response['data']['images'] != null) {
      return List<String>.from(response['data']['images']);
    }

    return [];
  }

  /// Creates hotel review with JSON payload matching Swagger schema
  Future<dynamic> createReview({
    required Map<String, dynamic> data,
    required String hotelId,
  }) async {
    return await baseApi.post(
      endpoint: "api/reviews/hotel/$hotelId",
      data: data,
    );
  }
}