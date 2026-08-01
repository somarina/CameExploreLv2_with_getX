import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../core/api/services/dashboard_auth_service.dart';
import '../../../../routes/app_pages.dart';
import '../views/location_picker_screen.dart';

class RegisterScreenController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();

  // ── Carousel state for the top image card ────────────────────────
  final PageController pageController = PageController();
  final currentPage = 0.obs;

  final List<String> carouselImages = [
    "assets/images/angkor_wat.png",
    "assets/images/angkor_wat.png",
    "assets/images/angkor_wat.png",
    "assets/images/angkor_wat.png",
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  // ── Form ───────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  final companyNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // PASTE YOUR REAL KEY BELOW — the map will stay black and addresses will
  // show as raw lat/lng until this is a real key with Maps JavaScript API,
  // Places API, and Geocoding API enabled (see console.cloud.google.com).
  // Read at build/run time via --dart-define — NEVER hardcode the real key
  // here. See README section "Google Maps API key setup" for how to run
  // the app with your key.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  final List<String> businessTypes = [
    'Hotel & Accommodation',
    'Tour Operator',
    'Travel Agency',
    'Restaurant',
    'Transportation',
    'Adventure & Activities',
    'Other',
  ];
  final Rxn<String> selectedBusinessType = Rxn<String>();

  final DashboardAuthService _authService = DashboardAuthService();

  // Populated when the user picks a suggestion from Google Places.
  // Stays null if they just type the address by hand — that's fine, address
  // itself still gets submitted from addressController.text.
  final Rxn<double> selectedLat = Rxn<double>();
  final Rxn<double> selectedLng = Rxn<double>();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final agreedToTerms = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void toggleAgreedToTerms(bool? value) =>
      agreedToTerms.value = value ?? false;

  void setBusinessType(String? value) => selectedBusinessType.value = value;

  // Called when a suggestion is tapped in the Google Places dropdown.
  void onAddressSelected(String description, {double? lat, double? lng}) {
    addressController.text = description;
    addressController.selection = TextSelection.fromPosition(
      TextPosition(offset: description.length),
    );
    selectedLat.value = lat;
    selectedLng.value = lng;
  }

  /// Opens the full-screen "pick on map" flow (search + drag map + pin) and
  /// fills the address field with the confirmed location.
  Future<void> openLocationPicker() async {
    final result = await Get.to<Map<String, dynamic>>(
      () => LocationPickerScreen(
        initialLat: selectedLat.value,
        initialLng: selectedLng.value,
      ),
    );
    if (result == null) return;
    onAddressSelected(
      result['address'] as String? ?? addressController.text,
      lat: result['lat'] as double?,
      lng: result['lng'] as double?,
    );
  }

  String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company / organization name is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8) return 'Enter a valid phone number';
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Address is required';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (addressController.text.trim().isEmpty) {
      Get.snackbar(
        'Address required',
        'Please enter or pick your company address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!agreedToTerms.value) {
      Get.snackbar(
        'Terms required',
        'Please agree to the Terms of Service and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedBusinessType.value == null ||
        selectedBusinessType.value!.trim().isEmpty) {
      Get.snackbar(
        'Business type required',
        'Please select your business type.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final response = await _authService.registerCompanyService(
      name: companyNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      businessType: selectedBusinessType.value!,
      address: addressController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    isLoading.value = false;

    if (response == null) {
      Get.snackbar(
        'Registration failed',
        'Could not reach the server',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // BaseApiService already normalizes both the success shape
    // ({"result", "message", "data"}) and the FastAPI error shape
    // ({"detail": {"result", "message", "data"}}) down to the same
    // top-level "result"/"message" keys, same as loginService.
    final bool result = response['result'] == true;
    final String message = response['message'] ?? 'Something went wrong';

    if (!result) {
      Get.snackbar('Registration failed', message, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};

    // The backend issues a token immediately on registration (it behaves
    // like an auto-login), so store it exactly like login does.
    final box = GetStorage();
    box.write('dashboard_token', data['token'] ?? '');
    box.write('dashboard_admin_name', data['name'] ?? '');
    box.write('dashboard_active_role', data['active_role'] ?? 'company');
    box.write('dashboard_email', data['email'] ?? '');

    Get.snackbar(
      'Welcome',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );

    // TODO: make sure Routes.COMPANY_SCREEN exists (see company screen work).
    Get.offAllNamed(Routes.COMPANY_SCREEN);
  }

  void goToSignIn() {
    // TODO: adjust to your actual login route name if different.
    Get.offNamed(Routes.LOGIN_SCREEN);
  }

  void registerAsIndividual() {
    Get.toNamed(Routes.PERSONAL_REGISTER_SCREEN);
  }

  void registerAsTravelAgency() {
    Get.toNamed(Routes.COMPANY_REGISTER_SCREEN);
  }

  @override
  void onClose() {
    pageController.dispose();
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}