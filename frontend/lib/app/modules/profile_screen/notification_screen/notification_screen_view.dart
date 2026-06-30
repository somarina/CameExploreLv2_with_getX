import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/Globle/section_card.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'notification_screen_binding.dart';
part 'notification_screen_controller.dart';

class NotificationScreenView extends GetView<NotificationScreenViewController> {
  const NotificationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "Notification",
          style: GoogleFonts.spaceGrotesk(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              title: "ការជូនដំណឹងប្រព័ន្ធ",
              child: Obx(
                () => SwitchListTile(
                  title: Text(
                    "ប្រព័ន្ធ",
                    style: GoogleFonts.spaceGrotesk(fontSize: 16),
                  ),
                  inactiveThumbColor: Colors.white,
                  activeThumbColor: Colors.white,
                  // inactiveTrackColor: Color,
                  activeTrackColor: AppColors.lightPrimaryColor,
                  inactiveTrackColor: Colors.grey[500],
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  value: controller.system.value,
                  onChanged: (v) => controller.system.value = v,
                ),
              ),
            ),

            SectionCard(
              title: 'អន្តរកម្ម',
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: Row(
                        children: [
                          SvgPicture.asset(
                            AppImage.messageIcon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "សារ",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      inactiveThumbColor: Colors.white,
                      activeThumbColor: Colors.white,
                      // inactiveTrackColor: Color,
                      activeTrackColor: AppColors.lightPrimaryColor,
                      inactiveTrackColor: Colors.grey[500],
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      value: controller.message.value,
                      onChanged: (v) => controller.message.value = v,
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        'ចូលចិត្ត',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: Get.theme.colorScheme.secondary,
                        ),
                      ),
                      inactiveThumbColor: Colors.white,
                      activeThumbColor: Colors.white,
                      // inactiveTrackColor: Color,
                      activeTrackColor: AppColors.lightPrimaryColor,
                      inactiveTrackColor: Colors.grey[500],
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      value: controller.like.value,
                      onChanged: (v) => controller.like.value = v,
                    ),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: "ការជូនដំណឹងរុញ",
              child: Obx(
                () => SwitchListTile(
                  title: Text(
                    "ការធ្វើបច្ចុប្បន្នភាពកម្មវិធី\nមុខងារថ្មី និងការធ្វើបច្ចុប្បន្នភាព",
                    style: GoogleFonts.spaceGrotesk(fontSize: 16),
                  ),
                  inactiveThumbColor: Colors.white,
                  activeThumbColor: Colors.white,
                  // inactiveTrackColor: Color,
                  activeTrackColor: AppColors.lightPrimaryColor,
                  inactiveTrackColor: Colors.grey[500],
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  value: controller.pushNot.value,
                  onChanged: (v) => controller.pushNot.value = v,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
