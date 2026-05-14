import 'package:get/get.dart';

import '../controllers/favorite_screen_controller.dart';

class FavoriteScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteScreenController>(
      () => FavoriteScreenController(),
    );
  }
}
