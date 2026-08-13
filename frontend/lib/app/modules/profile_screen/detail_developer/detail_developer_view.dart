import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_developer_controller.dart';

class DetailDeveloperView extends GetView<DetailDeveloperViewController> {
  const DetailDeveloperView({super.key});

  @override
  Widget build(BuildContext context) {
    final dev = controller.developer;

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
          "About Developer".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 60, backgroundImage: AssetImage(dev.image)),
            SizedBox(height: 10),
            Text(
              dev.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              dev.role,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),

            SizedBox(height: 20),

            _card(
              // ot jenh image
              svg: AppImage.projectIcon,
              context,
              title: "Contact".tr,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .start,
                    children: [
                      Image.asset("assets/icons/call.png", width: 30),
                      SizedBox(width: 20),
                      Image.asset(
                        "assets/icons/github.png",
                        // color: Theme.of(context).colorScheme.secondary,
                        width: 30,
                      ),
                      SizedBox(width: 20),
                      Image.asset("assets/icons/google.png", width: 30),

                      SizedBox(width: 20),
                      Image.asset("assets/icons/telegram.png", width: 30),
                    ],
                  ),
                ],
              ),
            ),

            _card(
              svg: AppImage.projectIcon,
              context,
              title: "Project Contribution".tr,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(AppImage.dotIcon),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dev.description,
                          style: GoogleFonts.googleSans(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(AppImage.dotIcon),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dev.description2,
                          style: GoogleFonts.googleSans(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(AppImage.dotIcon),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dev.description3,
                          style: GoogleFonts.googleSans(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _card(
              svg: AppImage.educationIcon,
              context,
              title: "Education".tr,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(AppImage.locationIcon),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              dev.education,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.googleSans(
                                fontSize: 16,
                                fontWeight: .bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              dev.disEducation,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.googleSans(
                                fontSize: 14,

                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(AppImage.locationIcon),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              dev.education2,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.googleSans(
                                fontSize: 16,
                                fontWeight: .bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              dev.disEducation2,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.googleSans(
                                fontSize: 14,

                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _card(
              context,
              svg: AppImage.skillIcon,
              title: "Skills".tr,
              child: Wrap(
                spacing: 8,
                children: dev.skills.map((s) => Chip(label: Text(s))).toList(),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Together we build CamExplore to help people explore the beauty of Cambodia."
                    .tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required Widget child,
    required String svg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(svg),
              SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
