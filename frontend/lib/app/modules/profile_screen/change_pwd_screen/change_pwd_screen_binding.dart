part of 'change_pwd_screen_view.dart';

class ChangePwdScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ChangePwdScreenViewController());
   }
}