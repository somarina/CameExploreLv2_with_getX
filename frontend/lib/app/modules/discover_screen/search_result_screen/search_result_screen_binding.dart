part of 'search_result_screen_view.dart';

class SearchResultScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchResultScreenController());
  }
}
