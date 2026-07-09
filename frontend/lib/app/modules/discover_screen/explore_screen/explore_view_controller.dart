part of 'explore_screen_view.dart';

class ExploreViewController extends GetxController {
  final CategoryService categoryService = CategoryService();
  final PlacesServices placesService = PlacesServices();

  RxBool isLoading = false.obs;

  RxList categories = [].obs;
  RxList places = [].obs;
  RxList<bool> favorites = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
    getPlaces();
  }

  void toggleFavorite(int index) {
    favorites[index] = !favorites[index];
    favorites.refresh();
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
      final response = await categoryService.getCategories();

      if (response["result"] == true) {
        categories.value = response["data"] ?? [];
      }
    } catch (e) {
      debugPrint("Get Categories Error: $e");
    }
  }

  Future<void> getPlaces({String? category}) async {
    try {
      isLoading.value = true;

      final response = await placesService.fetchPlaces(category: category);

      places.assignAll(response);

      favorites.assignAll(List.generate(places.length, (_) => false));
    } catch (e) {
      debugPrint("Get Places Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
