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
    if (overallScore.value == 0) {
      Get.snackbar("Error", "Please select an overall score.");
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please write your review.");
      return;
    }

    final String hId = (hotel["hotel_id"] ?? hotel["id"] ?? hotel["_id"] ?? "")
        .toString();
    if (hId.isEmpty) {
      Get.snackbar("Error", "Invalid Hotel ID.");
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      List<String> base64Images = [];

      for (File file in selectedImages) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        base64Images.add("data:image/jpeg;base64,$base64String");
      }

      final data = {
        "hotel_id": hId,
        "overall": overallScore.value,
        "cleanliness": categories["cleaniness"] ?? 0,
        "comfort": categories["comfort"] ?? 0,
        "location": categories["location"] ?? 0,
        "facilities": categories["facilities"] ?? 0,
        "staff": categories["staff"] ?? 0,
        "value": categories["value_money"] ?? 0,
        "comment": reviewController.text.trim(),
        "images": base64Images,
        "stayed_date": stayedDateText,
      };

      final response = await reviewService.createReview(
        data: data,
        hotelId: hId,
      );
      hotelDetailCtrl.getHotelReviews();
      homelCtrl.getHotels();


      if (Get.isDialogOpen ?? false) Get.back();

      if (response != null && response["result"] == true) {
        Get.back(result: true);
        Get.snackbar(
          "Success",
          response["message"] ?? "Review submitted successfully.",
        );
      } else {
        Get.snackbar(
          "Error",
          response?["message"] ?? "Failed to submit review. Server error.",
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", e.toString());
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
