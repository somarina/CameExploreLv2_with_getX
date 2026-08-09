// import 'package:frontend/app/core/api/services/base_api_service.dart';
// import 'package:frontend/app/modules/discover_screen/nearby_screen/place_model.dart';

// class SearchService {
//   final BaseApiService baseApi = BaseApiService();

//   Future<List<PlaceModel>> search({
//     required String keyword,
//     required String type,
//     int limit = 20,
//   }) async {
//     final response = await baseApi.get(
//       endpoint: "/api/search/",
//       queryParameters: {"keyword": keyword, "type": type, "limit": limit},
//     );

//     final List data = response.data["data"]["places"];

//     return data.map((e) => PlaceModel.fromJson(e)).toList();
//   }
// }

import 'package:frontend/app/core/api/services/base_api_service.dart';

class SearchService {
  final BaseApiService baseApi = BaseApiService();

  Future<Map<String, dynamic>> search({
    required String keyword,
    String type = "all",
    int limit = 20,
  }) async {
    final response = await baseApi.get(
      endpoint: "/api/search/",
      queryParameters: {
        "keyword": keyword,
        "limit": limit,
      },
    );

    print("SEARCH RESPONSE: $response");

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return {};
  }
}