// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/company_screen_controller.dart';

bool _isKhmerText(String text) => RegExp(r'[\u1780-\u17FF]').hasMatch(text);

TextStyle companyFont(
  String text, {
  required Color color,
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return _isKhmerText(text)
      ? GoogleFonts.googleSans(color: color, fontSize: fontSize, fontWeight: fontWeight)
      : GoogleFonts.spaceGrotesk(color: color, fontSize: fontSize, fontWeight: fontWeight);
}

/// Top bar reused by "My Places", "Add Place" and "Settings":
/// title + subtitle on the left, optional search field, bell, avatar on the right.
class CompanyTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final CompanyScreenController controller;
  final bool showSearch;
  final Widget? trailing; // e.g. the "Add Place" button
  final bool isDesktop;
  final bool isDark;
  final Color titleColor;
  final Color subtitleColor;
  final Color mutedColor;
  final Color cardBg;
  final Color cardBorder;
  final Color primaryColor;

  const CompanyTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.isDesktop,
    required this.isDark,
    required this.titleColor,
    required this.subtitleColor,
    required this.mutedColor,
    required this.cardBg,
    required this.cardBorder,
    required this.primaryColor,
    this.showSearch = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: companyFont(title, color: titleColor, fontSize: isDesktop ? 26 : 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: companyFont("x", color: subtitleColor, fontSize: 13)),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null) ...[trailing!, const SizedBox(width: 12)],
        _bell(),
        const SizedBox(width: 12),
        _avatar(),
      ],
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  icon: Icon(Icons.menu_rounded, color: titleColor),
                ),
              ),
              Expanded(child: titleBlock),
            ],
          ),
          const SizedBox(height: 12),
          if (showSearch) ...[_searchField(), const SizedBox(height: 12)],
          Row(children: [if (trailing != null) Expanded(child: trailing!), const Spacer(), _bell(), const SizedBox(width: 12), _avatar()]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleBlock),
        if (showSearch) ...[
          SizedBox(width: 260, child: _searchField()),
          const SizedBox(width: 14),
        ],
        actions,
      ],
    );
  }

  Widget _searchField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 19, color: mutedColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: companyFont("x", color: titleColor, fontSize: 13.5),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: "Search anything...",
                hintStyle: companyFont("x", color: mutedColor, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bell() {
    return Obx(() {
      return InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.05),
              child: Icon(Icons.notifications_outlined, size: 19, color: isDark ? Colors.white : Colors.black87),
            ),
            if (controller.notificationCount.value > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _avatar() {
    return Obx(() {
      final name = controller.companyName.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: primaryColor,
            child: Text(
              name.isNotEmpty ? name.characters.first.toUpperCase() : "C",
              style: companyFont("C", color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: companyFont(name, color: titleColor, fontSize: 13, fontWeight: FontWeight.w600)),
                Text("Company", style: companyFont("Company", color: mutedColor, fontSize: 11.5)),
              ],
            ),
          ],
        ],
      );
    });
  }
}
