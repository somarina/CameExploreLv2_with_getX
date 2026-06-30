import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  //TODO: Implement HomeScreenController

  var currentIndex = 0.obs;

  List<String> imgList = [
    'assets/images/homescreen/slider1.png',
    'assets/images/homescreen/slider2.png',
    'assets/images/homescreen/slider3.png',
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }


  final favorites = List.generate(20, (_) => false).obs;
  void toggleFavorite(int index) {
    favorites[index] = !favorites[index];
  }

  @override
  void onInit() {
    super.onInit();
  }
}
