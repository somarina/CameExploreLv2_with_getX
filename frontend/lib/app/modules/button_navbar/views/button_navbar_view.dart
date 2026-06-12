import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/button_navbar_controller.dart';

class ButtonNavbarView extends GetView<ButtonNavbarController> {
  const ButtonNavbarView({super.key});

  static final List<Widget> _screens = [
    const _PlaceholderScreen(title: 'ទំព័រដើម'),
    const _PlaceholderScreen(title: 'ស្វែងរក'),
    const _PlaceholderScreen(title: 'រទេះទំនិញ'),
    const _PlaceholderScreen(title: 'រក្សាទុក'),
    const _PlaceholderScreen(title: 'គណនី'),
  ];

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIOSNavbar();
    } else {
      return _buildAndroidNavbar();
    }
  }

  // ── iOS → Real Liquid Glass from adaptive_platform_ui ────────────────
  Widget _buildIOSNavbar() {
    return AdaptiveScaffold(
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        useNativeBottomBar: true,
        selectedIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        items: [
          AdaptiveNavigationDestination(icon: 'house.fill', label: 'ទំព័រដើម'),
          AdaptiveNavigationDestination(icon: 'safari.fill', label: 'ស្វែងរក'),
          AdaptiveNavigationDestination(icon: 'cart.fill', label: 'រទេះទំនិញ'),
          AdaptiveNavigationDestination(icon: 'heart.fill', label: 'រក្សាទុក'),
          AdaptiveNavigationDestination(icon: 'person.fill', label: 'គណនី'),
        ],
      ),
      body: Obx(() => _screens[controller.currentIndex.value]),
    );
  }

  // ── Android → Curved labeled navbar ──────────────────────────────────
  // ── Android → Curved labeled navbar ──────────────────────────────────
  Widget _buildAndroidNavbar() {
    return Scaffold(
      extendBody: true,
      body: Obx(() => _screens[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => CurvedNavigationBar(
          index: controller.currentIndex.value,
          height: 70, // ← increased from 60 to give labels room
          color: Colors.white,
          buttonBackgroundColor: AppColors.lightPrimaryColor,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            controller.currentIndex.value = index;
          },
          items: [
            CurvedNavigationBarItem(
              child: _buildIcon('assets/icons/ion_home.svg'),
              label: 'ទំព័រដើម',
              labelStyle: GoogleFonts.kantumruyPro(
                fontSize: 15,
                fontWeight: controller.currentIndex.value == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            CurvedNavigationBarItem(
              child: _buildIcon('assets/icons/icon_search.svg'),
              label: 'ស្វែងរក',
              labelStyle: GoogleFonts.kantumruyPro(
                fontSize: 15,
                fontWeight: controller.currentIndex.value == 1
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            CurvedNavigationBarItem(
              child: _buildIcon('assets/icons/cart.svg'),
              label: 'រទេះទំនិញ',
              labelStyle: GoogleFonts.kantumruyPro(
                fontSize: 15,
                fontWeight: controller.currentIndex.value == 2
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            CurvedNavigationBarItem(
              child: _buildIcon('assets/icons/icon_favorite.svg'),
              label: 'រក្សាទុក',
              labelStyle: GoogleFonts.kantumruyPro(
                fontSize: 15,
                fontWeight: controller.currentIndex.value == 3
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            CurvedNavigationBarItem(
              child: _buildIcon('assets/icons/profile.svg'),
              label: 'គណនី',
              labelStyle: GoogleFonts.kantumruyPro(
                fontSize: 15,
                fontWeight: controller.currentIndex.value == 4
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SVG Icon builder ──────────────────────────────────────────────────
  Widget _buildIcon(String path) {
    return SvgPicture.asset(
      path,
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}

// ── Placeholder — replace with real screens ───────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.kantumruyPro(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
