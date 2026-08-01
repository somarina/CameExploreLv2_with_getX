import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../controllers/theme_controller.dart';
import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';

class AdminSidebar extends StatelessWidget {
  final AdminScreenController controller;
  const AdminSidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Container(
      width: 264,
      color: AdminColors.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Logo / brand ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CamExplore',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
                    ),
                    Text(
                      'Admin Panel',
                      style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AdminColors.border),

          // ---------- Nav items ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'ADMINISTRATION',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AdminColors.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Obx(() => Column(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: controller.currentSection.value == AdminSection.dashboard,
                onTap: () => controller.goTo(AdminSection.dashboard),
              ),
              _NavItem(
                icon: Icons.place_outlined,
                label: 'Manage Places',
                selected: controller.currentSection.value == AdminSection.managePlaces,
                onTap: () => controller.goTo(AdminSection.managePlaces),
              ),
              _NavItem(
                icon: Icons.people_outline,
                label: 'Manage Users',
                selected: controller.currentSection.value == AdminSection.manageUsers,
                onTap: () => controller.goTo(AdminSection.manageUsers),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                label: 'Approvals',
                selected: controller.currentSection.value == AdminSection.approvals,
                badgeCount: controller.pendingCount,
                onTap: () => controller.goTo(AdminSection.approvals),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                selected: controller.currentSection.value == AdminSection.analytics,
                onTap: () => controller.goTo(AdminSection.analytics),
              ),
            ],
          )),

          const Spacer(),
          const Divider(height: 1, color: AdminColors.border),
          const SizedBox(height: 8),

          _NavItem(icon: Icons.settings_outlined, label: 'Settings', selected: false, onTap: () {}),

          Obx(() => _NavItem(
            icon: themeController.isDarkMode.value ? Icons.dark_mode : Icons.dark_mode_outlined,
            label: 'Dark Mode',
            selected: false,
            onTap: themeController.toggleTheme,
            trailing: Switch.adaptive(
              value: themeController.isDarkMode.value,
              activeColor: AdminColors.primary,
              onChanged: (_) => themeController.toggleTheme(),
            ),
          )),
          _NavItem(
            icon: Icons.logout,
            label: 'Logout',
            selected: false,
            onTap: () => _showLogoutDialog(context, controller),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AdminScreenController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: AdminColors.surfaceLight.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Lottie.asset(
                            'assets/icons/logout.json',
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Logout',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Are you sure you want to log out of your account?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: AdminColors.background.withOpacity(0.6),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.logout();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AdminColors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text('Logout', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Widget? trailing;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AdminColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: selected ? Colors.white : AdminColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : AdminColors.textPrimary,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : AdminColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? AdminColors.primary : Colors.white,
                      ),
                    ),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}