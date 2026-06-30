import 'package:frontend/app/core/api/services/base_api_service.dart';

class FavoriteService {
  final BaseApiService baseApi = BaseApiService();

  // Get all favorite lists
  Future<dynamic> getFavoriteLists() async {
    return await baseApi.get(endpoint: '/api/favorites/lists');
  }

  // Create favorite list
  Future<dynamic> createFavoriteList(String listName) async {
    return await baseApi.post(
      endpoint: '/api/favorites/lists',
      data: {"name": listName},
    );
  }

  // Rename favorite list
  Future<dynamic> renameFavoriteList({
    required String listId,
    required String name,
  }) async {
    return await baseApi.put(
      endpoint: '/api/favorites/lists/$listId',
      data: {'name': name},
    );
  }

  // Delete favorite list
  Future<dynamic> deleteFavoriteList(String listId) async {
  return await baseApi.delete(
    endpoint: '/api/favorites/lists/$listId',
  );
}

  // Add item to a favorite list
  Future<dynamic> addFavoriteItem(int listId) async {
    return await baseApi.post(
      endpoint: '/api/favorites/lists/$listId/items',
      data: {},
    );
  }

  // Get items in a favorite list
  Future<dynamic> getFavoriteItems(int listId) async {
    return await baseApi.get(endpoint: '/api/favorites/lists/$listId/items');
  }

  // Delete an item from a favorite list
  Future<dynamic> deleteFavoriteItem({
    required int listId,
    required int placeId,
  }) async {
    return await baseApi.delete(
      endpoint: '/api/favorites/lists/$listId/items/$placeId',
    );
  }

  
}
