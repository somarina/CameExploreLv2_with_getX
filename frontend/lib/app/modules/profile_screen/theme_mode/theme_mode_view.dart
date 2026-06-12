import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

part 'theme_mode_binding.dart';
part 'theme_mode_controller.dart';

class ThemeModeView extends GetView<ThemeModeViewController> {
  const ThemeModeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back(result: controller.isDark.value);
          },
        ),
        title: Text(
          "Theme Mode",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: .bold,
            color: Get.theme.colorScheme.secondary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Theme", style: TextStyle(fontSize: 18)),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    /// 🌞 LIGHT MODE
                    GestureDetector(
                      onTap: () {
                        controller.changeTheme(false);

                      },
                      child: Column(
                        children: [
                          Image.asset(AppImage.lightImage, height: 100),
                          const SizedBox(height: 8),
                          const Text("Light"),
                          const SizedBox(height: 8),
                           controller.selectMode.value == 0? SvgPicture.asset(
                              AppImage.doneIcon,
                              colorFilter: ColorFilter.mode(
                                Get.theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ) : SizedBox(),
                          
                        ],
                      ),
                    ),

                    /// 🌙 DARK MODE
                    GestureDetector(
                      onTap: () => controller.changeTheme(true),
                      child: Column(
                        children: [
                          Image.asset(AppImage.darkImage, height: 100),
                          SizedBox(height: 8),
                          Text("Dark"),
                          SizedBox(height: 8),

                        controller.selectMode.value == 1? SvgPicture.asset(
                              AppImage.doneIcon,
                              colorFilter: ColorFilter.mode(
                                Get.theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ) : SizedBox(),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
