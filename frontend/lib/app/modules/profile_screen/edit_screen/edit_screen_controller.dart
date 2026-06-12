part of 'edit_screen_view.dart';

class EditScreenViewController extends GetxController {
  /// TEXT CONTROLLERS
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  var gender = 'male'.obs;

  void saveProfile() {
    Get.snackbar('Success', 'Profile Updated');
  }
}
