import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/theme_controller.dart';
import '../../../core/api/services/dashboard_places_service.dart';
import '../../../routes/app_pages.dart';

/// A single row in the "Popular Destinations" panel.
class PopularDestination {
  final String name;
  final String location;
  final String imageAsset;
  final double rating;
  final int views;
  final String tag;
  final String priceLabel; // e.g. "$37 entry fee" or "Free entry fee"

  const PopularDestination({
    required this.name,
    required this.location,
    required this.imageAsset,
    required this.rating,
    required this.views,
    required this.tag,
    required this.priceLabel,
  });
}

/// A single row in the "Recent Activity" feed.
class ActivityItem {
  final String text; // plain text, bold segments handled by the view
  final String boldPart;
  final String timeAgo;
  final Color dotColor;

  const ActivityItem({
    required this.text,
    required this.boldPart,
    required this.timeAgo,
    required this.dotColor,
  });
}

/// A single row in "My Places" once the company has submitted places.
class MyPlace {
  final String id;
  final String name;
  final String status; // Approved / Pending / Rejected
  final String imageAsset;
  final String category;
  final String province;
  final String description;
  final double entryFee;

  const MyPlace({
    this.id = "",
    required this.name,
    required this.status,
    required this.imageAsset,
    this.category = "",
    this.province = "",
    this.description = "",
    this.entryFee = 0,
  });

  /// Builds from a `/places` API item — backend status is lowercase
  /// ("pending"/"approved"/"rejected"), the UI shows it capitalized.
  factory MyPlace.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json["status"] ?? "pending").toString();
    final fee = json["entry_fee"];
    return MyPlace(
      id: (json["id"] ?? "").toString(),
      name: (json["name_en"] ?? json["name"] ?? "").toString(),
      status: rawStatus.isEmpty ? "Pending" : (rawStatus[0].toUpperCase() + rawStatus.substring(1)),
      imageAsset: (json["image_url"] != null && json["image_url"].toString().isNotEmpty)
          ? json["image_url"].toString()
          : "assets/images/angkor_wat.png",
      category: (json["category"] ?? "").toString(),
      province: (json["province"] ?? "").toString(),
      description: (json["description_en"] ?? json["description"] ?? "").toString(),
      entryFee: fee == null ? 0 : (double.tryParse(fee.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0),
    );
  }
}

class CompanyScreenController extends GetxController {
  // Shared app-wide theme state — same instance every other screen reads from.
  final ThemeController themeController = Get.find<ThemeController>();
  final DashboardPlacesService _placesService = DashboardPlacesService();

  // ── Sidebar / navigation ────────────────────────────────────────
  // 0 = Dashboard, 1 = My Places, 2 = Add Place, 3 = Settings
  final selectedNavIndex = 0.obs;
  final isSidebarOpen = false.obs; // used for the mobile drawer

  // ── My Places page state ────────────────────────────────────────
  final isGridView = true.obs;
  final placesSearchController = TextEditingController();
  final placesSearchQuery = "".obs;

