part of 'explore_screen_view.dart';

class ExploreViewController extends GetxController {
  final CategoryService categoryService = CategoryService();

  RxBool isLoading = false.obs;
  RxList categories = [].obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true;

      final response = await categoryService.getCategories();

      if (response["result"] == true) {
        categories.value = response["data"] ?? [];
      }
    } catch (e) {
      debugPrint("Get Categories Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
