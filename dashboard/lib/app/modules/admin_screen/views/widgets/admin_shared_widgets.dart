import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_colors.dart';

/// Top summary card, e.g. "Total Places / 4 / +8%"
class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminRadii.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              _Badge(text: badgeText, color: badgeColor, bg: badgeBg),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Badge({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdminRadii.chip)),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// A white rounded card container used to wrap charts/tables/sections.
class AdminSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminRadii.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: child,
    );
  }
}

/// Section header with title + subtitle, optionally a trailing widget.
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small colored status pill, e.g. "Pending" / "Approved" / "Rejected"
class AdminStatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const AdminStatusChip({super.key, required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdminRadii.chip)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(text, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// Reusable search field used across pages.
class AdminSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const AdminSearchField({super.key, this.hint = 'Search anything...', this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(AdminRadii.chip),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AdminColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hint,
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AdminColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
