part of 'package_checkout_screen_view.dart';

class PackageCheckoutScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => PackageCheckoutScreenViewController());
   }
}