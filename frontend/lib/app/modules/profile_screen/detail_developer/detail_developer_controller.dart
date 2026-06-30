import 'package:frontend/app/core/api/Model/model.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';


class DetailDeveloperViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();

  late DeveloperModel developer;

  @override
  void onInit() {
    developer = Get.arguments as DeveloperModel;
    super.onInit();
  }
}