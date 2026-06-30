part of 'home_see_all_screen_view.dart';

class HomeSeeAllScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => HomeSeeAllScreenViewController());
   }
}