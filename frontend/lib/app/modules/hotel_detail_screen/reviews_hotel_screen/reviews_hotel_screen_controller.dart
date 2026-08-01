part of 'reviews_hotel_screen_view.dart';

class ReviewsHotelScreenViewController extends GetxController {
  final HotelReviewServices _reviewService = HotelReviewServices();

  late final Map<String, dynamic> hotel;

  final reviews = <dynamic>[].obs;
  final isLoading = false.obs;

  // Reactive summary mappings
  final overallScore = 0.0.obs;
  final reviewCount = 0.obs;
  final breakdown = <String, dynamic>{}.obs;
  var reviewsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    hotel = Map<String, dynamic>.from(Get.arguments ?? {});

    getHotelReviews();
  }

  Future<void> getHotelReviews() async {
    final String hotelId = (hotel["id"] ?? hotel["hotel_id"] ?? "").toString();
    if (hotelId.isEmpty) return;

    try {
      isLoading.value = true;
      final response = await _reviewService.fetchReviews(hotelId);

      if (response != null &&
          response["result"] == true &&
          response["data"] != null) {
        final data = response["data"];

        if (data["items"] != null && data["items"] is List) {
          reviews.assignAll(data["items"]);
          reviewsList.assignAll(data["items"]);
        }

        if (data["summary"] != null) {
          final summary = data["summary"];
          overallScore.value =
              double.tryParse(summary["overall"].toString()) ?? 0.0;
          reviewCount.value =
              int.tryParse(summary["review_count"].toString()) ?? 0;

          if (summary["breakdown"] != null) {
            breakdown.assignAll(summary["breakdown"]);
          }
        }
      }
    } catch (e) {
      print("[GETX DETAILS] Error parsing reviews: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().trim().isEmpty) return "";

    final dateStr = rawDate.toString().trim();

    try {
      final parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (_) {}

    try {
      final parsedDate = DateFormat('MMM yyyy').parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(parsedDate);
    } catch (_) {}

    return dateStr;
  }

  String formatTimeAgo(String rawDate) {
    if (rawDate.trim().isEmpty) return "";

    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return "";

    // Manually add 7 hours offset to the parsed time
    final adjustedDate = parsedDate.add(const Duration(hours: 7));

    final difference = DateTime.now().difference(adjustedDate);

    if (difference.isNegative) return "just now";

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds.clamp(1, 60)}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "${weeks}w ago";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "${months}mo ago";
    } else {
      final years = (difference.inDays / 365).floor();
      return "${years}y ago";
    }
  }
}
