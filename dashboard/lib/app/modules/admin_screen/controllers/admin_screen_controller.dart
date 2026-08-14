import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/api/services/dashboard_auth_service.dart';
import '../../../core/api/services/dashboard_hotels_service.dart';
import '../../../core/api/services/dashboard_packages_service.dart';
import '../../../core/api/services/dashboard_places_service.dart';
import '../../../routes/app_pages.dart';
import '../models/admin_colors.dart';
import '../models/admin_models.dart';

/// Which section of the dashboard is currently visible.
enum AdminSection {
  dashboard,
  managePlaces,
  manageHotels,
  managePackages,
  manageRestaurants,
  manageUsers,
  approvals,
  analytics,
  settings,
}

class AdminScreenController extends GetxController {
  final DashboardAuthService _authService = DashboardAuthService();
  final DashboardPlacesService _placesService = DashboardPlacesService();
  final DashboardHotelsService _hotelsService = DashboardHotelsService();
  final DashboardPackagesService _packagesService = DashboardPackagesService();

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

  /// Pulls a usable photo URL out of a place/hotel/package/restaurant JSON
  /// payload — prefers the explicit `image_url`, otherwise falls back to
  /// the first entry in `images`. Returns null if neither is set so the
  /// UI can fall back to its colored icon placeholder.
  String? _firstImageUrl(Map<String, dynamic> json) {
    final direct = json["image_url"]?.toString();
    if (direct != null && direct.trim().isNotEmpty) return direct;
    final images = json["images"];
    if (images is List && images.isNotEmpty) {
      final first = images.first?.toString();
      if (first != null && first.trim().isNotEmpty) return first;
    }
    return null;
  }

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
      imageUrl: _firstImageUrl(json),
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

