import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/about_organization_screen/about_organization_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutOrganizationScreenView extends GetView<AboutOrganizationController> {
  const AboutOrganizationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "organ_title".tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: .bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // buildContainer(context),
              buildContainer(
                context,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AppImage.peopleIcon,
                        width: 60,
                        height: 60,
                      ),
                      Text(
                        "about_app_title".tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: .bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        "about_app_desc".tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(children: [SvgPicture.asset(AppImage.teamIcon)]),
              SizedBox(height: 20),
              buildContainer(
                context,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(AppImage.favIcon),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "mission_title".tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,

                              fontWeight: .bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: Get.width * 0.67,
                            child: Text(
                              "mission_desc".tr,
                              textAlign: TextAlign.start, // for text center
                              style: GoogleFonts.spaceGrotesk(
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
              ),
              SizedBox(height: 20),
              // buildDeveloper(context),
              Row(
                children: [
                  // SvgPicture.asset(AppImage.teamImage, width: 40,height: 40,)
                  // Image.asset("assets/images/team.png"),
                  SizedBox(width: 10),
                  Text(
                    "developer_title".tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: .bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.developers.length,
                itemBuilder: (context, index) {
                  final dev = controller.developers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.green),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        dev.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: .bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      subtitle: Text(
                        dev.role,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.toNamed(
                          Routes.DETAILDEVELOPER_SCREEN,
                          arguments: dev,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainer(BuildContext context, {required child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Colors.white,
        color: controller.themeCtrl.getDark() ? null : Color(0xffD0FAE5),
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5), // x, y
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  // Widget buildDeveloper(BuildContext context) {
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           // SvgPicture.asset(AppImage.teamImage, width: 40,height: 40,)
  //           Image.asset("assets/images/team.png"),
  //           SizedBox(width: 10),
  //           Text(
  //             "ក្រុមអ្នកអភិវឌ្ឍន៍កម្មវិធី",
  //             style: GoogleFonts.spaceGrotesk(
  //               fontSize: 18,
  //               fontWeight: .bold,
  //               color: Theme.of(context).colorScheme.secondary,
  //             ),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 20),
  //       Container(
  //         width: double.infinity,
  //         height: 70,
  //         decoration: BoxDecoration(
  //           color: Color(0xffE6FCEE),
  //           borderRadius: BorderRadius.only(
  //             bottomLeft: Radius.circular(50),
  //             bottomRight: Radius.circular(50),
  //           ),
  //           border: Border.all(width: 1, color: AppColors.darkPrimaryColor),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Row(
  //             children: [
  //               SvgPicture.asset(AppImage.profileIcon),
  //               Spacer(),
  //               Text(
  //                 "Keat Somarina",
  //                 style: GoogleFonts.spaceGrotesk(
  //                   fontSize: 18,
  //                   color: Colors.black,
  //                   fontWeight: .bold,
  //                 ),
  //               ),
  //               SizedBox(width: 5),
  //               // SvgPicture.asset(AppImage.githubIcon),
  //               // SvgPicture.asset("assets/svg/github.svg"),
  //               // SvgPicture.asset(AppImage.emailIcon),
  //               Spacer(),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: double.infinity,
  //         height: 70,
  //         decoration: BoxDecoration(
  //           color: Color(0xffE6FCEE),
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(50),
  //             topRight: Radius.circular(50),
  //           ),
  //           border: Border.all(width: 1, color: AppColors.darkPrimaryColor),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Row(
  //             children: [
  //               SvgPicture.asset(AppImage.profileIcon),
  //               Spacer(),
  //               Text(
  //                 "Taing Naihuoy",
  //                 style: GoogleFonts.spaceGrotesk(
  //                   fontSize: 18,
  //                   color: Colors.black,
  //                   fontWeight: .bold,
  //                 ),
  //               ),
  //               // SvgPicture.asset(AppImage.githubIcon),
  //               // SvgPicture.asset("assets/svg/github.svg"),
  //               // SvgPicture.asset(
  //               //   AppImage.emailIcon,
  //               //   fit: BoxFit.cover,
  //               //   width: 30,
  //               //   color: Colors.amber,
  //               // ),
  //               Spacer(),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //             ],
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 20),
  //       Container(
  //         width: double.infinity,
  //         height: 70,
  //         decoration: BoxDecoration(
  //           color: Color(0xffE6FCEE),
  //           borderRadius: BorderRadius.only(
  //             bottomLeft: Radius.circular(50),
  //             bottomRight: Radius.circular(50),
  //           ),
  //           border: Border.all(width: 1, color: AppColors.darkPrimaryColor),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Row(
  //             children: [
  //               SvgPicture.asset(AppImage.profileIcon),
  //               Spacer(),
  //               Text(
  //                 "Tangoun Songheng",
  //                 style: GoogleFonts.spaceGrotesk(
  //                   fontSize: 18,
  //                   color: Colors.black,
  //                   fontWeight: .bold,
  //                 ),
  //               ),
  //               SizedBox(width: 5),
  //               // SvgPicture.asset(AppImage.githubIcon),
  //               // SvgPicture.asset("assets/svg/github.svg"),
  //               // SvgPicture.asset(AppImage.emailIcon),
  //               Spacer(),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: double.infinity,
  //         height: 70,
  //         decoration: BoxDecoration(
  //           color: Color(0xffE6FCEE),
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(50),
  //             topRight: Radius.circular(50),
  //           ),
  //           border: Border.all(width: 1, color: AppColors.darkPrimaryColor),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Row(
  //             children: [
  //               SvgPicture.asset(AppImage.profileIcon),
  //               Spacer(),
  //               Text(
  //                 "Aing Vouchly",
  //                 style: GoogleFonts.spaceGrotesk(
  //                   fontSize: 18,
  //                   color: Colors.black,
  //                   fontWeight: .bold,
  //                 ),
  //               ),
  //               // SvgPicture.asset(AppImage.githubIcon),
  //               // SvgPicture.asset("assets/svg/github.svg"),
  //               // SvgPicture.asset(
  //               //   AppImage.emailIcon,
  //               //   fit: BoxFit.cover,
  //               //   width: 30,
  //               //   color: Colors.amber,
  //               // ),
  //               Spacer(),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //               SizedBox(width: 5),
  //               SvgPicture.asset(AppImage.btnIcon, width: 30, height: 30),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
