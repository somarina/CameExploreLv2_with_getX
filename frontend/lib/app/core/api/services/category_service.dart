import 'package:frontend/app/core/api/services/base_api_service.dart';

class CategoryService {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> getCategories() async {
    return await baseApi.get(
      endpoint: '/api/categories',
    );
  }
}