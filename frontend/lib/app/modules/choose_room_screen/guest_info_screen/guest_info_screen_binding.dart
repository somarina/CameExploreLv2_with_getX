part of 'guest_info_screen_view.dart';

class GuestInfoScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => GuestInfoScreenViewController());
   }
}