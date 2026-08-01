import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/api/services/dashboard_auth_service.dart';
import '../../../core/api/services/dashboard_places_service.dart';
import '../../../routes/app_pages.dart';
import '../models/admin_colors.dart';
import '../models/admin_models.dart';

/// Which section of the dashboard is currently visible.
enum AdminSection { dashboard, managePlaces, manageUsers, approvals, analytics, settings }

class AdminScreenController extends GetxController {
  final DashboardAuthService _authService = DashboardAuthService();
  final DashboardPlacesService _placesService = DashboardPlacesService();

  // ====================== NAVIGATION STATE ======================
  final Rx<AdminSection> currentSection = AdminSection.dashboard.obs;

  void goTo(AdminSection section) => currentSection.value = section;

  // ====================== ADMIN PROFILE (from login) ======================
  final adminName = ''.obs;
  final adminRole = ''.obs;

  void _loadAdminProfile() {
    final box = GetStorage();
    final name = box.read<String>('dashboard_admin_name') ?? '';
    final role = box.read<String>('dashboard_active_role') ?? '';
    adminName.value = name.isNotEmpty ? name : 'Admin';
    adminRole.value = role.isNotEmpty
        ? role[0].toUpperCase() + role.substring(1)
        : 'Admin';
  }

  Future<void> logout() async {
    await _authService.logoutService();
    final box = GetStorage();
    await box.remove('dashboard_token');
    await box.remove('dashboard_admin_name');
    await box.remove('dashboard_active_role');
    await box.remove('dashboard_email');
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }

  // ====================== TOP-LEVEL STATS (mock for now) ======================
  // TODO: replace with real counts from GET /api/dashboard/auth/admin + places API
  int get totalPlaces => places.length;
  int get pendingCount => places.where((p) => p.status == PlaceStatus.pending).length;
  int get approvedCount => places.where((p) => p.status == PlaceStatus.approved).length;
  int get rejectedCount => places.where((p) => p.status == PlaceStatus.rejected).length;
  int get totalCompanies => companies.length;

  // ====================== PLACES (real /places data) ======================
  final RxList<AdminPlace> places = <AdminPlace>[].obs;
  final isLoadingPlaces = false.obs;

  static const _placeColorCycle = [
    AdminColors.primary,
    AdminColors.teal,
    AdminColors.amber,
    AdminColors.purple,
    AdminColors.green,
    AdminColors.red,
  ];

  AdminPlace _placeFromJson(Map<String, dynamic> json, int index) {
    final rawStatus = (json["status"] ?? "pending").toString();
    final status = switch (rawStatus) {
      "approved" => PlaceStatus.approved,
      "rejected" => PlaceStatus.rejected,
      _ => PlaceStatus.pending,
    };
    final fee = json["entry_fee"]?.toString();
    final createdAt = json["created_at"]?.toString();
    return AdminPlace(
      id: (json["id"] ?? "").toString(),
      name: (json["name_en"] ?? json["name"] ?? "").toString(),
      subtitle: (json["description_en"] ?? json["description"] ?? "").toString(),
      company: (json["owner_name"] ?? "—").toString(),
      category: (json["category"] ?? "").toString(),
      province: (json["province"] ?? "").toString(),
      fee: (fee == null || fee.isEmpty) ? "Free" : fee,
      submittedDate: createdAt != null && createdAt.length >= 10 ? createdAt.substring(0, 10) : "",
      status: status,
      imageColor: _placeColorCycle[index % _placeColorCycle.length],
    );
  }

  /// Loads every place regardless of status — admins see the full queue
  /// (pending/approved/rejected), unlike the public/company views.
  Future<void> loadPlaces() async {
    isLoadingPlaces.value = true;
    final response = await _placesService.getPlaces();
    if (response is Map && response["result"] == true) {
      final items = (response["data"]?["items"] as List?) ?? [];
      places.assignAll([
        for (int i = 0; i < items.length; i++) _placeFromJson(Map<String, dynamic>.from(items[i]), i),
      ]);
    }
    isLoadingPlaces.value = false;
  }

