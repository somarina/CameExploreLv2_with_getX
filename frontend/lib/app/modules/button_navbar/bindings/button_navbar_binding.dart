import 'package:frontend/app/modules/booking_screen/controllers/booking_screen_controller.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_controller.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:get/get.dart';

import '../../profile_screen/userProfile_screen/user_profile_screen_view.dart';
import '../controllers/button_navbar_controller.dart';

class ButtonNavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ButtonNavbarController>(() => ButtonNavbarController());

    Get.lazyPut<HomeScreenController>(() => HomeScreenController());

    Get.lazyPut<SearchScreenController>(() => SearchScreenController());

    Get.lazyPut<BookingScreenController>(() => BookingScreenController());

    Get.lazyPut<UserProfileScreenViewController>(
      () => UserProfileScreenViewController(),
    );
    Get.lazyPut<SearchScreenController>(() => SearchScreenController());

    Get.lazyPut<BookingScreenController>(() => BookingScreenController());
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<FavoriteScreenController>(() => FavoriteScreenController());
    Get.lazyPut<NearbyScreenController>(() => NearbyScreenController());
  }
}


  // Get.put(SearchScreenController());
  // Get.put(BookingScreenController());
  // Get.put(FavoriteScreenController());