part of 'package_detail_screen_view.dart';

class PackageDetailScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => PackageDetailScreenViewController());
   }
}