  Future<void> approvePlace(AdminPlace place) async {
    final response = await _placesService.reviewPlace(placeId: place.id, status: "approved");
    if (response is Map && response["result"] == true) {
      await loadPlaces();
    } else {
      Get.snackbar("Couldn't approve", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> rejectPlace(AdminPlace place, {String? note}) async {
    final response = await _placesService.reviewPlace(placeId: place.id, status: "rejected", reviewNote: note);
    if (response is Map && response["result"] == true) {
      await loadPlaces();
    } else {
      Get.snackbar("Couldn't reject", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> deletePlace(AdminPlace place) async {
    final response = await _placesService.deletePlace(place.id);
    if (response is Map && response["result"] == true) {
      places.removeWhere((p) => p.id == place.id);
    } else {
      Get.snackbar("Couldn't delete", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  // ====================== MOCK: COMPANIES ======================
  final RxList<AdminCompany> companies = <AdminCompany>[
    AdminCompany(
      name: 'Angkor Tourism Co.',
      id: 'U-1000',
      initials: 'AT',
      color: AdminColors.primary,
      email: 'angkor@tour.com',
      phone: '+855 12 345 678',
      businessType: 'Tourism Agency',
      businessTypeColor: AdminColors.primary,
      location: 'Siem Reap',
      places: 0,
      joined: 'Mar 10, 2026',
    ),
    AdminCompany(
      name: 'Coastal Adventures',
      id: 'U-1001',
      initials: 'CA',
      color: AdminColors.purple,
      email: 'coastal@adv.com',
      phone: '+855 11 234 567',
      businessType: 'Travel Agency',
      businessTypeColor: AdminColors.purple,
      location: 'Sihanoukville',
      places: 0,
      joined: 'Mar 15, 2026',
    ),
    AdminCompany(
      name: 'Heritage Travel',
      id: 'U-1002',
      initials: 'HT',
      color: AdminColors.green,
      email: 'heritage@travel.com',
      phone: '+855 23 456 789',
      businessType: 'Tour Operator',
      businessTypeColor: AdminColors.green,
      location: 'Phnom Penh',
      places: 0,
      joined: 'Mar 20, 2026',
    ),
    AdminCompany(
      name: 'Mekong River Tours',
      id: 'U-1003',
      initials: 'MR',
      color: AdminColors.amber,
      email: 'mekong@river.com',
      phone: '+855 17 890 123',
      businessType: 'Boat Tourism',
      businessTypeColor: AdminColors.amber,
      location: 'Kratie',
      places: 0,
      joined: 'Apr 1, 2026',
    ),
    AdminCompany(
      name: 'Khmer Culture Hub',
      id: 'U-1004',
      initials: 'KC',
      color: AdminColors.red,
      email: 'khmer@culture.com',
      phone: '+855 99 111 222',
      businessType: 'Cultural Tour',
      businessTypeColor: AdminColors.amber,
      location: 'Battambang',
      places: 0,
      joined: 'Apr 5, 2026',
    ),
    AdminCompany(
      name: 'somarina',
      id: 'U-1005',
      initials: 'S',
      color: AdminColors.teal,
      email: 'somarinak@gmail.com',
      phone: '+855 16 269 851',
      businessType: 'Hotel & Resort',
      businessTypeColor: AdminColors.textSecondary,
      location: '21st',
      places: 1,
      joined: 'Jun 23, 2026',
    ),
  ].obs;

  // ====================== MOCK: ANALYTICS ======================
  final List<ProvinceStat> provinceStats = const [
    ProvinceStat(province: 'Siem Reap', places: 38, share: 38, growth: 14),
    ProvinceStat(province: 'Phnom Penh', places: 25, share: 25, growth: 23),
    ProvinceStat(province: 'Sihanoukville', places: 17, share: 17, growth: 24),
    ProvinceStat(province: 'Battambang', places: 10, share: 10, growth: 6),
    ProvinceStat(province: 'Kampot', places: 7, share: 7, growth: 12),
    ProvinceStat(province: 'Other', places: 3, share: 3, growth: 23),
  ];

  final List<CategoryStat> categoryStats = const [
    CategoryStat(label: 'Temple', percent: 28, color: AdminColors.primary),
    CategoryStat(label: 'Beach', percent: 19, color: AdminColors.green),
    CategoryStat(label: 'Cultural Site', percent: 22, color: AdminColors.amber),
    CategoryStat(label: 'Museum', percent: 9, color: AdminColors.purple),
    CategoryStat(label: 'Natural Park', percent: 13, color: Color(0xFFEC4899)),
    CategoryStat(label: 'Historical Monument', percent: 9, color: AdminColors.teal),
  ];

  // Weekly submissions vs approved, for the Dashboard area chart (Mon..Sun)
  final List<double> weeklySubmissions = const [3, 6, 4, 9, 6, 3, 4];
  final List<double> weeklyApproved = const [2, 4, 3, 7, 5, 2, 3];

  // Monthly trend, for the Analytics page (Jan..Jul)
  final List<double> monthlySubmissions = const [8, 11, 10, 17, 16, 21, 22];
  final List<double> monthlyApproved = const [6, 8, 8, 13, 12, 18, 18];
  final List<double> monthlyRejected = const [1, 1, 1, 2, 2, 1, 2];

  @override
  void onInit() {
    super.onInit();
    _loadAdminProfile();
    loadPlaces();
  }
}