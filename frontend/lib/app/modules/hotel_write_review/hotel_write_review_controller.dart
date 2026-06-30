part of 'hotel_write_review_view.dart';

class WriteReviewScreenViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();
  final overallScore = 0.obs;

  final reviewController = TextEditingController();
  final reviewLength = 0.obs;

  final categories = <String, int>{
    "Cleanliness": 0,
    "Comfort": 0,
    "Location": 0,
    "Facilities": 0,
    "Staff": 0,
    "Value for money": 0,
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
        return "Poor";
      case 3:
        return "Fair";
      case 4:
        return "Good";
      case 5:
        return "Excellent";
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

  @override
  void onInit() {
    reviewController.addListener(() {
      reviewLength.value = reviewController.text.length;
    });
    super.onInit();
  }
}
