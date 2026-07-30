part of 'hotel_write_review_view.dart';

class WriteReviewScreenViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();
  var hotelCtrl = HotelDetailScreenViewController();
  final overallScore = 0.obs;

  final reviewController = TextEditingController();
  final reviewLength = 0.obs;

  final HotelReviewServices reviewService = HotelReviewServices();
  late final Map<String, dynamic> hotel;

  var hotelDetailCtrl = Get.find<HotelDetailScreenViewController>();
  var homelCtrl = Get.find<HomeScreenController>();

  final categories = <String, int>{
    "cleaniness": 0,
    "comfort": 0,
    "location": 0,
    "facilities": 0,
    "staff": 0,
    "value_money": 0,
  }.obs;

  // Dynamic Stayed Date Getter
  String get stayedDateText {
    final rawDate =
        hotel["check_in"] ?? hotel["stayed_date"] ?? hotel["startDate"];
    if (rawDate == null || rawDate.toString().isEmpty) {
      return DateFormat('MMM yyyy').format(DateTime.now());
    }

    try {
      DateTime parsed = DateFormat("MMM dd, yyyy").parse(rawDate.toString());
      return DateFormat('MMM yyyy').format(parsed);
    } catch (_) {
      try {
        DateTime parsed = DateTime.parse(rawDate.toString());
        return DateFormat('MMM yyyy').format(parsed);
      } catch (_) {
        return rawDate.toString();
      }
    }
  }

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

  Future<void> submitReview() async {
    final String hId = (hotel["hotel_id"] ?? hotel["id"] ?? hotel["_id"] ?? "")
        .toString();
    if (hId.isEmpty) {
      Get.snackbar("Error", "Invalid Hotel ID.");
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please write your review.");
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 1. Upload images to Cloudinary first
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        imageUrls = await reviewService.uploadImages(
          files: selectedImages,
          hotelId: hId,
        );
      }

      // 2. Build JSON matching the exact backend schema
      final Map<String, dynamic> data = {
        "cleanliness": categories["cleanliness"] ?? 5,
        "location": categories["location"] ?? 5,
        "staff": categories["staff"] ?? 5,
        "value": categories["value"] ?? categories["value_money"] ?? 5,
        "comment": reviewController.text.trim(),
        "images": imageUrls, // Array of uploaded Cloudinary URLs
        "stayed_date": stayedDateText, // e.g., "2026-07-29"
      };

      // 3. Post review payload
      final response = await reviewService.createReview(
        data: data,
        hotelId: hId,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response != null) {
        // Refresh active hotel detail & home views
        if (Get.isRegistered<HotelDetailScreenViewController>()) {
          Get.find<HotelDetailScreenViewController>().getHotelReviews();
        }
        if (Get.isRegistered<HomeScreenController>()) {
          Get.find<HomeScreenController>().getHotels();
        }

        Get.back(result: true);
        Get.snackbar(
          "Success",
          response["message"] ?? "Review submitted successfully.",
        );
      } else {
        Get.snackbar(
          "Error",
          response?["message"] ?? "Failed to submit review.",
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Error submitting hotel review: $e");
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }

  @override
  void onInit() {
    super.onInit();
    reviewController.addListener(() {
      reviewLength.value = reviewController.text.length;
    });
    hotel = Map<String, dynamic>.from(Get.arguments ?? {});
  }
}
