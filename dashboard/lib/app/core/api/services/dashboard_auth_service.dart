import 'package:dashboard/app/core/api/services/base_api_service.dart';

class DashboardAuthService {
  final BaseApiService baseApi = BaseApiService();

  // ── Login (admin or company account) ────────────────────────────────────
  Future<dynamic> loginService({
    required String emailOrPhone,
    required String password,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/dashboard/auth/login",
      data: {"email_or_phone": emailOrPhone, "password": password},
    );
    return response;
  }

  // ── Register personal account ───────────────────────────────────────────
  Future<dynamic> registerPersonalService({
    required String name,
    required String gender,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/dashboard/auth/register/personal",
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

  // ── Register company account ────────────────────────────────────────────
  Future<dynamic> registerCompanyService({
    required String name,
    required String gender,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    var response = await baseApi.post(
      endpoint: "/api/dashboard/auth/register/company",
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

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<dynamic> logoutService() async {
    var response = await baseApi.delete(endpoint: "/api/dashboard/auth/logout");
    return response;
  }
}
