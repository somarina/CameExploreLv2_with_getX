part of 'hotel_detail_photo_view.dart';

class HotelDetailPhotoViewController extends GetxController {

late List<String> hotelPhotos;


  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    hotelPhotos = List<String>.from(args['hotelPhotos'] ?? []);

  }
}