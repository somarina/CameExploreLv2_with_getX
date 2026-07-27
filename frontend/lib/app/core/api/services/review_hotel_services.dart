import 'package:frontend/app/core/api/services/base_api_service.dart';

class HotelReviewServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchReviews(String hotelId) async {
    return await baseApi.get(
      endpoint: "api/reviews/hotel/$hotelId",
    );
  }

  Future<dynamic> createReview({
    required Map<String, dynamic> data,
    required String hotelId,
  }) async {
    return await baseApi.postFormDataFiles(
      endpoint: "api/reviews/hotel/$hotelId",
      data: data,
    );
  }
}