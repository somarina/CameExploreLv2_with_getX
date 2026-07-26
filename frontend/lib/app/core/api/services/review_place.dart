import 'package:frontend/app/core/api/services/base_api_service.dart';

enum ReviewType { place, package }

class PlaceReviewService {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchReviews(
    String id, {
    ReviewType type = ReviewType.place,
  }) async {
    final endpoint = type == ReviewType.place
        ? "api/reviews/place/$id"
        : "api/reviews/package/$id";

    return await baseApi.get(endpoint: endpoint);
  }

  Future<dynamic> createReview({
    required Map<String, dynamic> data,
    required String id,
    ReviewType type = ReviewType.place,
  }) async {
    final endpoint = type == ReviewType.place
        ? "api/reviews/place/$id"
        : "api/reviews/package/$id";

    return await baseApi.postFormDataFiles(endpoint: endpoint, data: data);
  }
}
