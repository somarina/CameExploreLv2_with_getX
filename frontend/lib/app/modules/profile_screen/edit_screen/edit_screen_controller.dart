part of 'edit_screen_view.dart';

class EditScreenViewController extends GetxController {
  final userProfileController = Get.find<UserProfileScreenViewController>();

  final firstnameCtrl = TextEditingController();
  final lastnameCtrl = TextEditingController();
  final newEmailCtrl = TextEditingController();
  final newPhoneCtrl = TextEditingController();

  var selectedGender = ''.obs;
  var isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();
  Rx<File?> pickedImage = Rx<File?>(null);

  late UserModel arg;

  @override
  void onInit() {
    super.onInit();
    arg = Get.arguments as UserModel;
    _loadUser();
  }

  // void _loadUser() {
  //   var fullName = arg.name.split(" ");

  //   firstnameCtrl.text = fullName.isNotEmpty ? fullName[0] : "";
  //   lastnameCtrl.text = fullName.length > 1 ? fullName[1] : "";

  //   newEmailCtrl.text = arg.email;
  //   newPhoneCtrl.text = arg.phone;
  //   selectedGender.value = arg.gender;

  //   if (arg.avatar.isNotEmpty) {
  //     pickedImage.value = File(arg.avatar);
  //   }
  // }

  void _loadUser() {
    var fullName = arg.name.split(" ");

    firstnameCtrl.text = fullName.isNotEmpty ? fullName[0] : "";
    lastnameCtrl.text = fullName.length > 1 ? fullName[1] : "";

    newEmailCtrl.text = arg.email;
    newPhoneCtrl.text = arg.phone;
    selectedGender.value = arg.gender;
  }

  var profileImage = "".obs;

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      pickedImage.value = File(image.path);

      profileImage.value = "m";

      // var response=  await ProfileServices().uploadAvatarService(
      //     avatarPath: image.path,
      //   );

      //   profileImage.value = response["data"]["profile_image"];

      //   debugPrint(profileImage.value );
    }
  }

  Future<void> editProfile() async {
    if (firstnameCtrl.text.isEmpty ||
        lastnameCtrl.text.isEmpty ||
        newEmailCtrl.text.isEmpty ||
        newPhoneCtrl.text.isEmpty ||
        selectedGender.value.isEmpty) {
      Get.snackbar("Warning", "Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;

      String avatarUrl = userProfileController.user.avatar;

      // ✅ upload only if new image picked
      if (pickedImage.value != null) {
        final profileResponse = await ProfileServices().uploadAvatarService(
          avatarPath: pickedImage.value!.path,
        );

        avatarUrl = profileResponse["data"]["profile_image"];
      }

      final response = await ProfileServices().updateProfileService(
        name: "${firstnameCtrl.text} ${lastnameCtrl.text}".trim(),
        email: newEmailCtrl.text,
        phone: newPhoneCtrl.text,
        gender: selectedGender.value,
        avatar: avatarUrl,
      );

      if (response["result"] == true) {
        await userProfileController.getProfile();
        Get.back();
        Get.snackbar("Success", response["message"]);
      } else {
        Get.snackbar("Failed", response["message"]);
      }
    } catch (e) {
      debugPrint("Edit profile error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  // Future<void> editProfile() async {
  //   if (firstnameCtrl.text.isEmpty ||
  //       lastnameCtrl.text.isEmpty ||
  //       newEmailCtrl.text.isEmpty ||
  //       newPhoneCtrl.text.isEmpty ||
  //       selectedGender.value.isEmpty) {
  //     Get.snackbar("Warning", "Please fill all fields");
  //     return;
  //   }

  //   try {
  //     isLoading.value = true;

  //     var profileResponse = await ProfileServices().uploadAvatarService(
  //       avatarPath: pickedImage.value!.path,
  //     );

  //     profileImage.value = profileResponse["data"]["profile_image"];

  //     debugPrint(profileImage.value);

  //     final response = await ProfileServices().updateProfileService(
  //       name: "${firstnameCtrl.text} ${lastnameCtrl.text}".trim(),
  //       email: newEmailCtrl.text,
  //       phone: newPhoneCtrl.text,
  //       gender: selectedGender.value,
  //       avatar: profileImage.value.isEmpty
  //           ? userProfileController.user.avatar
  //           : profileImage.value,
  //     );

  //     if (response["result"] == true) {
  //       await userProfileController.getProfile();
  //       Get.back();
  //       Get.snackbar(response["message"], "Profile updated");
  //     } else {
  //       Get.snackbar(response["message"], "Update failed");
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Something went wrong");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  @override
  void onClose() {
    firstnameCtrl.dispose();
    lastnameCtrl.dispose();
    newEmailCtrl.dispose();
    newPhoneCtrl.dispose();
    super.onClose();
  }
}
