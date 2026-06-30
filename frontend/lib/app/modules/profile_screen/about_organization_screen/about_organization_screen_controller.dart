import 'package:frontend/app/core/api/Model/model.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';

class AboutOrganizationController extends GetxController {
  // control theme when have condition
  var themeCtrl = Get.find<ThemeModeViewController>();
  final developers = <DeveloperModel>[
    DeveloperModel(
      name: "dev_1".tr,
      role: "Flutter Developer",
      description: "Developed CamExplore tourism mobile application",
      description2: "UX/UI Desisn",
      description3: "Built explore and detail screens",
      education: "Royal University Of Phnom Penh ",
      disEducation: "Bachelor of Computer Science(Year 4, Semester 1)",
      education2: "ANT Technology Training Center",
      disEducation2: " Mobile App(Flutter) Scholarship from (MPTC)",

      skills: ["Flutter", "GetX", "Firebase", "Figma"],
    ),
    DeveloperModel(
      name: "dev_2".tr,
      role: "Flutter Developer",
      description: "Developed CamExplore tourism mobile application",
      description2: "UX/UI Desisn",
      description3: "Built explore and detail screens",
      education: "Royal University Of Phnom Penh ",
      disEducation: "Bachelor of Computer Science(Graduate)",
      education2: "ANT Technology Training Center",
      disEducation2: " Mobile App(Flutter) Scholarship from (MPTC)",
      skills: ["Flutter", "GetX", "Firebase", "Figma"],
    ),
    DeveloperModel(
      name: "dev_3".tr,
      role: "Flutter Developer",
      description: "Developed CamExplore tourism mobile application",
      description2: "UX/UI Desisn",
      description3: "Built explore and detail screens",
      education: "Royal University Of Phnom Penh ",
      disEducation: "Bachelor of Computer Science(Graduate)",
      education2: "ANT Technology Training Center",
      disEducation2: " Mobile App(Flutter) Scholarship from (MPTC)",
      skills: ["Flutter", "GetX", "Firebase", "Figma"],
    ),
    DeveloperModel(
      name: "dev_4".tr,
      role: "Flutter Developer",
      description: "Developed CamExplore tourism mobile application",
      description2: "UX/UI Desisn",
      description3: "Built explore and detail screens",
      education: "SETEC Institute Of Phnom Penh ",
      disEducation:
          "Bachelor of Managment Information System(Year 2, Semester 1)",
      education2: "ANT Technology Training Center",
      disEducation2: " Mobile App(Flutter)",
      skills: ["Flutter", "GetX"],
    ),
  ];
}
