part of 'detail_places_screen_view.dart';

class DetailPlacesScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => DetailPlacesScreenViewController());
       
   }
}