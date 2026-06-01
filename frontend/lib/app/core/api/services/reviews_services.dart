import 'package:frontend/app/core/api/services/base_api_service.dart';

class ReviewsServices {
  final BaseApiService baseApi = BaseApiService();

  // ── Get Reviews for a Place ───────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchReviews({required String placeId}) async {
    var response = await baseApi.get(endpoint: "/api/reviews/$placeId");
    return response;
  }

  // ── Create Review ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createReviewService({
    required String placeId,
    required String comment,
    required double rating,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/reviews",
      data: {"place_id": placeId, "comment": comment, "rating": rating},
    );
    return response;
  }

  // ── Delete Review ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteReviewService({
    required String reviewId,
  }) async {
    var response = await baseApi.delete(endpoint: "/api/reviews/$reviewId");
    return response;
  }
}
