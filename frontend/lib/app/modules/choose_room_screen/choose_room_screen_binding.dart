part of 'choose_room_screen_view.dart';

class ChooseRoomScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChooseRoomScreenViewController());
  }
}
