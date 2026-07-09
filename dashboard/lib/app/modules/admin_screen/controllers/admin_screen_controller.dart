import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/admin_colors.dart';
import '../models/admin_models.dart';

/// Which section of the dashboard is currently visible.
enum AdminSection { dashboard, managePlaces, manageUsers, approvals, analytics }

class AdminScreenController extends GetxController {
  // ====================== NAVIGATION STATE ======================
  final Rx<AdminSection> currentSection = AdminSection.dashboard.obs;

  void goTo(AdminSection section) => currentSection.value = section;

  // ====================== ADMIN PROFILE (mock for now) ======================
  final adminName = 'somarina'.obs;
  final adminRole = 'Admin'.obs;

  // ====================== TOP-LEVEL STATS (mock for now) ======================
  // TODO: replace with real counts from GET /api/dashboard/auth/admin + places API
  int get totalPlaces => places.length;
  int get pendingCount => places.where((p) => p.status == PlaceStatus.pending).length;
  int get approvedCount => places.where((p) => p.status == PlaceStatus.approved).length;
  int get rejectedCount => places.where((p) => p.status == PlaceStatus.rejected).length;
  int get totalCompanies => companies.length;

  // ====================== MOCK: PLACES ======================
  final RxList<AdminPlace> places = <AdminPlace>[
    AdminPlace(
      name: 'Banteay Srei Temple',
      subtitle: 'The citadel of the women',
      company: 'Angkor Tourism Co.',
      category: 'Temple',
      province: 'Siem Reap',
      fee: '\$37',
      submittedDate: 'Apr 28, 2026',
      status: PlaceStatus.pending,
      imageColor: AdminColors.primary,
    ),
    AdminPlace(
      name: 'Koh Rong Paradise Beach',
      subtitle: 'Crystal clear waters',
      company: 'Coastal Adventures',
      category: 'Beach',
      province: 'Preah Sihanouk',
      fee: 'Free',
      submittedDate: 'Apr 29, 2026',
      status: PlaceStatus.pending,
      imageColor: AdminColors.teal,
    ),
    AdminPlace(
      name: 'Royal Palace Museum',
      subtitle: 'Historic royal residence',
      company: 'Heritage Travel',
      category: 'Cultural Site',
      province: 'Phnom Penh',
      fee: '\$10',
      submittedDate: 'Apr 25, 2026',
      status: PlaceStatus.approved,
      imageColor: AdminColors.amber,
    ),
    AdminPlace(
      name: 'Kampot Restaurant',
      subtitle: 'Kampot Restaurant',
      company: 'somarina',
      category: 'Historical Monument',
      province: 'Kam Pot',
      fee: '\$12',
      submittedDate: 'Jun 23, 2026',
      status: PlaceStatus.pending,
      imageColor: AdminColors.purple,
    ),
  ].obs;

  void approvePlace(AdminPlace place) {
    final index = places.indexOf(place);
    if (index == -1) return;
    places[index] = AdminPlace(
      name: place.name,
      subtitle: place.subtitle,
      company: place.company,
      category: place.category,
      province: place.province,
      fee: place.fee,
      submittedDate: place.submittedDate,
      status: PlaceStatus.approved,
      imageColor: place.imageColor,
    );
  }

  void rejectPlace(AdminPlace place) {
    final index = places.indexOf(place);
    if (index == -1) return;
    places[index] = AdminPlace(
      name: place.name,
      subtitle: place.subtitle,
      company: place.company,
      category: place.category,
      province: place.province,
      fee: place.fee,
      submittedDate: place.submittedDate,
      status: PlaceStatus.rejected,
      imageColor: place.imageColor,
    );
  }

  void deletePlace(AdminPlace place) => places.remove(place);

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
  }
}
