part of 'package_write_review_view.dart';

class PackageWriteReviewViewController extends GetxController {
  final PlaceReviewService _reviewService = PlaceReviewService();
  final themeCtrl = Get.find<ThemeModeViewController>();

  late String targetId;
  late ReviewType reviewType;

  RxInt rating = 0.obs;
  final reviewController = TextEditingController();
  final reviewLength = 0.obs;

  RxBool isLoading = false.obs;

  final RxList<File> selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    // Safely extract target ID and ReviewType from arguments
    final args = Get.arguments;
    if (args is Map) {
      targetId = args['id']?.toString() ?? "";
      reviewType = args['type'] is ReviewType
          ? args['type']
          : ReviewType.package;
    } else {
      targetId = args as String? ?? "";
      reviewType = ReviewType.package;
    }

    reviewController.addListener(() {
      reviewLength.value = reviewController.text.length;
    });
  }

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

  Future<void> submitReview() async {
    if (rating.value == 0) {
      Get.snackbar("Required", "Please provide a star rating.");
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      Get.snackbar("Required", "Please write a review comment.");
      return;
    }

    try {
      isLoading.value = true;

      List<String> imageUrls = [];

      // 1. Upload images first if selected
      if (selectedImages.isNotEmpty) {
        imageUrls = await _reviewService.uploadImages(
          files: selectedImages,
          targetId: targetId,
          type: reviewType,
        );

        debugPrint("Image URLs received from upload: $imageUrls");
      }

      // 2. Attach uploaded URLs into data payload
      final Map<String, dynamic> data = {
        "rating": rating.value,
        "comment": reviewController.text.trim(),
        "images": imageUrls, // <--- Sent to create review endpoint
      };

      debugPrint("Final Create Review Payload: $data");

      // 3. Create review
      final response = await _reviewService.createReview(
        data: data,
        id: targetId,
        type: reviewType,
      );

      if (response != null) {
        // Refresh active controllers
        if (Get.isRegistered<PackageDetailScreenViewController>()) {
          Get.find<PackageDetailScreenViewController>().fetchReviews();
        }
        if (Get.isRegistered<DetailPlacesScreenViewController>()) {
          Get.find<DetailPlacesScreenViewController>().fetchReviews();
        }
        if (Get.isRegistered<HomeScreenController>()) {
          final homeCtrl = Get.find<HomeScreenController>();
          homeCtrl.getPlaces();
          homeCtrl.getPackages();
        }

        Get.back(result: true);
        Get.snackbar("Success", "Review submitted successfully!");
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
