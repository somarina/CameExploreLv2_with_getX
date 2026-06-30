part of 'confirmed_booking_view.dart';

class ConfirmedBookingViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ConfirmedBookingViewController());
   }
}