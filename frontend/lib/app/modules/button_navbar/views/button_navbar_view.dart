import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/modules/booking_screen/views/booking_screen_view.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_view.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors/app_colors.dart';
import '../../../routes/app_pages.dart';
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
    AdaptiveNavigationDestination(icon: 'house', label: 'Home'),
    AdaptiveNavigationDestination(icon: 'magnifyingglass', label: 'Discover'),
    AdaptiveNavigationDestination(icon: 'bag', label: 'Booking'),
    AdaptiveNavigationDestination(icon: 'heart', label: 'Favorites'),
    AdaptiveNavigationDestination(icon: 'person', label: 'Profile'),
  ];

  // static final List<CurvedNavigationBarItem> _androidNavItems = [
  //   const CurvedNavigationBarItem(child: Icon(Icons.home), label: 'Home'),
  //   const CurvedNavigationBarItem(child: Icon(Icons.search), label: 'Discover'),
  //   const CurvedNavigationBarItem(
  //     child: Icon(Icons.shopping_bag, color: controller.currentIndex.value == 0
  //         ? Colors.white
  //         : Colors.grey,),
  //     label: 'Booking',
  //   ),
  //   const CurvedNavigationBarItem(
  //     child: Icon(Icons.favorite),
  //     label: 'Favorites',
  //   ),
  //   const CurvedNavigationBarItem(child: Icon(Icons.person), label: 'Profile'),
  // ];

  List<CurvedNavigationBarItem> get _androidNavItems => [
    CurvedNavigationBarItem(
      child: Icon(
        Icons.home,
        color: controller.currentIndex.value == 0 ? Colors.white : Colors.black,
      ),
      label: 'Home',
    ),
    CurvedNavigationBarItem(
      child: Icon(
        Icons.search,
        color: controller.currentIndex.value == 1 ? Colors.white : Colors.black,
      ),
      label: 'Discover',
    ),
    CurvedNavigationBarItem(
      child: Icon(
        Icons.shopping_bag,
        color: controller.currentIndex.value == 2 ? Colors.white : Colors.black,
      ),
      label: 'Booking',
    ),
    CurvedNavigationBarItem(
      child: Icon(
        Icons.favorite,
        color: controller.currentIndex.value == 3 ? Colors.white : Colors.black,
      ),
      label: 'Favorites',
    ),
    CurvedNavigationBarItem(
      child: Icon(
        Icons.person,
        color: controller.currentIndex.value == 4 ? Colors.white : Colors.black,
      ),
      label: 'Profile',
    ),
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
      () => Stack(
        children: [
          AdaptiveScaffold(
            // _buildPage renders only the current page — no IndexedStack pre-building all 5
            body: _buildPage(controller.currentIndex.value),
            bottomNavigationBar: AdaptiveBottomNavigationBar(
              items: _destinations,
              selectedIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              useNativeBottomBar: true,
              bottomNavigationBar: Platform.isAndroid
                  ? _androidBottomBar(context)
                  : null,
            ),
          ),
          // AssistiveTouch-style floating button — draggable anywhere on
          // screen, snaps to the nearest edge on release, opens AI screen.
          const _AssistiveTouchButton(),
        ],
      ),
    );
  }
}

// Small frosted-glass circle that mimics iOS AssistiveTouch: draggable,
// semi-transparent, snaps to the left/right edge when let go.
class _AssistiveTouchButton extends StatefulWidget {
  const _AssistiveTouchButton();

  @override
  State<_AssistiveTouchButton> createState() => _AssistiveTouchButtonState();
}

class _AssistiveTouchButtonState extends State<_AssistiveTouchButton>
    with SingleTickerProviderStateMixin {
  static const double _size = 52;

  Offset? _position;
  late final AnimationController _snapController;
  Animation<Offset>? _snapAnimation;
  bool _dragging = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
      if (_snapAnimation != null) {
        setState(() => _position = _snapAnimation!.value);
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _initPositionIfNeeded(Size screenSize) {
    _position ??= Offset(
      screenSize.width - _size - 12,
      screenSize.height * 0.55,
    );
  }

  void _onDragUpdate(DragUpdateDetails details, Size screenSize) {
    setState(() {
      final dx = (_position!.dx + details.delta.dx).clamp(
        0.0,
        screenSize.width - _size,
      );
      final dy = (_position!.dy + details.delta.dy).clamp(
        0.0,
        screenSize.height - _size,
      );
      _position = Offset(dx, dy);
    });
  }

  void _onDragEnd(Size screenSize) {
    final snapLeft = _position!.dx < (screenSize.width - _size) / 2;
    final targetX = snapLeft ? 8.0 : screenSize.width - _size - 8.0;
    final target = Offset(targetX, _position!.dy);

    _snapAnimation = Tween<Offset>(
      begin: _position,
      end: target,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));
    _snapController.forward(from: 0);
    setState(() => _dragging = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _initPositionIfNeeded(screenSize);

    // Bright + glowing while touched or dragged, dim/translucent when idle
    // — same idea as iOS AssistiveTouch fading out until you tap it.
    final bool active = _dragging || _pressed;

    return Positioned(
      left: _position!.dx,
      top: _position!.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _dragging = true),
        onPanUpdate: (details) => _onDragUpdate(details, screenSize),
        onPanEnd: (_) => _onDragEnd(screenSize),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => Get.toNamed(Routes.AI_SCREEN),
        child: AnimatedScale(
          scale: _dragging ? 1.1 : (_pressed ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 120),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? AppColors.lightPrimaryColor.withOpacity(0.95)
                      : Colors.white.withOpacity(0.25),
                  border: Border.all(
                    color: active
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.lightPrimaryColor.withOpacity(
                              0.6,
                            ),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: active ? Colors.white : Colors.white.withOpacity(0.7),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}