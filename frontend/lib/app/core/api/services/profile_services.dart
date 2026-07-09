import 'package:dio/dio.dart';
import 'package:frontend/app/core/api/services/base_api_service.dart';

class ProfileServices {
  final baseApi = BaseApiService();

  // 🔹 GET PROFILE
  Future<Map<String, dynamic>> getProfileService() async {
    final response = await baseApi.get(endpoint: "/api/profile/me");
    return response;
  }

  // 🔹 UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfileService({
    required String avatar,
    required String name,
    required String gender,
    required String phone,
    required String email,
  }) async {
    final response = await baseApi.put(
      endpoint: "/api/profile/info",
      data: {
        "name": name,
        "gender": gender,
        "phone": phone,
        "email": email,
        "profile_image": avatar,
      },
    );
    return response;
  }
  // avatar
  // Future<Map<String, dynamic>> uploadAvatarService({
  //   required String avatarPath,
  // }) async {
  //   final dynamic formData = FormData.fromMap({
  //     "file": await MultipartFile.fromFile(
  //       avatarPath,
  //       filename: avatarPath.split('/').last,
  //     ),
  //   });

  //   final response = await baseApi.post(
  //     endpoint: "/api/profile/avatar/upload",
  //     data: formData,
  //   );

  //   return response;
  // }

  Future<Map<String, dynamic>> uploadAvatarService({
    required String avatarPath,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        avatarPath,
        filename: avatarPath.split('/').last,
      ),
    });

    final response = await baseApi.postFormData(
      endpoint: "/api/profile/avatar/upload",
      data: formData,
    );

    return response;
  }

  // 🔹 CHANGE PASSWORD
  Future<Map<String, dynamic>> changePasswordService({
    required String current_password,
    required String new_password,
    required String confirm_password,
  }) async {
    final response = await baseApi.put(
      endpoint: "/api/profile/change-password",
      data: {
        "current_password": current_password,
        "new_password": new_password,
        "confirm_password": confirm_password,
      },
    );
    return response;
  }

  //feedback
  Future<Map<String, dynamic>> feedbackService({
    required int rating,
    required String review_type,
    required String name,
    required String email,
    required String comment,
  }) async {
    final response = await baseApi.post(
      endpoint: "/api/reviews/create",
      data: {
        "rating": rating,
        "review_type": review_type,
        "name": name,
        "email": email,
        "comment": comment,
      },
    );
    return response;
  }
}
