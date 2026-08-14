import 'base_api_service.dart';

class DashboardRestaurantsService {
  final BaseApiService baseApi = BaseApiService();

  // All restaurants — admin only sees every status; company/public callers
  // only ever get back "approved" ones regardless of the status filter.
  // limit defaults to the API's max page size (200) — the admin queue
  // needs to see everything, not just the first 50 (API default).
  Future<dynamic> getRestaurants({String? status, int limit = 200}) async {
    return await baseApi.get(
      endpoint: "/restaurants/",
      queryParameters: {
        if (status != null) "status": status,
        "limit": limit,
      },
    );
  }

  // Admin approve/reject (or any owner edit while still pending) — same
  // PUT endpoint the company uses to edit its own pending submissions.
  Future<dynamic> reviewRestaurant({
    required String restaurantId,
    required String status, // "approved" | "rejected"
    String? reviewNote,
  }) async {
    return await baseApi.put(
      endpoint: "/restaurants/$restaurantId",
      data: {
        "status": status,
        if (reviewNote != null) "review_note": reviewNote,
      },
    );
  }

  // Admin edit — same PUT endpoint as reviewRestaurant, but for arbitrary
  // field updates instead of just the approve/reject status.
  Future<dynamic> updateRestaurant(String restaurantId, Map<String, dynamic> data) async {
    return await baseApi.put(endpoint: "/restaurants/$restaurantId", data: data);
  }

  Future<dynamic> deleteRestaurant(String restaurantId) async {
    return await baseApi.delete(endpoint: "/restaurants/$restaurantId");
  }
}
