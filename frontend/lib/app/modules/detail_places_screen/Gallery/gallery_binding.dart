part of 'gallery_view.dart';

class GalleryViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => GalleryViewController());
   }
}