import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/base_api_service.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';

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
    return await baseApi.delete(endpoint: '/api/favorites/lists/$listId');
  }

  // Add item to a favorite list
  // Future<dynamic> addFavoriteItem({
  //   required String listId,
  //   required String placeId,
  // }) async {
  //   return await baseApi.post(
  //     endpoint: '/api/favorites/lists/$listId/items',
  //     data: {"place_id": placeId},
  //   );
  // }
  Future<dynamic> addFavoriteItem({
    required String listId,
    required String itemId,
    required FavoriteItemType type,
  }) {
    final body = {"item_id": itemId, "item_type": type.name};

    print("Add favorite body: $body");

    return baseApi.post(
      endpoint: '/api/favorites/lists/$listId/items',
      data: body,
    );
  }

  // Get items in a favorite list
  Future<dynamic> getFavoriteItems(String listId) async {
    return await baseApi.get(endpoint: '/api/favorites/lists/$listId/items');
  }

  Future<dynamic> deleteFavoriteItem({
    required String listId,
    required String itemId,
  }) async {
    final endpoint = '/api/favorites/lists/$listId/items/$itemId';

    print("DELETE Endpoint: $endpoint");

    return await baseApi.delete(endpoint: endpoint);
  }
  
  Future<Map<String, dynamic>?> getPlaceById(String id) async {
    try {
      final response = await baseApi.get(endpoint: "/api/places/$id");

      debugPrint("PLACE RESPONSE: $response");

      if (response["result"] == true) {
        return Map<String, dynamic>.from(response["data"]);
      }

      return null;
    } catch (e) {
      debugPrint("Get place error: $e");
      return null;
    }
  }
}
