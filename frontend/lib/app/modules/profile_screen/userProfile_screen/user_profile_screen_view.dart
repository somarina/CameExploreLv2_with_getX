import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/api/Model/user_model.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors/app_colors.dart';

part 'user_profile_screen_binding.dart';
part 'user_profile_screen_controller.dart';

class UserProfileScreenView extends GetView<UserProfileScreenViewController> {
  const UserProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.getProfile();
    return Scaffold(
      backgroundColor: AppColors.lightPrimaryColor,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SafeArea(
          bottom: false, // not show backgroud
          child: Column(
            children: [
              _header(context),
              SizedBox(height: 20),
              // controller.isLogin.value ? _login(context) : _guestUser(),
              Obx(
                () => controller.isLogin.value ? _login(context) : _guestUser(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _container(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: child,
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required String prefix,
    required String title,
    required String suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Prefix icon
          SvgPicture.asset(
            prefix,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.googleSans(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Suffix icon
          SvgPicture.asset(suffixIcon, width: 30, height: 30),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text("acc".tr, style: AppFonts.fontHeader),
          Spacer(),
          Bounceable(
            onTap: () {
              controller.isLogin.value
                  ? Get.toNamed(Routes.EDIT_SCREEN, arguments: controller.user)
                  : Get.toNamed(Routes.SECURITY_SCREEN);
            },
            child: SvgPicture.asset(AppImage.editIcon),
          ),
        ],
      ),
    );
  }

  Widget _guestUser() {
    return Column(
      crossAxisAlignment: .center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 70),
          child: Row(
            // crossAxisAlignment: .end,
            children: [
              DottedBorder(
                options: CircularDottedBorderOptions(
                  dashPattern: [80, 15], // size long or short
                  strokeWidth: 3, // size big or small
                  padding: EdgeInsets.all(5),
                  color: Color(0xffE7000B),
                ),
                child: CircleAvatar(
                  radius: 45,
                  // profile
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
              SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFEF3C6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    "guest user".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 15,
                      color: Color(0xffBB4D00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xffFEE685)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "signup".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: Color(0xffBB4D00),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(240, 45),
                    backgroundColor: AppColors.lightPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.offAllNamed(Routes.LOGIN_SCREEN);
                    },
                    child: Text("create acc".tr, style: AppFonts.fontsButton),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        _container(
          Get.context!,
          child: Column(
            children: [
              _language(Get.context!),
              _menuItem(
                Get.context!,
                prefix: AppImage.themeIcon,
                title: "theme".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                Get.context!,
                prefix: AppImage.notificationIcon,
                title: "notification".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                Get.context!,
                prefix: AppImage.securityIcon,
                title: "security".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                Get.context!,
                prefix: AppImage.feedbackIcon,
                title: "feedback".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                Get.context!,
                prefix: AppImage.conditionIcon,
                title: "condition".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                Get.context!,
                prefix: AppImage.abouAppIcon,
                title: "app".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                Get.context!,
                prefix: AppImage.developerIcon,
                title: "developer".tr,
                suffixIcon: AppImage.btnIcon,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _language(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Prefix icon
          SvgPicture.asset(
            AppImage.languageIcon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              "language".tr,
              style: GoogleFonts.googleSans(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "translate".tr,
            style: GoogleFonts.googleSans(
              fontSize: 16,
              color: Colors.black45,
            ),
          ),

          SizedBox(width: 10),

          Bounceable(
            onTap: () {},
            onTapDown: (detail) {
              showCustomPopupMenu(
                child: Column(
                  children: [
                    Text(
                      "language".tr,
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                        fontWeight: .bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    _languageItem(
                      Get.context!,
                      text: "khmer".tr,
                      image: AppImage.khmerImage,
                      languageCode: "kmKH",
                      onTap: () {
                        controller.updateLocale("kmKH");
                        Get.back();
                      },
                    ),
                    SizedBox(height: 5),
                    _languageItem(
                      Get.context!,
                      text: "english".tr,
                      image: AppImage.englishImage,
                      languageCode: "enUS",
                      onTap: () {
                        controller.updateLocale("enUS");
                        Get.back();
                      },
                    ),
                  ],
                ),
                context: Get.context!,
                position: detail.globalPosition,
                alignment: Alignment.topLeft,
              );
            },
            child: SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
          ),
        ],
      ),
    );
  }

  Widget _languageItem(
    BuildContext context, {
    required String text,
    required String image,
    required VoidCallback onTap,
    required String languageCode,
  }) {
    return Obx(() {
      final isActive = controller.selectedLanguage.value == languageCode;

      return Bounceable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                text,
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(width: 5),

              Image.asset(image),

              const Spacer(),

              if (isActive)
                SvgPicture.asset(AppImage.doneIcon, width: 20, height: 20),
            ],
          ),
        ),
      );
    });
  }

  Future<T?> showCustomPopupMenu<T>({
    required BuildContext context,
    required Widget child,
    Offset? position,
    Alignment alignment = Alignment.topRight,
    double width = 200,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Custom Popup',
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) {
        const edgePadding = 12.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final maxMenuWidth = (screenWidth - edgePadding * 2)
                .clamp(0.0, width)
                .toDouble();
            final minMenuWidth = maxMenuWidth < 180 ? maxMenuWidth : 180.0;
            final maxLeft = screenWidth - maxMenuWidth - edgePadding;
            final left = position?.dx
                .clamp(
                  edgePadding,
                  maxLeft < edgePadding ? edgePadding : maxLeft,
                )
                .toDouble();

            final menu = Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: minMenuWidth,
                  maxWidth: maxMenuWidth,
                ),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Get.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: child,
              ),
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: Bounceable(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                if (position == null)
                  Align(
                    alignment: alignment,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80, right: 16),
                      child: menu,
                    ),
                  )
                else
                  Positioned(left: left, top: position.dy - 24, child: menu),
              ],
            );
          },
        );
      },
      transitionBuilder: (_, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            alignment: Alignment.topLeft,
            scale: Tween<double>(
              begin: 0.92,
              end: 1,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _login(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? profileShimmer()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DottedBorder(
                  options: const CircularDottedBorderOptions(
                    dashPattern: [80, 15],
                    strokeWidth: 3,
                    padding: EdgeInsets.all(5),
                    color: Color(0xffE7000B),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: controller.isLoading.value
                        ? null
                        : controller.getAvatar(),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            color: Color(0xffE7000B),
                            strokeWidth: 2.5,
                          )
                        : (controller.getAvatar() == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.user.name,
                  style: GoogleFonts.googleSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  controller.user.email,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 20),
                _container(
                  context,
                  child: Column(
                    children: [
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.CHANGEPWD_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.themeIcon,
                          title: "cpwd".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      _language(context),
                      Bounceable(
                        onTap: () async {
                          await Get.toNamed(Routes.THEME_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.themeIcon,
                          title: "theme".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.NOTIFICATION_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.notificationIcon,
                          title: "notification".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.SECURITY_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.securityIcon,
                          title: "security".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.FEEDBACK_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.feedbackIcon,
                          title: "feedback".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.HELPSUPPORT_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.conditionIcon,
                          title: "condition".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.ABOUTAPP_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.abouAppIcon,
                          title: "app".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      Bounceable(
                        onTap: () {
                          Get.toNamed(Routes.ABOUTORGANIZATION_SCREEN);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.developerIcon,
                          title: "developer".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      btn(context),
                    ],
                  ),
                ),
              ],
            ),
    );
  }



Widget profileShimmer() {
  return Shimmer.fromColors(
    baseColor: const Color(0xFFBDBDBD).withValues(alpha: 0.5),
    highlightColor: const Color(0xFFE8E8E8).withValues(alpha: 0.8),
    period: const Duration(milliseconds: 1200),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =========================
        // AVATAR - same as your UI
        // =========================
        DottedBorder(
          options: const CircularDottedBorderOptions(
            dashPattern: [80, 15],
            strokeWidth: 3,
            padding: EdgeInsets.all(5),
            color: Color(0xFFBDBDBD),
          ),
          child: const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFBDBDBD),
          ),
        ),

        const SizedBox(height: 10),

        // =========================
        // NAME
        // =========================
        Container(
          width: 90,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        const SizedBox(height: 8),

        // =========================
        // EMAIL
        // =========================
        Container(
          width: 180,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        const SizedBox(height: 20),

        // =========================
        // SAME CONTAINER
        // =========================
        _shimmerContainer(
          children: [
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerMenuItem(),
            _shimmerLogout(),
          ],
        ),
      ],
    ),
  );
}

Widget _shimmerContainer({
  required List<Widget> children,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFBDBDBD),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30),
      ),
    ),
    child: Column(
      children: children,
    ),
  );
}

Widget _shimmerMenuItem() {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    height: 50,
    decoration: BoxDecoration(
      color: const Color(0xFFBDBDBD),
      border: Border.all(
        color: const Color(0xFFBDBDBD),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: [
        // Icon
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        // Title
        Expanded(
          child: Container(
            height: 17,
            decoration: BoxDecoration(
              color: const Color(0xFFBDBDBD),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Arrow
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

Widget _shimmerLogout() {
  return Column(
    children: [
      const SizedBox(height: 8),

      Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFBDBDBD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFBDBDBD),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 65,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget btn(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 45),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            // foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            controller.logout();
            // Navigate to login screen after logout
            Get.toNamed(Routes.LOGIN_SCREEN);
          },
          child: Row(
            mainAxisAlignment: .center,
            children: [
              SvgPicture.asset(AppImage.leaveIcon),
              SizedBox(width: 10),
              Text(
                "logout".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  fontWeight: .bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
