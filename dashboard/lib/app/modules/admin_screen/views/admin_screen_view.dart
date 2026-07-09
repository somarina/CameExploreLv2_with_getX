import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_screen_controller.dart';
import '../models/admin_colors.dart';
import 'pages/admin_analytics_page.dart';
import 'pages/admin_approvals_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_manage_places_page.dart';
import 'pages/admin_manage_users_page.dart';
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
                  child: Obx(() => _buildPageContent(controller.currentSection.value)),
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
                icon: const Icon(Icons.menu, color: AdminColors.textPrimary),
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
      case AdminSection.manageUsers:
        return AdminManageUsersPage(controller: controller);
      case AdminSection.approvals:
        return AdminApprovalsPage(controller: controller);
      case AdminSection.analytics:
        return AdminAnalyticsPage(controller: controller);
    }
  }
}
