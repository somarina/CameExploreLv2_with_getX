part of 'itinerary_screen_view.dart';

class ItineraryScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ItineraryScreenViewController());
   }
}