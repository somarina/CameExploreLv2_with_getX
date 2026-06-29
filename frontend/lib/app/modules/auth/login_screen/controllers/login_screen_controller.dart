import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/api_config.dart';
import '../../../../core/api/services/auth_services.dart';
import '../../../../routes/app_pages.dart';

class LoginScreenController extends GetxController
    with GetTickerProviderStateMixin {
  final box = GetStorage();
  final authServices = AuthServices();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final scrollController = ScrollController();

  final isEmail = true.obs;
  final obscure = true.obs;
  final submitted = false.obs;
  final idHasError = false.obs;
  final passHasError = false.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;

  void toggleRememberMe() => rememberMe.value = !rememberMe.value;

  late final AnimationController idShakeController;
  late final Animation<double> idShake;
  late final AnimationController passShakeController;
  late final Animation<double> passShake;

  static const int shakeDurationMs = 180;
  static const double shakeDistance = 10;

  final isEnglish = Get.locale?.languageCode == "enUS";


  @override
  void onInit() {
    super.onInit();
    idShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: shakeDurationMs),
    );
    passShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: shakeDurationMs),
    );
    idShake = _createFieldShake(idShakeController);
    passShake = _createFieldShake(passShakeController);

    // Load saved credentials if remember me was checked
    final remembered = box.read('rememberMe') ?? false;
    if (remembered) {
      rememberMe.value = true;
      final savedIsEmail = box.read('savedIsEmail') ?? true;
      isEmail.value = savedIsEmail;
      if (savedIsEmail) {
        emailController.text = box.read('savedAccount') ?? '';
      } else {
        phoneController.text = box.read('savedAccount') ?? '';
      }
      passController.text = box.read('savedPassword') ?? '';
    }
  }

  Animation<double> _createFieldShake(AnimationController controller) {
    final items = <TweenSequenceItem<double>>[];
    const int count = 7;
    const double d = shakeDistance;
    for (int i = 0; i < count; i++) {
      items.add(
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: i.isEven ? 0 : -d,
            end: i.isEven ? d : -d,
          ),
          weight: 1,
        ),
      );
    }
    items.add(
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -d, end: 0),
        weight: 1,
      ),
    );
    return TweenSequence(
      items,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void changeLoginType(bool value) {
    isEmail.value = value;
    idHasError.value = false;
  }

  void togglePassword() => obscure.value = !obscure.value;
  void clearIdError() {
    if (idHasError.value) idHasError.value = false;
  }

  void clearPassError() {
    if (passHasError.value) passHasError.value = false;
  }

  bool isEmailInvalid(String v) =>
      v.trim().isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
  bool isPhoneInvalid(String v) =>
      v.trim().isEmpty || !RegExp(r'^\d{8,10}$').hasMatch(v.trim());
  bool isPassInvalid(String v) => v.trim().isEmpty || v.trim().length < 6;

  void shakeIdField() => idShakeController.forward(from: 0);
  void shakePassField() => passShakeController.forward(from: 0);

  // ── Save user ─────────────────────────────────────────────────────────────

  void _saveUser(dynamic data) {
    box.write('token', data['token'] ?? '');
    box.write('userId', data['id'] ?? '');
    box.write('userName', data['name'] ?? '');
    box.write('userEmail', data['email'] ?? '');
    box.write('userAvatar', data['avatar'] ?? '');
    box.write('userRole', data['role'] ?? 'user');
    box.write('isLogin', true);
    box.write('userMode', 'user');

    if (rememberMe.value) {
      final account = isEmail.value
          ? emailController.text.trim()
          : phoneController.text.trim();
      box.write('savedAccount', account);
      box.write('savedPassword', passController.text.trim());
      box.write('savedIsEmail', isEmail.value);
      box.write('rememberMe', true);
    } else {
      box.remove('savedAccount');
      box.remove('savedPassword');
      box.write('rememberMe', false);
    }
  }

  // ── Normal Login ──────────────────────────────────────────────────────────

  Future<void> login() async {
    if (isLoading.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    submitted.value = true;

    final idInvalid = isEmail.value
        ? isEmailInvalid(emailController.text)
        : isPhoneInvalid(phoneController.text);
    final passInvalid = isPassInvalid(passController.text);

    idHasError.value = idInvalid;
    passHasError.value = passInvalid;

    if (idInvalid || passInvalid) {
      if (idInvalid) shakeIdField();
      if (passInvalid) shakePassField();
      return;
    }

    try {
      isLoading.value = true;

      final account = isEmail.value
          ? emailController.text.trim()
          : phoneController.text.trim();

      var response = await authServices.loginService(
        emailOrPhone: account,
        password: passController.text.trim(),
      );

      if (response["result"] == true) {
        _saveUser(response["data"]);
        Get.offAllNamed(Routes.BUTTON_NAVBAR);
//         Get.offAllNamed(Routes.BUTTON_NAVBAR);
      } else {
        Get.snackbar(
          'Login Failed',
          response["message"] ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google Login ──────────────────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      await GoogleSignIn.instance.signOut();
      final googleUser = await GoogleSignIn.instance.authenticate();

      var response = await authServices.googleLoginService(
        googleId: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        profileImage: googleUser.photoUrl ?? '',
      );

      if (response["result"] == true) {
        final data = response["data"];
        box.write('token', data['token'] ?? '');
        box.write('userId', data['id'] ?? '');
        box.write('userName', data['name'] ?? '');
        box.write('userEmail', data['email'] ?? '');
        box.write('userAvatar', data['avatar'] ?? '');
        box.write('userRole', data['role'] ?? 'user');
        box.write('isLogin', true);
        box.write('userMode', 'user');
        Get.offAllNamed(Routes.BUTTON_NAVBAR);
      } else {
        Get.snackbar(
          'Google Login Failed',
          response["message"] ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('GOOGLE ERROR: $e');
      Get.snackbar(
        'Google Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Replace loginWithTelegram() in login_screen_controller.dart ───────────

  // Future<void> loginWithTelegram() async {
  //   if (isLoading.value) return;
  //   try {
  //     isLoading.value = true;
  //     const botId = '8720092780';
  //     const origin = 'https://staleness-antirust-shrapnel.ngrok-free.dev';
  //     final url = Uri.parse(
  //       'https://oauth.telegram.org/auth'
  //       '?bot_id=$botId'
  //       '&origin=$origin'
  //       '&return_to=camexplore://telegram-login'
  //       '&request_access=write',
  //     );
  //     if (await canLaunchUrl(url)) {
  //       await launchUrl(url);
  //     } else {
  //       Get.dialog(
  //         AlertDialog(
  //           title: Text(
  //             'មិនអាចបើក Telegram',
  //             style: GoogleFonts.kantumruyPro(),
  //           ),
  //           content: Text(
  //             'សូមដំឡើង Telegram ជាមុនសិន ដើម្បីចូលគណនីតាមរបៀបនេះ។',
  //           ),
  //           actions: [
  //             TextButton(onPressed: () => Get.back(), child: Text('បោះបង់')),
  //             TextButton(
  //               onPressed: () async {
  //                 final storeUrl = Platform.isIOS
  //                     ? Uri.parse(
  //                         'https://apps.apple.com/app/telegram/id686449807',
  //                       )
  //                     : Uri.parse(
  //                         'https://play.google.com/store/apps/details?id=org.telegram.messenger',
  //                       );
  //                 await launchUrl(
  //                   storeUrl,
  //                   mode: LaunchMode.externalApplication,
  //                 );
  //                 Get.back();
  //               },
  //               child: Text('ដំឡើង Telegram'),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> loginWithTelegram() async {
  if (isLoading.value) return;

  try {
    isLoading.value = true;

    final returnTo = Uri.encodeComponent('$kBaseUrl/api/auth/telegram-callback');

    final url = Uri.parse(
      'https://oauth.telegram.org/auth'
      '?bot_id=$kTelegramBotId'
      '&origin=$kBaseUrl'
      '&return_to=$returnTo'   // points to YOUR backend, not camexplore://
      '&request_access=write',
    );

    debugPrint('Telegram URL: $url');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('TELEGRAM ERROR: $e');
    Get.snackbar(
      'Telegram Login Failed',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}
  // ── Guest ─────────────────────────────────────────────────────────────────

  Future<void> continueAsGuest() async {
    box.write('userMode', 'guest');
    Get.offAllNamed(Routes.BUTTON_NAVBAR);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void goToForgotPassword() => Get.toNamed(Routes.FORGET_PASSWORD);
  void goToRegister() => Get.toNamed(Routes.REGISTER_SCREEN);

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    passController.dispose();
    scrollController.dispose();
    idShakeController.dispose();
    passShakeController.dispose();
    super.onClose();
  }
}
