// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../controllers/company_screen_controller.dart';
import 'pages/company_add_place_page.dart';
import 'pages/company_my_places_page.dart';
import 'pages/company_settings_page.dart';

class CompanyScreenView extends GetView<CompanyScreenController> {
  const CompanyScreenView({super.key});

  static const primaryColor = Color(0xFF00C17C);
  static const _blue = Color(0xFF3B82F6);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.themeController.isDarkMode.value;

      final Color pageBg = isDark
          ? const Color(0xFF031024)
          : const Color(0xFFF8FAFC);
      final Color sidebarBg = isDark ? const Color(0xFF040F22) : Colors.white;
      final Color cardBg = isDark ? const Color(0xFF0B1B33) : Colors.white;
      final Color cardBorder = isDark ? Colors.white12 : Colors.black12;
      final Color titleColor = isDark ? Colors.white : Colors.black87;
      final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;
      final Color mutedColor = isDark ? Colors.white54 : Colors.black45;

      return Scaffold(
        backgroundColor: pageBg,
        drawer: LayoutBuilder(
          builder: (context, constraints) => Drawer(
            backgroundColor: sidebarBg,
            child: SafeArea(
              child: _sidebarContent(
                context,
                isDark: isDark,
                sidebarBg: sidebarBg,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                mutedColor: mutedColor,
              ),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 980;

            return Row(
              children: [
                if (isDesktop)
                  SizedBox(
                    width: 280,
                    child: Container(
                      color: sidebarBg,
                      child: SafeArea(
                        child: _sidebarContent(
                          context,
                          isDark: isDark,
                          sidebarBg: sidebarBg,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                          mutedColor: mutedColor,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SafeArea(
                    child: Obx(() {
                      switch (controller.selectedNavIndex.value) {
                        case 1:
                          return CompanyMyPlacesPage(
                            controller: controller,
                            isDesktop: isDesktop,
                            isDark: isDark,
                            pageBg: pageBg,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            mutedColor: mutedColor,
                            primaryColor: primaryColor,
                            accentColor: _blue,
                          );
                        case 2:
                          return CompanyAddPlacePage(
                            controller: controller,
                            isDesktop: isDesktop,
                            isDark: isDark,
                            pageBg: pageBg,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            mutedColor: mutedColor,
                            primaryColor: primaryColor,
                            accentColor: _blue,
                          );
                        case 3:
                          return CompanySettingsPage(
                            controller: controller,
                            isDesktop: isDesktop,
                            isDark: isDark,
                            pageBg: pageBg,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            mutedColor: mutedColor,
                            primaryColor: primaryColor,
                            redColor: _red,
                          );
                        default:
                          return RefreshIndicator(
                            color: primaryColor,
                            onRefresh: controller.refreshDashboard,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isDesktop ? 28 : 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _topHeader(
                                    context: context,
                                    isDesktop: isDesktop,
                                    isDark: isDark,
                                    cardBg: cardBg,
                                    cardBorder: cardBorder,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    mutedColor: mutedColor,
                                  ),
                                  const SizedBox(height: 20),
                                  _statsGrid(
                                    context: context,
                                    isDesktop: isDesktop,
                                    cardBg: cardBg,
                                    cardBorder: cardBorder,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                  ),
                                  const SizedBox(height: 20),
                                  isDesktop
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child:
                                                  _popularDestinationsPanel(
                                                    cardBg: cardBg,
                                                    cardBorder: cardBorder,
                                                    titleColor: titleColor,
                                                    subtitleColor:
                                                        subtitleColor,
                                                    mutedColor: mutedColor,
                                                    isDark: isDark,
                                                  ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _quickActionsPanel(
                                                cardBg: cardBg,
                                                cardBorder: cardBorder,
                                                titleColor: titleColor,
                                                subtitleColor: subtitleColor,
                                                isDark: isDark,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            _popularDestinationsPanel(
                                              cardBg: cardBg,
                                              cardBorder: cardBorder,
                                              titleColor: titleColor,
                                              subtitleColor: subtitleColor,
                                              mutedColor: mutedColor,
                                              isDark: isDark,
                                            ),
                                            const SizedBox(height: 16),
                                            _quickActionsPanel(
                                              cardBg: cardBg,
                                              cardBorder: cardBorder,
                                              titleColor: titleColor,
                                              subtitleColor: subtitleColor,
                                              isDark: isDark,
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 16),
                                  isDesktop
                                      ? IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: _recentActivityPanel(
                                                  cardBg: cardBg,
                                                  cardBorder: cardBorder,
                                                  titleColor: titleColor,
                                                  subtitleColor: subtitleColor,
                                                  mutedColor: mutedColor,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _myPlacesPanel(
                                                  cardBg: cardBg,
                                                  cardBorder: cardBorder,
                                                  titleColor: titleColor,
                                                  subtitleColor: subtitleColor,
                                                  mutedColor: mutedColor,
                                                  isDark: isDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            _recentActivityPanel(
                                              cardBg: cardBg,
                                              cardBorder: cardBorder,
                                              titleColor: titleColor,
                                              subtitleColor: subtitleColor,
                                              mutedColor: mutedColor,
                                            ),
                                            const SizedBox(height: 16),
                                            _myPlacesPanel(
                                              cardBg: cardBg,
                                              cardBorder: cardBorder,
                                              titleColor: titleColor,
                                              subtitleColor: subtitleColor,
                                              mutedColor: mutedColor,
                                              isDark: isDark,
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          );
                      }
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  // ── Logout confirmation (matches the admin dashboard's styled dialog) ──
  void _confirmLogout(
    BuildContext context, {
    required Color cardBg,
    required Color titleColor,
    required Color subtitleColor,
  }) {
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
                      color: cardBg.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Lottie.asset('assets/icons/logout.json', repeat: true),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Logout",
                          style: _font("Logout", color: titleColor, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Are you sure you want to log out of your account?",
                          textAlign: TextAlign.center,
                          style: _font("x", color: subtitleColor, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: (titleColor == Colors.white ? Colors.white : Colors.black).withOpacity(0.06),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: _font("Cancel", color: titleColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
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
                                  backgroundColor: _red,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  "Logout",
                                  style: _font("Logout", color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
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

  // ── Fonts (matches login/register: Khmer text gets Google Sans) ──
  bool _isKhmerText(String text) => RegExp(r'[\u1780-\u17FF]').hasMatch(text);

  TextStyle _font(
    String text, {
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return _isKhmerText(text)
        ? GoogleFonts.googleSans(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          )
        : GoogleFonts.spaceGrotesk(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          );
  }

  // ── Sidebar ────────────────────────────────────────────────────
  Widget _sidebarContent(
    BuildContext context, {
    required bool isDark,
    required Color sidebarBg,
    required Color titleColor,
    required Color subtitleColor,
    required Color mutedColor,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 980;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor,
                child: Text(
                  controller.companyName.value.isNotEmpty
                      ? controller.companyName.value.characters.first
                            .toUpperCase()
                      : "C",
                  style: _font(
                    "C",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.companyName.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _font(
                        controller.companyName.value,
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                    if (controller.companyEmail.value.isNotEmpty)
                      Text(
                        "@${controller.companyEmail.value}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _font("x", color: mutedColor, fontSize: 11.5),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            "NAVIGATION",
            style: _font(
              "NAVIGATION",
              color: mutedColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _navItem(
            context: context,
            isDesktop: isDesktop,
            icon: Icons.grid_view_rounded,
            label: "Dashboard",
            index: 0,
            titleColor: titleColor,
          ),
          _navItem(
            context: context,
            isDesktop: isDesktop,
            icon: Icons.place_outlined,
            label: "My Places",
            index: 1,
            titleColor: titleColor,
          ),
          _navItem(
            context: context,
            isDesktop: isDesktop,
            icon: Icons.add_circle_outline,
            label: "Add Place",
            index: 2,
            titleColor: titleColor,
          ),
          const Spacer(),
          Divider(color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 6),
          InkWell(
            onTap: controller.goToSettings,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 19, color: subtitleColor),
                  const SizedBox(width: 12),
                  Text(
                    "Settings",
                    style: _font(
                      "Settings",
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                size: 19,
                color: subtitleColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isDark ? "Dark Mode" : "Light Mode",
                  style: _font("x", color: subtitleColor, fontSize: 14),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: !isDark,
                  activeColor: primaryColor,
                  onChanged: (_) => controller.themeController.toggleTheme(),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _confirmLogout(
              context,
              cardBg: sidebarBg,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 19, color: _red),
                  const SizedBox(width: 12),
                  Text(
                    "Logout",
                    style: _font("Logout", color: _red, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required bool isDesktop,
    required IconData icon,
    required String label,
    required int index,
    required Color titleColor,
  }) {
    return Obx(() {
      final selected = controller.selectedNavIndex.value == index;
      return InkWell(
        onTap: () {
          controller.selectNav(index);
          if (!isDesktop) Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? Colors.white : titleColor.withOpacity(.7),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: _font(
                  label,
                  color: selected
                      ? Colors.white
                      : titleColor.withOpacity(.85),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Top header ─────────────────────────────────────────────────
  Widget _topHeader({
    required BuildContext context,
    required bool isDesktop,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
    required Color mutedColor,
  }) {
    final greetingName = controller.companyName.value.split(' ').first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDesktop)
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded, color: titleColor),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $greetingName!  👋",
                  style: _font(
                    "Hello, $greetingName!",
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Welcome back to your tourism dashboard",
                  style: _font("x", color: subtitleColor, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: controller.goToAddPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(
                "Add Place",
                style: _font(
                  "Add Place",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _circleIconButton(
                  icon: Icons.notifications_outlined,
                  isDark: isDark,
                  onTap: () {},
                ),
                if (controller.notificationCount.value > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryColor,
                  child: Text(
                    controller.companyName.value.isNotEmpty
                        ? controller.companyName.value.characters.first
                              .toUpperCase()
                        : "C",
                    style: _font(
                      "C",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.companyName.value,
                        style: _font(
                          controller.companyName.value,
                          color: titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Company",
                        style: _font("Company", color: mutedColor, fontSize: 11.5),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: CircleAvatar(
        backgroundColor: isDark
            ? Colors.white.withOpacity(.08)
            : Colors.black.withOpacity(.05),
        radius: 19,
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 19,
        ),
      ),
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────
  // Widget _statsGrid({
  //   required bool isDesktop,
  //   required Color cardBg,
  //   required Color cardBorder,
  //   required Color titleColor,
  //   required Color subtitleColor,
  // }) {
  //   final cards = [
  //     _StatCardData(
  //       "Total Places",
  //       controller.totalPlaces.value,
  //       "None yet",
  //       Icons.location_on_outlined,
  //       _blue,
  //     ),
  //     _StatCardData(
  //       "Pending",
  //       controller.pendingPlaces.value,
  //       "Awaiting review",
  //       Icons.access_time_rounded,
  //       _amber,
  //     ),
  //     _StatCardData(
  //       "Approved",
  //       controller.approvedPlaces.value,
  //       "Live & active",
  //       Icons.check_circle_outline,
  //       primaryColor,
  //     ),
  //     _StatCardData(
  //       "Rejected",
  //       controller.rejectedPlaces.value,
  //       "Needs revision",
  //       Icons.cancel_outlined,
  //       _red,
  //     ),
  //   ];

  //   final columns = isDesktop ? 4 : 2;

  //   return GridView.count(
  //     crossAxisCount: columns,
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     mainAxisSpacing: 16,
  //     crossAxisSpacing: 16,
  //     childAspectRatio: isDesktop ? 1.5 : 1.2,
  //     children: cards
  //         .map(
  //           (c) => _statCard(
  //             data: c,
  //             cardBg: cardBg,
  //             cardBorder: cardBorder,
  //             titleColor: titleColor,
  //             subtitleColor: subtitleColor,
  //           ),
  //         )
  //         .toList(),
  //   );
  // }

  Widget _statsGrid({
    required bool isDesktop,
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
    required BuildContext context,
  }) {
    final cards = [
      _StatCardData(
        "Total Places",
        controller.totalPlaces.value,
        "None yet",
        Icons.location_on_outlined,
        _blue,
      ),
      _StatCardData(
        "Pending",
        controller.pendingPlaces.value,
        "Awaiting review",
        Icons.access_time_rounded,
        _amber,
      ),
      _StatCardData(
        "Approved",
        controller.approvedPlaces.value,
        "Live & active",
        Icons.check_circle_outline,
        primaryColor,
      ),
      _StatCardData(
        "Rejected",
        controller.rejectedPlaces.value,
        "Needs revision",
        Icons.cancel_outlined,
        _red,
      ),
    ];

    final columns = isDesktop ? 4 : 2;

    // Base height for the card's content, scaled by the user's text-size setting
    // so larger accessibility font sizes don't overflow either.
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    // A little extra headroom beyond the measured content height so
    // slightly taller font metrics (Google Fonts line-height, etc.) never
    // clip the bottom of the card.
    final baseExtent = isDesktop
        ? 168.0
        : 183.0; // mobile cards are narrower -> text wraps more -> need more height
    final mainAxisExtent = baseExtent * textScale.clamp(1.0, 1.3);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: mainAxisExtent,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, i) => _statCard(
        data: cards[i],
        cardBg: cardBg,
        cardBorder: cardBorder,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
      ),
    );
  }

  Widget _statCard({
    required _StatCardData data,
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, color: data.color, size: 19),
              ),
              Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: subtitleColor.withOpacity(.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.label,
            style: _font(data.label, color: subtitleColor, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            "${data.value}",
            style: _font(
              "${data.value}",
              color: titleColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtext,
            style: _font(
              data.subtext,
              color: subtitleColor.withOpacity(.7),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared place image loader ──────────────────────────────────
  // Uploaded places carry a real image URL (image_url from the backend);
  // only the untouched demo data still points at a bundled asset. Using
  // Image.asset on a URL throws and silently breaks that place's card, so
  // uploaded photos render via Image.network instead.
  Widget _placeImage(
    String source, {
    required double width,
    required double height,
    required Color mutedColor,
    required bool isDark,
    BoxFit fit = BoxFit.cover,
  }) {
    final isNetwork = source.startsWith('http://') || source.startsWith('https://');
    final errorFallback = Container(
      width: width,
      height: height,
      color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined, size: width * 0.45, color: mutedColor),
    );
    if (isNetwork) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => errorFallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
            alignment: Alignment.center,
            child: SizedBox(
              width: width * 0.4,
              height: width * 0.4,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return Image.asset(source, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => errorFallback);
  }

  // ── Popular destinations ───────────────────────────────────────
  Widget _popularDestinationsPanel({
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
    required Color mutedColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Popular Destinations",
                      style: _font(
                        "Popular Destinations",
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Top approved places by visitor views",
                      style: _font("x", color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: controller.goToMyPlaces,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View All",
                      style: _font(
                        "View All",
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.north_east_rounded,
                      size: 13,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.popularDestinations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No destinations yet",
                  style: _font("x", color: mutedColor, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: List.generate(controller.popularDestinations.length, (
                i,
              ) {
                final d = controller.popularDestinations[i];
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            "#${i + 1}",
                            style: _font(
                              "#",
                              color: mutedColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _placeImage(
                            d.imageAsset,
                            width: 48,
                            height: 48,
                            mutedColor: mutedColor,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _font(
                                  d.name,
                                  color: titleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 12,
                                    color: mutedColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    d.location,
                                    style: _font(
                                      "x",
                                      color: subtitleColor,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: _amber,
                                  ),
                                  Text(
                                    " ${d.rating}",
                                    style: _font(
                                      "x",
                                      color: subtitleColor,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 12,
                                    color: mutedColor,
                                  ),
                                  Text(
                                    " ${d.views}",
                                    style: _font(
                                      "x",
                                      color: subtitleColor,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(.08)
                                        : Colors.black.withOpacity(.05),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.tag,
                                    style: _font(
                                      d.tag,
                                      color: subtitleColor,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          d.priceLabel,
                          textAlign: TextAlign.right,
                          style: _font(
                            d.priceLabel,
                            color: titleColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (i != controller.popularDestinations.length - 1) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: cardBorder),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  // ── Quick actions ───────────────────────────────────────────────
  Widget _quickActionsPanel({
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: _font(
              "Quick Actions",
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _quickActionTile(
            icon: Icons.add_circle_outline,
            title: "Add New Place",
            subtitle: "Submit for approval",
            highlighted: true,
            onTap: controller.goToAddPlace,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _quickActionTile(
            icon: Icons.place_outlined,
            title: "My Places",
            subtitle: "Manage locations",
            highlighted: false,
            onTap: controller.goToMyPlaces,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(.04)
                  : Colors.black.withOpacity(.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Platform Stats",
                  style: _font(
                    "Platform Stats",
                    color: titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Views",
                      style: _font("x", color: subtitleColor, fontSize: 12),
                    ),
                    Text(
                      "—",
                      style: _font(
                        "x",
                        color: titleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Avg. Rating",
                      style: _font("x", color: subtitleColor, fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          "—",
                          style: _font(
                            "x",
                            color: titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.star_rounded, size: 13, color: _amber),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool highlighted,
    required VoidCallback onTap,
    required Color titleColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlighted
              ? primaryColor.withOpacity(.12)
              : (isDark
                    ? Colors.white.withOpacity(.04)
                    : Colors.black.withOpacity(.03)),
          borderRadius: BorderRadius.circular(14),
          border: highlighted
              ? Border.all(color: primaryColor.withOpacity(.4))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _font(
                      title,
                      color: highlighted ? primaryColor : titleColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: _font(
                      subtitle,
                      color: subtitleColor,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.north_east_rounded, size: 15, color: subtitleColor),
          ],
        ),
      ),
    );
  }

  // ── Recent activity ─────────────────────────────────────────────
  Widget _recentActivityPanel({
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
    required Color mutedColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: _font(
              "Recent Activity",
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (controller.recentActivity.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No recent activity",
                  style: _font("x", color: mutedColor, fontSize: 13),
                ),
              ),
            )
          else
            ...controller.recentActivity.asMap().entries.map(
              (entry) {
                final isLast = entry.key == controller.recentActivity.length - 1;
                final a = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: a.dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: a.text,
                                style: _font(
                                  a.text,
                                  color: subtitleColor,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: a.boldPart,
                                style: _font(
                                  a.boldPart,
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        a.timeAgo,
                        style: _font("x", color: mutedColor, fontSize: 11.5),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── My places ────────────────────────────────────────────────────
  Widget _myPlacesPanel({
    required Color cardBg,
    required Color cardBorder,
    required Color titleColor,
    required Color subtitleColor,
    required Color mutedColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Places",
                style: _font(
                  "My Places",
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: controller.goToMyPlaces,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "See All",
                      style: _font(
                        "See All",
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (controller.myPlaces.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Icon(Icons.explore_outlined, size: 36, color: mutedColor),
                  const SizedBox(height: 10),
                  Text(
                    "No places yet",
                    style: _font(
                      "No places yet",
                      color: subtitleColor,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.goToAddPlace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: Text(
                      "Add First Place",
                      style: _font(
                        "Add First Place",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: controller.myPlaces
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _placeImage(
                              p.imageAsset,
                              width: 44,
                              height: 44,
                              mutedColor: mutedColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              style: _font(
                                p.name,
                                color: titleColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.status,
                              style: _font(
                                p.status,
                                color: subtitleColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final int value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _StatCardData(
    this.label,
    this.value,
    this.subtext,
    this.icon,
    this.color,
  );
}
