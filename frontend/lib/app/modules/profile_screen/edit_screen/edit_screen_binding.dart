part of 'edit_screen_view.dart';

class EditScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => EditScreenViewController());
   }
}