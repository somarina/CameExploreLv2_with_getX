part of 'notification_screen_view.dart';

class NotificationScreenViewController extends GetxController {
  // control theme when have condition
  var themeCtrl = Get.find<ThemeModeViewController>();
  var system = true.obs;
  var message = true.obs;
  var like = false.obs;
  var follow = true.obs;
  var pushNot = true.obs;
}
