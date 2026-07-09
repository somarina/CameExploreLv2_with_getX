import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import 'admin_shared_widgets.dart';

/// Top bar: page title + subtitle on the left, search + bell + avatar on the right.
class AdminTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final AdminScreenController controller;
  final Widget? trailingAction; // e.g. "Review Requests" button on Dashboard

  const AdminTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth < 1200;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _IconBubble(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _AdminAvatar(controller: controller, isCompact: true),
            ],
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (trailingAction != null) trailingAction!,
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(height: 46, child: const AdminSearchField()),
              ),
              const SizedBox(width: 12),
              _IconBubble(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _AdminAvatar(controller: controller),
            ],
          ),
        ],
      );
    }

    // Desktop
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 14, color: AdminColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              const Expanded(child: AdminSearchField()),
              const SizedBox(width: 14),
              if (trailingAction != null) ...[trailingAction!, const SizedBox(width: 14)],
              _IconBubble(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: () {},
              ),
              const SizedBox(width: 14),
              _AdminAvatar(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;
  const _IconBubble({required this.icon, required this.onTap, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AdminColors.background,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 21, color: AdminColors.textPrimary)),
            if (showDot)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AdminColors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  final AdminScreenController controller;
  final bool isCompact;
  const _AdminAvatar({required this.controller, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: AdminColors.primary,
        child: Obx(() => Text(
              controller.adminName.value.isNotEmpty ? controller.adminName.value[0].toUpperCase() : 'A',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            )),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: AdminColors.primary,
          child: Obx(() => Text(
                controller.adminName.value.isNotEmpty ? controller.adminName.value[0].toUpperCase() : 'A',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
              )),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  controller.adminName.value,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                )),
            Obx(() => Text(
                  controller.adminRole.value,
                  style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary),
                )),
          ],
        ),
      ],
    );
  }
}

/// Solid primary button, e.g. "Review Requests  3"
class AdminPrimaryButton extends StatelessWidget {
  final String label;
  final int? count;
  final IconData? icon;
  final VoidCallback onTap;

  const AdminPrimaryButton({super.key, required this.label, required this.onTap, this.count, this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.primary,
      borderRadius: BorderRadius.circular(AdminRadii.chip),
      child: InkWell(
        borderRadius: BorderRadius.circular(AdminRadii.chip),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
              Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                  child: Text('$count', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
