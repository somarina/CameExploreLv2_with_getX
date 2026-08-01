import 'package:frontend/app/core/api/services/base_api_service.dart';

class HotelServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchHotels({
    String? province,
    String? search,
    int limit = 50,
    int skip = 0,
  }) async {
    return await baseApi.get(
      endpoint: "/hotels",
      queryParameters: {
        if (province != null && province.isNotEmpty) "province": province,
        if (search != null && search.isNotEmpty) "search": search,
        "limit": limit,
        "skip": skip,
      },
    );
  }

  Future<dynamic> fetchHotelById(String id) async {
    return await baseApi.get(endpoint: "/hotels/$id");
  }

 
}
