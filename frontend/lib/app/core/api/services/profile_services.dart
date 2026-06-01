import 'package:dio/dio.dart';
import 'package:frontend/app/core/api/services/base_api_service.dart';

class ProfileServices {
  final BaseApiService baseApi = BaseApiService();

  // ── Get My Profile ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchProfile() async {
    var response = await baseApi.get(endpoint: "/api/profile/me");
    return response;
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateProfileService({
    required String name,
    required String gender,
    required String phone,
  }) async {
    var response = await baseApi.put(
      endpoint: "/api/profile/me",
      data: {"name": name, "gender": gender, "phone": phone},
    );
    return response;
  }

  // ── Upload Profile Image ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> uploadProfileImageService({
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
    });
    var response = await baseApi.postFormData(
      endpoint: "/api/profile/upload-image",
      data: formData,
    );
    return response;
  }
}
