import 'package:frontend/app/core/api/services/base_api_service.dart';

class AuthServices {
  final BaseApiService baseApi = BaseApiService();

  // ── Normal Login ──────────────────────────────────────────────────────────
  Future<dynamic> loginService({
    required String emailOrPhone,
    required String password,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/login",
      data: {"email_or_phone": emailOrPhone, "password": password},
    );
    return response;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<dynamic> registerService({
    required String name,
    required String gender,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/register",
      data: {
        "name": name,
        "gender": gender,
        "email": email,
        "phone": phone,
        "password": password,
        "confirm_password": confirmPassword,
      },
    );
    return response;
  }

  // ── Google Login ──────────────────────────────────────────────────────────
  Future<dynamic> googleLoginService({
    required String googleId,
    required String email,
    required String name,
    required String profileImage,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/google-login",
      data: {
        "google_id": googleId,
        "email": email,
        "name": name,
        "profile_image": profileImage,
      },
    );
    return response;
  }

  // ── Telegram Login ────────────────────────────────────────────────────────
  Future<dynamic> telegramLoginService({
    required Map<String, dynamic> telegramData,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/telegram-login",
      data: telegramData,
    );
    return response;
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<dynamic> forgotPasswordService({
    required String emailOrPhone,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/forgot-password",
      data: {"email_or_phone": emailOrPhone},
    );
    return response;
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<dynamic> verifyOtpService({
    required String emailOrPhone,
    required String otp,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/verify-otp",
      data: {"email_or_phone": emailOrPhone, "otp": otp},
    );
    return response;
  }

  // ── Reset Password ────────────────────────────────────────────────────────
  Future<dynamic> resetPasswordService({
    required String emailOrPhone,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/auth/reset-password",
      data: {
        "email_or_phone": emailOrPhone,
        "otp": otp,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      },
    );
    return response;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<dynamic> logoutService() async {
    var response = await baseApi.delete(endpoint: "/api/auth/logout");
    return response;
  }
}