  List<MyPlace> get filteredMyPlaces {
    final q = placesSearchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return myPlaces;
    return myPlaces
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.province.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  // ── Add Place page state ────────────────────────────────────────
  static const categoryOptions = [
    "Temple",
    "Beach",
    "Museum",
    "Nature & Park",
    "Historical Site",
    "Waterfall",
    "Mountain",
    "Cultural Site",
    "Adventure",
    "Other",
  ];

  final addPlaceSubmitted = false.obs; // shows the success screen when true
  final isSubmittingPlace = false.obs;

  /// Resets the Add Place form back to its empty state (used by "Add Another").
  void resetAddPlaceForm() => addPlaceSubmitted.value = false;

  /// Called by the Add Place form once validation passes.
  /// Submits to the real backend — companies land as "pending" until an
  /// admin approves/rejects it from the Approvals screen.
  Future<void> submitNewPlace({
    required String name,
    String? nameKm,
    required String category,
    required String province,
    required String description,
    String? descriptionKm,
    String? addressEn,
    String? openingHours,
    String? phoneNum,
    List<String>? tags,
    double? latitude,
    double? longitude,
    required double entryFee,
    List<XFile>? images,
  }) async {
    isSubmittingPlace.value = true;

    final response = await _placesService.submitPlace(
      nameEn: name,
      nameKm: (nameKm != null && nameKm.isNotEmpty) ? nameKm : null,
      category: category,
      province: province,
      descriptionEn: description,
      descriptionKm: (descriptionKm != null && descriptionKm.isNotEmpty) ? descriptionKm : null,
      addressEn: (addressEn != null && addressEn.isNotEmpty) ? addressEn : null,
      openingHours: (openingHours != null && openingHours.isNotEmpty) ? openingHours : null,
      phoneNum: (phoneNum != null && phoneNum.isNotEmpty) ? phoneNum : null,
      tags: (tags != null && tags.isNotEmpty) ? tags : null,
      latitude: latitude,
      longitude: longitude,
      entryFee: entryFee > 0 ? "\$${entryFee.toStringAsFixed(entryFee % 1 == 0 ? 0 : 2)}" : "Free",
    );

    if (response is Map && response["result"] == true) {
      final newPlace = response["data"];
      final newPlaceId = (newPlace is Map ? newPlace["id"] : null)?.toString();

      // The place now exists — upload the picked images against its real
      // ID (the backend's upload endpoint requires the target to exist
      // first), then save the returned Cloudinary URLs onto it.
      if (newPlaceId != null && newPlaceId.isNotEmpty && images != null && images.isNotEmpty) {
        final uploadResponse = await _placesService.uploadPlaceImages(
          placeId: newPlaceId,
          images: images,
        );
        if (uploadResponse is Map && uploadResponse["result"] == true) {
          final urls = ((uploadResponse["data"]?["images"] as List?) ?? [])
              .map((e) => e.toString())
              .toList();
          if (urls.isNotEmpty) {
            await _placesService.updatePlaceImages(
              placeId: newPlaceId,
              imageUrl: urls.first,
              images: urls,
            );
          }
        } else {
          Get.snackbar(
            "Place submitted, but image upload failed",
            (uploadResponse is Map ? uploadResponse["message"] : null)?.toString() ??
                "You can try re-adding photos by editing this place later.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      isSubmittingPlace.value = false;
      await _loadMyPlaces();
      addPlaceSubmitted.value = true;
    } else {
      isSubmittingPlace.value = false;
      final message = (response is Map ? response["message"] : null) ?? "Could not submit this place";
      Get.snackbar("Submission failed", message.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Refreshes "My Places" (and the stat cards) from the backend.
  Future<void> _loadMyPlaces() async {
    final response = await _placesService.getMyPlaces();
    if (response is Map && response["result"] == true) {
      final items = (response["data"]?["items"] as List?) ?? [];
      myPlaces.assignAll(items.map((e) => MyPlace.fromJson(Map<String, dynamic>.from(e))));
      totalPlaces.value = myPlaces.length;
      pendingPlaces.value = myPlaces.where((p) => p.status == "Pending").length;
      approvedPlaces.value = myPlaces.where((p) => p.status == "Approved").length;
      rejectedPlaces.value = myPlaces.where((p) => p.status == "Rejected").length;
    }
  }

  // ── Company profile (read from what login stored) ──────────────
  final companyName = "Company".obs;
  final companyEmail = "".obs;

  // ── Stat cards ───────────────────────────────────────────────────
  final totalPlaces = 0.obs;
  final pendingPlaces = 0.obs;
  final approvedPlaces = 0.obs;
  final rejectedPlaces = 0.obs;

  // ── Header ───────────────────────────────────────────────────────
  final searchController = TextEditingController();
  final notificationCount = 0.obs;

  // ── Panels ───────────────────────────────────────────────────────
  final popularDestinations = <PopularDestination>[].obs;
  final recentActivity = <ActivityItem>[].obs;
  final myPlaces = <MyPlace>[].obs;

  final isLoadingDashboard = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCompanyProfile();
    loadDashboard();
  }

  void _loadCompanyProfile() {
    final box = GetStorage();
    final storedName = box.read("dashboard_admin_name");
    final storedEmail = box.read("dashboard_email");
    companyName.value = (storedName != null && storedName.toString().isNotEmpty)
        ? storedName.toString()
        : "Company";
    companyEmail.value = storedEmail?.toString() ?? "";
  }

  /// Pulls dashboard stats + panel data.
  /// "My Places" and the stat cards come from the real /places/mine
  /// endpoint; the panels below are still placeholder content.
  /// TODO: replace popularDestinations/recentActivity with real API calls.
  Future<void> loadDashboard() async {
    isLoadingDashboard.value = true;

    notificationCount.value = 0;

    popularDestinations.assignAll(const [
      PopularDestination(
        name: "Angkor Wat Temple Complex",
        location: "Siem Reap",
        imageAsset: "assets/images/angkor_wat.png",
        rating: 4.4,
        views: 312,
        tag: "Temple",
        priceLabel: "\$37 entry fee",
      ),
      PopularDestination(
        name: "Koh Rong Paradise Beach",
        location: "Preah Sihanouk",
        imageAsset: "assets/images/angkor_wat.png",
        rating: 4.5,
        views: 244,
        tag: "Beach",
        priceLabel: "Free entry fee",
      ),
    ]);

    recentActivity.assignAll(const [
      ActivityItem(
        text: "Place approved: ",
        boldPart: "Angkor Wat Temple Complex",
        timeAgo: "2h ago",
        dotColor: Color(0xFF22C55E),
      ),
      ActivityItem(
        text: "Submitted: ",
        boldPart: "Phnom Penh Culture Tour",
        timeAgo: "5h ago",
        dotColor: Color(0xFFF59E0B),
      ),
    ]);

    await _loadMyPlaces();

    isLoadingDashboard.value = false;
  }

  Future<void> refreshDashboard() => loadDashboard();

  // ── Navigation ───────────────────────────────────────────────────
  void selectNav(int index) => selectedNavIndex.value = index;

  void toggleSidebar() => isSidebarOpen.value = !isSidebarOpen.value;

  void goToAddPlace() {
    addPlaceSubmitted.value = false;
    selectedNavIndex.value = 2;
  }

  void goToMyPlaces() => selectedNavIndex.value = 1;

  void goToSettings() => selectedNavIndex.value = 3;

  void goToDashboard() => selectedNavIndex.value = 0;

  void logout() {
    final box = GetStorage();
    box.remove("dashboard_token");
    box.remove("dashboard_admin_name");
    box.remove("dashboard_active_role");
    box.remove("dashboard_email");

    // TODO: swap in your actual login route constant if this differs.
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }

  @override
  void onClose() {
    searchController.dispose();
    placesSearchController.dispose();
    super.onClose();
  }
}