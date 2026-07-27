import 'package:frontend/app/core/api/services/base_api_service.dart';

class TravelPackageServices {
  final BaseApiService baseApi = BaseApiService();

  /// GET /travel_packages/ - Get Packages
  Future<dynamic> fetchTravelPackages({
    String? search,
    String? tag,
    int limit = 50,
    int skip = 0,
  }) async {
    return await baseApi.get(
      endpoint: "/travel_packages/",
      queryParameters: {
        if (search != null && search.isNotEmpty) "search": search,
        if (tag != null && tag.isNotEmpty) "tag": tag,
        "limit": limit,
        "skip": skip,
      },
    );
  }

  /// POST /travel_packages/ - Create Package
  Future<dynamic> createTravelPackage(Map<String, dynamic> packageData) async {
    return await baseApi.post(endpoint: "/travel_packages/", data: packageData);
  }

  /// GET /travel_packages/mine - Get My Packages
  Future<dynamic> fetchMyTravelPackages({int limit = 50, int skip = 0}) async {
    return await baseApi.get(
      endpoint: "/travel_packages/mine",
      queryParameters: {"limit": limit, "skip": skip},
    );
  }

  /// GET /travel_packages/{package_id} - Get Package
  Future<dynamic> fetchTravelPackageById(String id) async {
    return await baseApi.get(endpoint: "/travel_packages/$id");
  }
}
