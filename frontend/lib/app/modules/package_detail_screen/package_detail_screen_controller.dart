part of 'package_detail_screen_view.dart';

class PackageDetailScreenViewController extends GetxController {
  final currentIndex = 0.obs;
  final isImportantExpanded = false.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  final adultCount = 1.obs;

  final showAvailability = false.obs;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final RxMap<String, dynamic> package = <String, dynamic>{}.obs;
  var reviewsList = <dynamic>[].obs;
  var isLoadingReviews = false.obs;
  var isLoading = false.obs; // Added missing reactive loading variable
  var reviewSummary = <String, dynamic>{}.obs;
  
  final PlaceReviewService _reviewService = PlaceReviewService();
  final TravelPackageServices _packageServices = TravelPackageServices(); // Added service dependency

  bool get isKhmer => Get.locale?.languageCode.startsWith("km") ?? false;

  String get packageName => isKhmer
      ? (package["name_km"] ?? package["name_en"] ?? "")
      : (package["name_en"] ?? package["name_km"] ?? "");

  String get description => isKhmer
      ? package["description_km"] ?? package["description_en"] ?? ""
      : package["description_en"] ?? "";

  double get price => (package["price_per_person"] ?? 0).toDouble();

  int get duration => package["duration_days"] ?? 0;

  int get maxPeople => package["max_people"] ?? 1;

  double get rating =>
      (reviewSummary["overall"] ?? package["rating"] ?? 0).toDouble();

  int get reviewCount =>
      reviewSummary["review_count"] ?? package["review_count"] ?? 0;
  String get image => package["image_url"] ?? "";

  List<String> get images => List<String>.from(package["images"] ?? []);

  List<String> get tags => List<String>.from(package["tags"] ?? []);

  List<Map<String, dynamic>> get itinerary =>
      List<Map<String, dynamic>>.from(package["itinerary"] ?? []);

  final selectedStartTime = "".obs;
  List<String> get startTimes => List<String>.from(package["start_time"] ?? []);

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic>) {
        package.assignAll(Map<String, dynamic>.from(Get.arguments));
      }
    }

    if (startTimes.isNotEmpty) {
      selectedStartTime.value = startTimes.first;
    }

    if (adultCount.value > maxPeople) {
      adultCount.value = maxPeople;
    }

    // Check if itinerary is empty and fetch package details from API
    final String packageId =
        (package["package_id"] ?? package["id"] ?? "").toString();

    if (itinerary.isEmpty && packageId.isNotEmpty) {
      fetchPackageDetails(packageId);
    }

    fetchReviews();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchPackageDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _packageServices.fetchTravelPackageById(id);
      if (response != null) {
  
        if (response is Map<String, dynamic>) {
          package.assignAll(response);
        }
      }
    } catch (e) {
      debugPrint("Error fetching package details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String get packageLocation {
    final String province = isKhmer
        ? (package["province_km"] ??
              package["province"] ??
              package["location_km"] ??
              package["address_km"] ??
              "")
        : (package["province_en"] ??
              package["province"] ??
              package["location_en"] ??
              package["address_en"] ??
              "");

    String locationName = province.trim();

    if (locationName.isEmpty) {
      final String title = packageName;
      if (title.contains(":")) {
        locationName = title.split(":").first.trim();
      } else if (title.contains("-")) {
        locationName = title.split("-").first.trim();
      } else {
        locationName = "";
      }
    }

    if (locationName.toLowerCase().contains("cambodia")) {
      return locationName;
    }

    return "$locationName, Cambodia";
  }

  Future<void> fetchReviews() async {
    final packageId = package["id"] ?? package["_id"];

    debugPrint("Package ID: $packageId");

    if (packageId == null || packageId.toString().isEmpty) {
      debugPrint("Package ID is empty");
      return;
    }

    try {
      isLoadingReviews.value = true;

      final response = await _reviewService.fetchReviews(
        packageId.toString(),
        type: ReviewType.package,
      );

      debugPrint("Review Response: $response");

      if (response != null &&
          (response["result"] == true || response["success"] == true) &&
          response["data"] != null) {
        final data = response["data"];

        if (data is Map<String, dynamic>) {
          final List rawItems = data["items"] ?? [];

          final itemsList = rawItems
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          reviewsList.assignAll(itemsList);

          if (data["summary"] != null) {
            reviewSummary.assignAll(Map<String, dynamic>.from(data["summary"]));
          }
        }

        debugPrint("reviewsList length = ${reviewsList.length}");
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> navigateToWriteReview() async {
    final packageId = package["id"] ?? package["_id"];

    if (packageId != null && packageId.toString().isNotEmpty) {
      final result = await Get.toNamed(
        Routes.PACKAGE_REVIEW,
        arguments: {'id': packageId.toString(), 'type': ReviewType.package},
      );

      if (result == true) {
        fetchReviews();
      }
    } else {
      Get.snackbar("Error", "Package ID is missing.");
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void increaseAdult(BuildContext context) {
    if (adultCount.value < maxPeople) {
      adultCount.value++;
    } else {
      Get.snackbar(
        "Limit Reached",
        "Maximum $maxPeople people are allowed.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void decreaseAdult() {
    if (adultCount.value > 1) {
      adultCount.value--;
    }
  }

  void checkAvailability() {
    if (selectedDate.value == null) {
      Get.snackbar(
        "select_date_err_title_".tr,
        "select_date_err_body_".tr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    showAvailability.value = true;
  }

  String get formattedDate {
    if (selectedDate.value == null) {
      return "select_date_package_".tr;
    }

    return DateFormat('dd MMMM yyyy').format(selectedDate.value!);
  }

  String get formattedTime {
    if (selectedTime.value == null) {
      return "starting_time_".tr;
    }

    return selectedTime.value!.format(Get.context!);
  }

  String formatTimeAgo(String rawDate) {
    if (rawDate.trim().isEmpty) return "";

    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return "";

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