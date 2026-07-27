part of 'gallery_seeall_view.dart';

class GallerySeeallViewController extends GetxController {
  late List<String> placePhotos;


  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    placePhotos = List<String>.from(args['placePhotos'] ?? []);

  }
}