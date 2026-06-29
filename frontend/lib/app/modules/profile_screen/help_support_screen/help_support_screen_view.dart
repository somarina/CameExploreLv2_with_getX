import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'help_support_screen_binding.dart';
part 'help_support_screen_controller.dart';

class HelpSupportScreenView extends GetView<HelpSupportScreenViewController> {
  const HelpSupportScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "terms_conditions".tr,
          style: GoogleFonts.spaceGrotesk(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Get.isDarkMode ? null : Colors.white,
                  border: Get.isDarkMode
                      ? Border.all(color: Get.theme.colorScheme.primary)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description_outlined, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            "terms_of_use".tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            Text(
                              "last_updated".tr,
                              style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_acceptance_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_acceptance_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_acceptance_title".tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_acceptance_desc".tr,
                        style: GoogleFonts.spaceGrotesk(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_use_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_use_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_use_rule".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_privacy_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_privacy_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_ip_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_ip_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_liability_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_liability_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_changes_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_changes_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_contact_title".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "tc_contact_desc".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? null : Colors.white,
                  border: Get.isDarkMode
                      ? Border.all(color: Theme.of(context).colorScheme.primary)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "related_docs".tr,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "privacy_policy".tr,
                        style: GoogleFonts.kantumruyPro(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
