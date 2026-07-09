import 'package:frontend/app/modules/discover_screen/search_screen/discover_place_model.dart';
import 'package:get/get.dart';

import '../../../core/api/services/places_services.dart';

class SearchScreenController extends GetxController {
  final PlacesServices service = PlacesServices();

  RxBool isLoading = true.obs;

  RxList<DiscoverPlaceModel> mostSearch = <DiscoverPlaceModel>[].obs;
  RxList<DiscoverPlaceModel> popularPlaces = <DiscoverPlaceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getDiscoverHome();
  }

  Future<void> getDiscoverHome() async {
    try {
      isLoading(true);

      final response = await service.fetchDiscoverHome();

      final data = response["data"];

      mostSearch.assignAll(
        (data["most_search"] as List)
            .map((e) => DiscoverPlaceModel.fromJson(e))
            .toList(),
      );

      popularPlaces.assignAll(
        (data["popular_places"] as List)
            .map((e) => DiscoverPlaceModel.fromJson(e))
            .toList(),
      );
    } finally {
      isLoading(false);
    }
  }
}
