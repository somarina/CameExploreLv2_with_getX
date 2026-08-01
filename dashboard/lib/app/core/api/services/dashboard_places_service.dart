import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'base_api_service.dart';

class DashboardPlacesService {
  final BaseApiService baseApi = BaseApiService();

  // Submit a place (company -> "pending", admin -> "approved" directly).
  // Matches the backend's PlaceCreate schema — name_km/description_km are
  // optional there (fall back to the English text) so the English-only
  // fields still work if left blank, but we now send everything the form
  // collects so submissions look like a real listing, not a stub.
  Future<dynamic> submitPlace({
    required String nameEn,
    String? nameKm,
    required String category,
    required String province,
    required String descriptionEn,
    String? descriptionKm,
    String? addressEn,
    String? openingHours,
    String? phoneNum,
    List<String>? tags,
    double? latitude,
    double? longitude,
    String? entryFee,
    List<String>? images,
    String? imageUrl,
  }) async {
    return await baseApi.post(
      endpoint: "/places/",
      data: {
        "name_en": nameEn,
        if (nameKm != null) "name_km": nameKm,
        "description_en": descriptionEn,
        if (descriptionKm != null) "description_km": descriptionKm,
        "province": province,
        "category": category,
        if (addressEn != null) "address_en": addressEn,
        if (openingHours != null) "opening_hours": openingHours,
        if (phoneNum != null) "phoneNum": phoneNum,
        if (tags != null) "tags": tags,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
        "entry_fee": entryFee,
        if (imageUrl != null) "image_url": imageUrl,
        if (images != null) "images": images,
      },
    );
  }

  // Uploads the picked images to Cloudinary via the backend's shared
  // review-image endpoint (it accepts any place/hotel/package target once
  // that record exists). Called AFTER submitPlace() gives us a real place
  // ID, since the backend validates the target exists first.
  Future<dynamic> uploadPlaceImages({
    required String placeId,
    required List<XFile> images,
  }) async {
    try {
      final formData = FormData();
      for (int i = 0; i < images.length && i < 5; i++) {
        final bytes = await images[i].readAsBytes();
        formData.files.add(MapEntry(
          'file${i + 1}',
          MultipartFile.fromBytes(bytes, filename: images[i].name),
        ));
      }
      final response = await baseApi.apiConfig.dio.post(
        '/api/reviews/upload-images/place/$placeId',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      final body = e.response?.data;
      return (body is Map)
          ? body
          : {"result": false, "message": e.message ?? "Image upload failed", "data": {}};
    }
  }

  // Saves the Cloudinary URLs (from uploadPlaceImages) onto the place —
  // uses the same PUT the company already uses to edit its own pending
  // submissions.
  Future<dynamic> updatePlaceImages({
    required String placeId,
    required String imageUrl,
    required List<String> images,
  }) async {
    return await baseApi.put(
      endpoint: "/places/$placeId",
      data: {
        "image_url": imageUrl,
        "images": images,
      },
    );
  }

  // "My Places" — places submitted by the logged-in company (or admin).
  Future<dynamic> getMyPlaces({String? status}) async {
    return await baseApi.get(
      endpoint: "/places/mine",
      queryParameters: {
        if (status != null) "status": status,
      },
    );
  }

  // All places — admin only sees every status; company/public callers
  // only ever get back "approved" ones regardless of the status filter.
  // limit defaults to the API's max page size (200) — the admin queue
  // needs to see everything, not just the first 50 (API default), or
  // newly submitted pending places can end up past the page cutoff.
  Future<dynamic> getPlaces({String? status, int limit = 200}) async {
    return await baseApi.get(
      endpoint: "/places/",
      queryParameters: {
        if (status != null) "status": status,
        "limit": limit,
      },
    );
  }

  // Admin approve/reject (or any owner edit while still pending) — same
  // PUT endpoint the company uses to edit its own pending submissions.
  Future<dynamic> reviewPlace({
    required String placeId,
    required String status, // "approved" | "rejected"
    String? reviewNote,
  }) async {
    return await baseApi.put(
      endpoint: "/places/$placeId",
      data: {
        "status": status,
        if (reviewNote != null) "review_note": reviewNote,
      },
    );
  }

  Future<dynamic> deletePlace(String placeId) async {
    return await baseApi.delete(endpoint: "/places/$placeId");
  }
}