import 'package:get/get.dart';

import '../../booking_screen/controllers/booking_screen_controller.dart';
import '../../discover_screen/search_screen/search_screen_controller.dart';
import '../../favorite_screen/controllers/favorite_screen_controller.dart';
import '../../home_screen/controllers/home_screen_controller.dart';
import '../../profile_screen/userProfile_screen/user_profile_screen_view.dart';
import '../controllers/button_navbar_controller.dart';

class ButtonNavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ButtonNavbarController>(
      () => ButtonNavbarController(),
    );

    Get.lazyPut<HomeScreenController>(
      () => HomeScreenController(),
    );

    Get.lazyPut<SearchScreenController>(
      () => SearchScreenController(),
    );

    Get.lazyPut<BookingScreenController>(
      () => BookingScreenController(),
    );

    Get.lazyPut<FavoriteScreenController>(
      () => FavoriteScreenController(),
    );

    Get.lazyPut<UserProfileScreenViewController>(
      () => UserProfileScreenViewController(),
    );
  }
}
