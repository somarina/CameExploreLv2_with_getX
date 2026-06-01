part of 'private_security_screen_view.dart';

class PrivateSecurityScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => PrivateSecurityScreenViewController());
   }
}