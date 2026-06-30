part of 'about_app_screen_view.dart';

class AboutAppScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => AboutAppScreenViewController());
      
   }
}