  Future<void> editPlace(AdminPlace place, Map<String, String> values) async {
    final data = <String, dynamic>{
      "name_en": values["name_en"],
      "description_en": values["description_en"],
      "category": values["category"],
      "province": values["province"],
      "entry_fee": values["entry_fee"],
    };
    final response = await _placesService.updatePlace(place.id, data);
    if (response is Map && response["result"] == true) {
      await loadPlaces();
    } else {
      Get.snackbar("Couldn't save changes", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
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

  // ====================== HOTELS / PACKAGES / RESTAURANTS (real data) ======================
  // Same submit -> pending -> admin approves/rejects/deletes workflow as
  // places, backed by /hotels, /travel_packages, /restaurants. Rows use
  // AdminListingItem (models/admin_models.dart) so one page widget
  // (AdminManageListingPage) renders all three instead of tripling the UI.

  final RxList<AdminListingItem> hotels = <AdminListingItem>[].obs;
  final isLoadingHotels = false.obs;
  final RxList<AdminListingItem> packages = <AdminListingItem>[].obs;
  final isLoadingPackages = false.obs;
  final RxList<AdminListingItem> restaurants = <AdminListingItem>[].obs;
  final isLoadingRestaurants = false.obs;

  AdminListingItem _hotelFromJson(Map<String, dynamic> json, int index) {
    final rawStatus = (json["status"] ?? "pending").toString();
    final status = switch (rawStatus) {
      "approved" => PlaceStatus.approved,
      "rejected" => PlaceStatus.rejected,
      _ => PlaceStatus.pending,
    };
    final createdAt = json["created_at"]?.toString();
    final star = json["star_rating"];
    return AdminListingItem(
      id: (json["id"] ?? "").toString(),
      name: (json["name_en"] ?? "").toString(),
      subtitle: (json["address_en"] ?? json["description_en"] ?? "").toString(),
      owner: (json["owner_id"] ?? "—").toString(),
      typeLabel: star == null ? "—" : "$star★",
      location: (json["province"] ?? "").toString(),
      price: (json["room_types"] is List && (json["room_types"] as List).isNotEmpty)
          ? "\$${(json["room_types"] as List).first["price_per_night"] ?? "—"}/night"
          : "—",
      submittedDate: createdAt != null && createdAt.length >= 10 ? createdAt.substring(0, 10) : "",
      status: status,
      imageColor: _placeColorCycle[index % _placeColorCycle.length],
      imageUrl: _firstImageUrl(json),
    );
  }

  AdminListingItem _packageFromJson(Map<String, dynamic> json, int index) {
    final rawStatus = (json["status"] ?? "pending").toString();
    final status = switch (rawStatus) {
      "approved" => PlaceStatus.approved,
      "rejected" => PlaceStatus.rejected,
      _ => PlaceStatus.pending,
    };
    final createdAt = json["created_at"]?.toString();
    final duration = json["duration_days"];
    final price = json["price_per_person"];
    return AdminListingItem(
      id: (json["id"] ?? "").toString(),
      name: (json["name_en"] ?? "").toString(),
      subtitle: (json["description_en"] ?? "").toString(),
      owner: (json["owner_id"] ?? "—").toString(),
      typeLabel: duration == null ? "—" : "$duration day(s)",
      location: "—",
      price: price == null ? "—" : "\$$price/person",
      submittedDate: createdAt != null && createdAt.length >= 10 ? createdAt.substring(0, 10) : "",
      status: status,
      imageColor: _placeColorCycle[index % _placeColorCycle.length],
      imageUrl: _firstImageUrl(json),
    );
  }

  AdminListingItem _restaurantFromJson(Map<String, dynamic> json, int index) {
    final rawStatus = (json["status"] ?? "pending").toString();
    final status = switch (rawStatus) {
      "approved" => PlaceStatus.approved,
      "rejected" => PlaceStatus.rejected,
      _ => PlaceStatus.pending,
    };
    final createdAt = json["created_at"]?.toString();
    // Restaurants are just Places with category "restaurant" — same
    // collection your mobile app already reads from /places, so anything
    // approved here shows up there immediately (and vice versa).
    final tags = (json["tags"] as List?)?.map((t) => t.toString()).toList() ?? [];
    return AdminListingItem(
      id: (json["id"] ?? "").toString(),
      name: (json["name_en"] ?? "").toString(),
      subtitle: (json["address_en"] ?? json["description_en"] ?? "").toString(),
      owner: (json["owner_id"] ?? "—").toString(),
      typeLabel: tags.isNotEmpty ? tags.first : "—",
      location: (json["province"] ?? "").toString(),
      price: (json["entry_fee"] ?? "—").toString(),
      submittedDate: createdAt != null && createdAt.length >= 10 ? createdAt.substring(0, 10) : "",
      status: status,
      imageColor: _placeColorCycle[index % _placeColorCycle.length],
      imageUrl: _firstImageUrl(json),
    );
  }

  /// Loads every hotel regardless of status — admins see the full queue.
  Future<void> loadHotels() async {
    isLoadingHotels.value = true;
    final response = await _hotelsService.getHotels();
    if (response is Map && response["result"] == true) {
      final items = (response["data"]?["items"] as List?) ?? [];
      hotels.assignAll([
        for (int i = 0; i < items.length; i++) _hotelFromJson(Map<String, dynamic>.from(items[i]), i),
      ]);
    }
    isLoadingHotels.value = false;
  }

  Future<void> approveHotel(AdminListingItem hotel) async {
    final response = await _hotelsService.reviewHotel(hotelId: hotel.id, status: "approved");
    if (response is Map && response["result"] == true) {
      await loadHotels();
    } else {
      Get.snackbar("Couldn't approve", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> rejectHotel(AdminListingItem hotel, {String? note}) async {
    final response = await _hotelsService.reviewHotel(hotelId: hotel.id, status: "rejected", reviewNote: note);
    if (response is Map && response["result"] == true) {
      await loadHotels();
    } else {
      Get.snackbar("Couldn't reject", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  /// Applies edits from the "Edit" dialog. `values` keys match the
  /// AdminEditField.key set in admin_screen_view.dart's editFieldsBuilder.
  Future<void> editHotel(AdminListingItem hotel, Map<String, String> values) async {
    final data = <String, dynamic>{
      "name_en": values["name_en"],
      "address_en": values["address_en"],
      "province": values["province"],
    };
    final star = int.tryParse(values["star_rating"] ?? "");
    if (star != null) data["star_rating"] = star;
    final response = await _hotelsService.updateHotel(hotel.id, data);
    if (response is Map && response["result"] == true) {
      await loadHotels();
    } else {
      Get.snackbar("Couldn't save changes", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> deleteHotel(AdminListingItem hotel) async {
    final response = await _hotelsService.deleteHotel(hotel.id);
    if (response is Map && response["result"] == true) {
      hotels.removeWhere((h) => h.id == hotel.id);
    } else {
      Get.snackbar("Couldn't delete", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  /// Loads every package regardless of status — admins see the full queue.
  Future<void> loadPackages() async {
    isLoadingPackages.value = true;
    final response = await _packagesService.getPackages();
    if (response is Map && response["result"] == true) {
      final items = (response["data"]?["items"] as List?) ?? [];
      packages.assignAll([
        for (int i = 0; i < items.length; i++) _packageFromJson(Map<String, dynamic>.from(items[i]), i),
      ]);
    }
    isLoadingPackages.value = false;
  }

  Future<void> approvePackage(AdminListingItem package) async {
    final response = await _packagesService.reviewPackage(packageId: package.id, status: "approved");
    if (response is Map && response["result"] == true) {
      await loadPackages();
    } else {
      Get.snackbar("Couldn't approve", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> rejectPackage(AdminListingItem package, {String? note}) async {
    final response = await _packagesService.reviewPackage(packageId: package.id, status: "rejected", reviewNote: note);
    if (response is Map && response["result"] == true) {
      await loadPackages();
    } else {
      Get.snackbar("Couldn't reject", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> editPackage(AdminListingItem package, Map<String, String> values) async {
    final data = <String, dynamic>{
      "name_en": values["name_en"],
      "description_en": values["description_en"],
    };
    final duration = int.tryParse(values["duration_days"] ?? "");
    if (duration != null) data["duration_days"] = duration;
    final price = double.tryParse(values["price_per_person"] ?? "");
    if (price != null) data["price_per_person"] = price;
    final response = await _packagesService.updatePackage(package.id, data);
    if (response is Map && response["result"] == true) {
      await loadPackages();
    } else {
      Get.snackbar("Couldn't save changes", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> deletePackage(AdminListingItem package) async {
    final response = await _packagesService.deletePackage(package.id);
    if (response is Map && response["result"] == true) {
      packages.removeWhere((p) => p.id == package.id);
    } else {
      Get.snackbar("Couldn't delete", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  /// Loads every restaurant regardless of status — admins see the full queue.
  /// Restaurants aren't their own backend resource; they're Places filtered
  /// to category "restaurant" (same source your mobile app's restaurant
  /// section reads from), so nothing here touches /restaurants at all.
  Future<void> loadRestaurants() async {
    isLoadingRestaurants.value = true;
    final response = await _placesService.getPlaces(category: "restaurant");
    if (response is Map && response["result"] == true) {
      final items = (response["data"]?["items"] as List?) ?? [];
      restaurants.assignAll([
        for (int i = 0; i < items.length; i++) _restaurantFromJson(Map<String, dynamic>.from(items[i]), i),
      ]);
    }
    isLoadingRestaurants.value = false;
  }

  Future<void> approveRestaurant(AdminListingItem restaurant) async {
    final response = await _placesService.reviewPlace(placeId: restaurant.id, status: "approved");
    if (response is Map && response["result"] == true) {
      await loadRestaurants();
    } else {
      Get.snackbar("Couldn't approve", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> rejectRestaurant(AdminListingItem restaurant, {String? note}) async {
    final response = await _placesService.reviewPlace(placeId: restaurant.id, status: "rejected", reviewNote: note);
    if (response is Map && response["result"] == true) {
      await loadRestaurants();
    } else {
      Get.snackbar("Couldn't reject", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> editRestaurant(AdminListingItem restaurant, Map<String, String> values) async {
    final data = <String, dynamic>{
      "name_en": values["name_en"],
      "description_en": values["description_en"],
      "address_en": values["address_en"],
      "province": values["province"],
      "entry_fee": values["entry_fee"],
      "opening_hours": values["opening_hours"],
    };
    final response = await _placesService.updatePlace(restaurant.id, data);
    if (response is Map && response["result"] == true) {
      await loadRestaurants();
    } else {
      Get.snackbar("Couldn't save changes", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> deleteRestaurant(AdminListingItem restaurant) async {
    final response = await _placesService.deletePlace(restaurant.id);
    if (response is Map && response["result"] == true) {
      restaurants.removeWhere((r) => r.id == restaurant.id);
    } else {
      Get.snackbar("Couldn't delete", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  // ====================== COMPANIES (real /admin/companies data) ======================
  final RxList<AdminCompany> companies = <AdminCompany>[].obs;
  final isLoadingCompanies = false.obs;

  static const _companyColorCycle = [
    AdminColors.primary,
    AdminColors.purple,
    AdminColors.green,
    AdminColors.amber,
    AdminColors.red,
    AdminColors.teal,
  ];

  String _initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    final parts = trimmed.split(RegExp(r"\s+"));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _formatJoined(String? isoDate) {
    if (isoDate == null || isoDate.length < 10) return "";
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return isoDate.substring(0, 10);
    }
  }

  AdminCompany _companyFromJson(Map<String, dynamic> json, int index) {
    final name = (json["name"] ?? "").toString();
    return AdminCompany(
      id: (json["id"] ?? "").toString(),
      name: name,
      initials: _initialsFor(name),
      color: _companyColorCycle[index % _companyColorCycle.length],
      email: (json["email"] ?? "").toString(),
      phone: (json["phone"] ?? "").toString(),
      businessType: (json["business_type"] ?? "").toString(),
      businessTypeColor: _companyColorCycle[index % _companyColorCycle.length],
      location: (json["address"] ?? "").toString(),
      places: (json["places"] is int) ? json["places"] as int : int.tryParse("${json["places"]}") ?? 0,
      joined: _formatJoined(json["created_at"]?.toString()),
      suspended: json["suspended"] == true,
    );
  }

  /// Loads every registered company account from the backend — this is
  /// the real "Manage Users" data source, replacing the old mock list.
  Future<void> loadCompanies() async {
    isLoadingCompanies.value = true;
    final response = await _authService.getCompaniesService();
    if (response is Map && response["result"] == true) {
      final items = (response["data"]?["items"] as List?) ?? [];
      companies.assignAll([
        for (int i = 0; i < items.length; i++) _companyFromJson(Map<String, dynamic>.from(items[i]), i),
      ]);
    } else {
      Get.snackbar("Couldn't load companies", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
    isLoadingCompanies.value = false;
  }

  Future<void> editCompany(AdminCompany company, Map<String, String> values) async {
    final data = <String, dynamic>{
      "name": values["name"],
      "email": values["email"],
      "phone": values["phone"],
      "business_type": values["businessType"],
      "address": values["location"],
    };
    final response = await _authService.updateCompanyService(company.id, data);
    if (response is Map && response["result"] == true) {
      await loadCompanies();
    } else {
      Get.snackbar("Couldn't save changes", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> suspendCompany(AdminCompany company) async {
    final response = await _authService.suspendCompanyService(company.id);
    if (response is Map && response["result"] == true) {
      await loadCompanies();
    } else {
      Get.snackbar("Couldn't update status", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

  Future<void> deleteCompany(AdminCompany company) async {
    final response = await _authService.deleteCompanyService(company.id);
    if (response is Map && response["result"] == true) {
      companies.removeWhere((c) => c.id == company.id);
    } else {
      Get.snackbar("Couldn't remove company", (response is Map ? response["message"] : null)?.toString() ?? "Please try again");
    }
  }

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
    loadHotels();
    loadPackages();
    loadRestaurants();
    loadCompanies();
  }
}