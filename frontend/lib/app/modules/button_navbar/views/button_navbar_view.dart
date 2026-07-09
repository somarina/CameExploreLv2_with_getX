import 'dart:io' show Platform;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/modules/booking_screen/views/booking_screen_view.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_view.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors/app_colors.dart';
import '../../favorite_screen/views/favorite_screen_view.dart';
import '../../home_screen/views/home_screen_view.dart';
import '../../profile_screen/userProfile_screen/user_profile_screen_view.dart';
import '../controllers/button_navbar_controller.dart';

class ButtonNavbarView extends GetView<ButtonNavbarController> {
  const ButtonNavbarView({super.key});

  // Pages built lazily — only rendered when first visited, not all at once
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreenView();
      case 1:
        return SearchScreenView();
      case 2:
        return BookingScreenView();
      case 3:
        return FavoriteScreenView();
      case 4:
        return UserProfileScreenView();
      default:
        return SizedBox.shrink();
    }
  }

  static final List<AdaptiveNavigationDestination> _destinations = [
    const AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
    const AdaptiveNavigationDestination(icon: Icons.search, label: 'Discover'),
    const AdaptiveNavigationDestination(
      icon: Icons.shopping_bag,
      label: 'Booking',
    ),
    const AdaptiveNavigationDestination(
      icon: Icons.favorite,
      label: 'Favorites',
    ),
    const AdaptiveNavigationDestination(icon: Icons.person, label: 'Profile'),
  ];

  static final List<CurvedNavigationBarItem> _androidNavItems = [
    const CurvedNavigationBarItem(child: Icon(Icons.home), label: 'Home'),
    const CurvedNavigationBarItem(child: Icon(Icons.search), label: 'Discover'),
    const CurvedNavigationBarItem(
      child: Icon(Icons.shopping_bag),
      label: 'Booking',
    ),
    const CurvedNavigationBarItem(
      child: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    const CurvedNavigationBarItem(child: Icon(Icons.person), label: 'Profile'),
  ];

  Widget _androidBottomBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CurvedNavigationBar(
        items: _androidNavItems,
        index: controller.currentIndex.value,
        color: Colors.white,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppColors.lightPrimaryColor,
        height: 75,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeOut,
        onTap: controller.changePage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdaptiveScaffold(
        // _buildPage renders only the current page — no IndexedStack pre-building all 5
        body: _buildPage(controller.currentIndex.value),
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          items: _destinations,
          selectedIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          useNativeBottomBar: true,
          bottomNavigationBar:
              Platform.isAndroid ? _androidBottomBar(context) : null,
        ),
      ),
    );
  }
}
