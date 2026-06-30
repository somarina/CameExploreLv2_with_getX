part of 'package_write_review_view.dart';

class PackageWriteReviewViewController extends GetxController {

  var themeCtrl = Get.find<ThemeModeViewController>();



  RxInt rating = 0.obs;
  final reviewController = TextEditingController();
  final reviewLength = 0.obs;
  void setRating(int value) {
    rating.value = value;
  }

  @override
  void onInit() {
    reviewController.addListener(() {
      reviewLength.value = reviewController.text.length;
    });
    super.onInit();
  }
}
