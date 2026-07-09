import 'package:frontend/app/core/api/services/base_api_service.dart';

class PlacesServices {
  final BaseApiService baseApi = BaseApiService();

  // ── Get All Places ────────────────────────────────────────────────────────
  // Future<Map<String, dynamic>> fetchPlaces({
  //   String? category,
  //   String? search,
  // }) async {
  //   var response = await baseApi.get(
  //     endpoint: "/places",
  //     queryParameters: {
  //       if (category != null) "category": category,
  //       if (search != null) "search": search,
  //     },
  //   );
  //   return response;
  // }

  // ── Get Place Detail ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchPlaceDetail({required String id}) async {
    var response = await baseApi.get(endpoint: "/api/places/$id");
    return response;
  }

  Future<Map<String, dynamic>> fetchDiscoverHome() async {
    return await baseApi.get(endpoint: "/api/discover/home");
  }

  Future<List<dynamic>> getPlaces() async {
    return await baseApi.get(endpoint: "/places/");
  }

  Future<List<dynamic>> fetchPlaces({
  String? category,
  String? search,
}) async {
  final response = await baseApi.get(
    endpoint: "/places",
    queryParameters: {
      if (category != null) "category": category,
      if (search != null) "search": search,
    },
  );

  return response;
}
}
