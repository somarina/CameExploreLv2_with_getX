part of 'explore_screen_view.dart';

class ExploreScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExploreViewController());
  }
}
