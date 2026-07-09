part of 'hotel_write_review_view.dart';

class WriteReviewScreenViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();
  final overallScore = 0.obs;

  final reviewController = TextEditingController();
  final reviewLength = 0.obs;

  final categories = <String, int>{
    "cleaniness": 0,
    "comfort": 0,
    "location": 0,
    "facilities": 0,
    "staff": 0,
    "value_money": 0,
  }.obs;

  void selectScore(int score) {
    overallScore.value = score;
  }

  void setCategoryRating(String category, int rating) {
    categories[category] = rating;
    categories.refresh();
  }

  String getRatingLabel(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return "poor".tr;
      case 3:
        return "fair".tr;
      case 4:
        return "good".tr;
      case 5:
        return "excellent".tr;
      default:
        return "";
    }
  }

  Color getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.redAccent;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.amber.shade700;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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
      Get.snackbar(
        "Maximum 5 photos",
        "You can upload up to 5 photos.",
      );
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  @override
  void onInit() {
    reviewController.addListener(() {
      reviewLength.value = reviewController.text.length;
    });
    super.onInit();
  }
}
