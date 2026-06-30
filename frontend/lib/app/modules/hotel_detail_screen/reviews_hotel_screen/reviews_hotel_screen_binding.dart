part of 'reviews_hotel_screen_view.dart';

class ReviewsHotelScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ReviewsHotelScreenViewController());
   }
}