part of 'package_write_review_view.dart';

class PackageWriteReviewViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();

  RxInt rating = 0.obs;
  final reviewController = TextEditingController();
  final reviewLength = 0.obs;

  /// Max 5 photos
  final RxList<File> selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

    if (images.isEmpty) return;

    final remaining = 5 - selectedImages.length;

    if (remaining <= 0) {
      Get.snackbar("Limit reached", "You can upload up to 5 photos.");
      return;
    }

    selectedImages.addAll(images.take(remaining).map((e) => File(e.path)));

    if (images.length > remaining) {
      Get.snackbar("Maximum 5 photos", "You can upload up to 5 photos.");
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  } 

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
