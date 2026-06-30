part of 'hotel_detail_photo_view.dart';

class HotelDetailPhotoViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => HotelDetailPhotoViewController());
   }
}