import 'base_api_service.dart';

class DashboardHotelsService {
  final BaseApiService baseApi = BaseApiService();

  // All hotels — admin only sees every status; company/public callers
  // only ever get back "approved" ones regardless of the status filter.
  // limit defaults to the API's max page size (200) — the admin queue
  // needs to see everything, not just the first 50 (API default).
  Future<dynamic> getHotels({String? status, int limit = 200}) async {
    return await baseApi.get(
      endpoint: "/hotels/",
      queryParameters: {
        if (status != null) "status": status,
        "limit": limit,
      },
    );
  }

  // Admin approve/reject (or any owner edit while still pending) — same
  // PUT endpoint the company uses to edit its own pending submissions.
  Future<dynamic> reviewHotel({
    required String hotelId,
    required String status, // "approved" | "rejected"
    String? reviewNote,
  }) async {
    return await baseApi.put(
      endpoint: "/hotels/$hotelId",
      data: {
        "status": status,
        if (reviewNote != null) "review_note": reviewNote,
      },
    );
  }

  // Admin edit — same PUT endpoint as reviewHotel, but for arbitrary
  // field updates (name/address/province/star rating/etc.) instead of
  // just the approve/reject status.
  Future<dynamic> updateHotel(String hotelId, Map<String, dynamic> data) async {
    return await baseApi.put(endpoint: "/hotels/$hotelId", data: data);
  }

  Future<dynamic> deleteHotel(String hotelId) async {
    return await baseApi.delete(endpoint: "/hotels/$hotelId");
  }
}
