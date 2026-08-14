import 'base_api_service.dart';

class DashboardAuthService {
  final BaseApiService baseApi = BaseApiService();

  // Login
  Future<dynamic> loginService({
    required String emailOrPhone,
    required String password,
  }) async {
    return await baseApi.post(
      endpoint: "/api/dashboard/auth/login",
      data: {
        "email_or_phone": emailOrPhone,
        "password": password,
      },
    );
  }

  // Register Personal
  Future<dynamic> registerPersonalService({
    required String name,
    required String gender,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    return await baseApi.post(
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
  }

  // Register Company
  // NOTE: matches the backend's RegisterCompanySchema exactly — there is
  // no "gender" field for company accounts, but there IS business_type
  // and address, both required.
  Future<dynamic> registerCompanyService({
    required String name,
    required String email,
    required String phone,
    required String businessType,
    required String address,
    required String password,
    required String confirmPassword,
  }) async {
    return await baseApi.post(
      endpoint: "/api/dashboard/auth/register/company",
      data: {
        "name": name,
        "email": email,
        "phone": phone,
        "business_type": businessType,
        "address": address,
        "password": password,
        "confirm_password": confirmPassword,
      },
    );
  }

  // Logout
  Future<dynamic> logoutService() async {
    return await baseApi.delete(
      endpoint: "/api/dashboard/auth/logout",
    );
  }

  // ✅ Change Password
  Future<dynamic> changePasswordService({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await baseApi.put(
      endpoint: "/api/dashboard/auth/change-password",
      data: {
        "current_password": currentPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      },
    );
  }

  // ✅ Forgot Password — sends (or resends, same endpoint) the OTP code.
  // Works for both admin and company accounts: backend checks the
  // admins collection first, then falls back to company users.
  Future<dynamic> forgotPasswordService({
    required String email,
  }) async {
    return await baseApi.post(
      endpoint: "/api/dashboard/auth/forgot-password",
      data: {
        "email": email,
      },
    );
  }

  // ✅ Verify OTP
  Future<dynamic> verifyOtpService({
    required String email,
    required String otp,
  }) async {
    return await baseApi.post(
      endpoint: "/api/dashboard/auth/verify-otp",
      data: {
        "email": email,
        "otp": otp,
      },
    );
  }

  // ✅ Reset Password — requires the OTP to have been verified first.
  Future<dynamic> resetPasswordService({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await baseApi.post(
      endpoint: "/api/dashboard/auth/reset-password",
      data: {
        "email": email,
        "otp": otp,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      },
    );
  }

  // ====================== ADMIN: MANAGE COMPANIES ======================
  // Real company accounts (users with "company" in their roles), replacing
  // the dashboard's old hardcoded mock list.

  Future<dynamic> getCompaniesService() async {
    return await baseApi.get(endpoint: "/api/dashboard/auth/admin/companies");
  }

  Future<dynamic> updateCompanyService(
    String companyId,
    Map<String, dynamic> data,
  ) async {
    return await baseApi.put(
      endpoint: "/api/dashboard/auth/admin/companies/$companyId",
      data: data,
    );
  }

  Future<dynamic> suspendCompanyService(String companyId) async {
    return await baseApi.put(
      endpoint: "/api/dashboard/auth/admin/companies/$companyId/suspend",
      data: const {},
    );
  }

  Future<dynamic> deleteCompanyService(String companyId) async {
    return await baseApi.delete(
      endpoint: "/api/dashboard/auth/admin/companies/$companyId",
    );
  }
}