part of 'fav_screen_2_view.dart';

class FavScreen2ViewController extends GetxController {
  
  var renameCtrl = TextEditingController();
  var renameFocusNode = FocusNode();
  RxString listName = "My Favorite Places".obs;

  @override
  void onInit() {
    super.onInit();
  }
}
