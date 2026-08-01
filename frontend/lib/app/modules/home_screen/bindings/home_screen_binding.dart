import 'package:frontend/app/modules/discover_screen/explore_screen/explore_screen_view.dart';
import 'package:get/get.dart';

import '../controllers/home_screen_controller.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(
      () => HomeScreenController(), 
    );
    Get.lazyPut<ExploreViewController>(
      () => ExploreViewController(),
    );

  }
}
