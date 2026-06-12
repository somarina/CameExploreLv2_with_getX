part of 'theme_mode_view.dart';

class ThemeModeViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ThemeModeViewController());
   }
}