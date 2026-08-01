part of 'gallery_seeall_view.dart';

class GallerySeeallViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => GallerySeeallViewController());
   }
}