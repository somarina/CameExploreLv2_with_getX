import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_screen_controller.dart';
import '../models/admin_colors.dart';
import 'pages/admin_analytics_page.dart';
import 'pages/admin_approvals_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_manage_listing_page.dart';
import 'pages/admin_manage_places_page.dart';
import 'pages/admin_manage_users_page.dart';
import 'pages/admin_settings_page.dart';
import 'widgets/admin_shared_widgets.dart';
import 'widgets/admin_sidebar.dart';

class AdminScreenView extends GetView<AdminScreenController> {
  const AdminScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AdminColors.background,
      endDrawer: isMobile
          ? Drawer(
              backgroundColor: AdminColors.surfaceLight,
              child: AdminSidebar(controller: controller),
            )
          : null,
      body: isMobile
          ? _buildMobileLayout(context)
          : Row(
              children: [
                SizedBox(
                  width: 264,
                  child: AdminSidebar(controller: controller),
                ),
                Expanded(
                  child: Obx(
                    () => _buildPageContent(controller.currentSection.value),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AdminColors.surfaceLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'CamExplore Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.menu, color: AdminColors.textPrimary),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() => _buildPageContent(controller.currentSection.value)),
        ),
      ],
    );
  }

  Widget _buildPageContent(AdminSection section) {
    switch (section) {
      case AdminSection.dashboard:
        return AdminDashboardPage(controller: controller);
      case AdminSection.managePlaces:
        return AdminManagePlacesPage(controller: controller);
      case AdminSection.manageHotels:
        return AdminManageListingPage(
          controller: controller,
          title: 'manage_hotels'.tr,
          subtitle: 'manage_hotels_subtitle'.tr,
          searchHint: 'search_name_owner_province'.tr,
          typeColumnLabel: 'col_rating'.tr,
          locationColumnLabel: 'col_province'.tr,
          priceColumnLabel: 'col_price'.tr,
          exportSheetName: 'Hotels',
          items: controller.hotels,
          isLoading: controller.isLoadingHotels,
          onApprove: controller.approveHotel,
          onReject: (item, reason) => controller.rejectHotel(item, note: reason),
          onDelete: controller.deleteHotel,
          onEdit: controller.editHotel,
          editFieldsBuilder: (item) => [
            AdminEditField(key: 'name_en', label: 'field_name'.tr, initialValue: item.name),
            AdminEditField(key: 'address_en', label: 'field_address'.tr, initialValue: item.subtitle, maxLines: 2),
            AdminEditField(key: 'province', label: 'col_province'.tr, initialValue: item.location),
            AdminEditField(
              key: 'star_rating',
              label: 'field_star_rating'.tr,
              initialValue: item.typeLabel.replaceAll(RegExp(r'[^0-9]'), ''),
              keyboardType: TextInputType.number,
            ),
          ],
        );
      case AdminSection.managePackages:
        return AdminManageListingPage(
          controller: controller,
          title: 'manage_packages'.tr,
          subtitle: 'manage_packages_subtitle'.tr,
          searchHint: 'search_name_owner_province'.tr,
          typeColumnLabel: 'col_duration'.tr,
          locationColumnLabel: 'col_province'.tr,
          priceColumnLabel: 'col_price'.tr,
          exportSheetName: 'Packages',
          items: controller.packages,
          isLoading: controller.isLoadingPackages,
          onApprove: controller.approvePackage,
          onReject: (item, reason) => controller.rejectPackage(item, note: reason),
          onDelete: controller.deletePackage,
          onEdit: controller.editPackage,
          editFieldsBuilder: (item) => [
            AdminEditField(key: 'name_en', label: 'field_name'.tr, initialValue: item.name),
            AdminEditField(key: 'description_en', label: 'field_description'.tr, initialValue: item.subtitle, maxLines: 3),
            AdminEditField(
              key: 'duration_days',
              label: 'field_duration_days'.tr,
              initialValue: item.typeLabel.replaceAll(RegExp(r'[^0-9]'), ''),
              keyboardType: TextInputType.number,
            ),
            AdminEditField(
              key: 'price_per_person',
              label: 'field_price_per_person'.tr,
              initialValue: item.price.replaceAll(RegExp(r'[^0-9.]'), ''),
              keyboardType: TextInputType.number,
            ),
          ],
        );
      case AdminSection.manageRestaurants:
        return AdminManageListingPage(
          controller: controller,
          title: 'manage_restaurants'.tr,
          subtitle: 'manage_restaurants_subtitle'.tr,
          searchHint: 'search_name_owner_province'.tr,
          typeColumnLabel: 'col_category'.tr,
          locationColumnLabel: 'col_province'.tr,
          priceColumnLabel: 'col_fee'.tr,
          exportSheetName: 'Restaurants',
          items: controller.restaurants,
          isLoading: controller.isLoadingRestaurants,
          onApprove: controller.approveRestaurant,
          onReject: (item, reason) => controller.rejectRestaurant(item, note: reason),
          onDelete: controller.deleteRestaurant,
          onEdit: controller.editRestaurant,
          editFieldsBuilder: (item) => [
            AdminEditField(key: 'name_en', label: 'field_name'.tr, initialValue: item.name),
            AdminEditField(key: 'description_en', label: 'field_description'.tr, initialValue: item.subtitle, maxLines: 3),
            AdminEditField(key: 'address_en', label: 'field_address'.tr, initialValue: item.subtitle, maxLines: 2),
            AdminEditField(key: 'province', label: 'col_province'.tr, initialValue: item.location),
            AdminEditField(key: 'entry_fee', label: 'field_entry_fee'.tr, initialValue: item.price),
            AdminEditField(key: 'opening_hours', label: 'field_opening_hours'.tr, initialValue: ''),
          ],
        );
      case AdminSection.manageUsers:
        return AdminManageUsersPage(controller: controller);
      case AdminSection.approvals:
        return AdminApprovalsPage(controller: controller);
      case AdminSection.analytics:
        return AdminAnalyticsPage(controller: controller);
      case AdminSection.settings:
        return AdminSettingsPage(controller: controller);
    }
  }
}
