part of 'about_organization_screen_view.dart';

class AboutOrganizationScreenViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => AboutOrganizationScreenViewController());
   }
}