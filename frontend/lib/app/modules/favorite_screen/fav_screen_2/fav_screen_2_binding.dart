part of 'fav_screen_2_view.dart';

class FavScreen2ViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FavScreen2ViewController());
  }
}
