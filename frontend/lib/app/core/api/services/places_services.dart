// import 'package:frontend/app/core/api/services/base_api_service.dart';

// class PlacesServices {
//   final BaseApiService baseApi = BaseApiService();

//   // ── Get All Places ────────────────────────────────────────────────────────
//   Future<dynamic> fetchPlaces({String? category, String? search}) async {
//     var response = await baseApi.get(
//       endpoint: "/places",
//       queryParameters: {
//         "category": ?category,
//         "search": ?search,
//       },
//     );
//     return response;
//   }

//   // ── Get Place Detail ──────────────────────────────────────────────────────
//   Future<Map<String, dynamic>> fetchPlaceDetail({required String id}) async {
//     var response = await baseApi.get(endpoint: "/api/places/$id");
//     return response;
//   }

//   Future<Map<String, dynamic>> fetchDiscoverHome() async {
//     return await baseApi.get(endpoint: "/api/discover/home");
//   }
//   Future<List<dynamic>> getPlaces() async {
//     return await baseApi.get(endpoint: "/places/");
//   }

// }

import 'package:frontend/app/core/api/services/base_api_service.dart';

class PlacesServices {
  final BaseApiService baseApi = BaseApiService();

  // ── Get All Places ────────────────────────────────────────────────────────
  Future<dynamic> fetchPlaces({String? category, String? search}) async {
    // Build query map securely omitting null parameters if necessary
    final Map<String, dynamic> query = {};
    if (category != null) query["category"] = category;
    if (search != null) query["search"] = search;

    var response = await baseApi.get(
      endpoint: "/places",
      // queryParameters: query,
      queryParameters: {
        "category": ?category,
        "search": ?search,
      },
    );
    return response;
  }

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
}