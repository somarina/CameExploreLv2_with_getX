part of 'hotel_detail_screen_view.dart';

class HotelDetailScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => HotelDetailScreenViewController());


   }
}