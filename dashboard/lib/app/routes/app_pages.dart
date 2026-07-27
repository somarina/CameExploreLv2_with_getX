import 'package:get/get.dart';

import '../modules/admin_screen/bindings/admin_screen_binding.dart';
import '../modules/admin_screen/views/admin_screen_view.dart';
import '../modules/auth/login_screen/bindings/login_screen_binding.dart';
import '../modules/auth/login_screen/views/login_screen_view.dart';
import '../modules/auth/register_screen/bindings/register_screen_binding.dart';
import '../modules/auth/register_screen/views/organization_register_screen_view.dart';
import '../modules/auth/register_screen/views/personal_register_screen_view.dart';
import '../modules/auth/register_screen/views/register_screen_view.dart';
import '../modules/auth/forget_password/bindings/forget_password_binding.dart';
import '../modules/auth/forget_password/views/forget_password_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER_SCREEM,
      page: () => const RegisterScreenView(),
      binding: RegisterScreenBinding(),
    ),
    GetPage(
      name: _Paths.PERSONAL_REGISTER_SCREEN,
      page: () => const PersonalRegisterScreenView(),
      binding: RegisterScreenBinding(),
    ),
    GetPage(
      name: _Paths.COMPANY_REGISTER_SCREEN,
      page: () => const OrganizationRegisterScreenView(),
      binding: RegisterScreenBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_SCREEN,
      page: () => const AdminScreenView(),
      binding: AdminScreenBinding(),
    ),
    GetPage(
      name: _Paths.FORGET_PASSWORD,
      page: () => const ForgetPasswordView(),
      binding: ForgetPasswordBinding(),
    ),
  ];
}
