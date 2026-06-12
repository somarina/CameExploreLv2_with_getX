import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_controller.dart';
import 'package:get/get.dart';

class SearchScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchScreenController());
  }
}
