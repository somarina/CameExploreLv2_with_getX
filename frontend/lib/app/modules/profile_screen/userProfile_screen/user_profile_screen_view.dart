import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
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
              SizedBox(height: 50),
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
              style: GoogleFonts.spaceGrotesk(
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
          GestureDetector(
            onTap: () {
              controller.isLogin.value
                  ? Get.toNamed(Routes.EDIT_SCREEN, arguments: controller.user)
                  : Get.toNamed(Routes.SECURITY_SCREEN); ////
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
                    style: GoogleFonts.spaceGrotesk(
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
                  style: GoogleFonts.spaceGrotesk(
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
                  child: Text("create acc".tr, style: AppFonts.fontsButton),
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
              style: GoogleFonts.spaceGrotesk(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "translate".tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: Colors.black45,
            ),
          ),

          SizedBox(width: 10),

          GestureDetector(
            onTap: () {},
            onTapDown: (detail) {
              showCustomPopupMenu(
                child: Column(
                  children: [
                    Text(
                      "language".tr,
                      style: GoogleFonts.spaceGrotesk(
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
    bool isActive = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.primary,
          //   width: 2,
          // ),
          border: Border.all(
            color: isActive ? Get.theme.colorScheme.primary : Colors.grey,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 5),
            Image.asset(image),
            // SvgPicture.asset(AppImage.khmerIcon)
            Spacer(),
            SvgPicture.asset(AppImage.doneIcon),
          ],
        ),
      ),
    );
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
                  child: GestureDetector(
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
          ? CircularProgressIndicator()
          // Shimmer.fromColors(
          //   baseColor: Colors.grey.shade200,
          //   highlightColor: Colors.grey.shade300,
          //   child: Container(height: 50, color: Colors.grey),
          // )
          : Column(
=======
          ? CircularProgressIndicator(color: Colors.white)
          :
            // Shimmer.fromColors(
            //   baseColor: Colors.grey.shade200,
            //   highlightColor: Colors.grey.shade300,
            //   child: Container(height: 50, color: Colors.grey),
            // )
            // ListView.builder(
            //   shrinkWrap: true,
            //     physics: const NeverScrollableScrollPhysics(),
            //     padding: const EdgeInsets.all(16),
            //     itemCount: 10
            //     itemBuilder: (context, index) {
            //       return buildShimmer(context);
            //     },):
            Column(
              crossAxisAlignment: .center,
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
                    // backgroundImage: AssetImage('assets/images/profile.png'),
                    backgroundImage: controller.isLoading.value
                        ? null
                        : controller.getAvatar(),
                  ),
                ),
                Text(
                  controller.user.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: .bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  controller.user.email,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 20),
                _container(
                  context,
                  child: Column(
                    children: [
                      GestureDetector(
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

                      GestureDetector(
                        onTap: () async {
                          await Get.toNamed(Routes.THEME_SCREEN);

                          // controller.changeTheme(ThemeMode.dark);
                          // Get.changeThemeMode(.dark);
                        },
                        child: _menuItem(
                          Get.context!,
                          prefix: AppImage.themeIcon,
                          title: "theme".tr,
                          suffixIcon: AppImage.btnIcon,
                        ),
                      ),
                      GestureDetector(
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
                      GestureDetector(
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
                      GestureDetector(
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
                      GestureDetector(
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
                      GestureDetector(
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
                      GestureDetector(
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

  Widget buildShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withValues(alpha: 0.8),
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
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
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: .bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}
