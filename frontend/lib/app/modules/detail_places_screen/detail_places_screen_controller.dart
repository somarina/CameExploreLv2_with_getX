part of 'detail_places_screen_view.dart';

class DetailPlacesScreenViewController extends GetxController {
  final HomeScreenController homeCtrl = Get.find<HomeScreenController>();
  final FavoriteScreenController favCtrl = Get.find<FavoriteScreenController>();
  final PlaceReviewService _reviewService = PlaceReviewService();
  final ScrollController scrollController = ScrollController();

  final RxMap<String, dynamic> place = <String, dynamic>{}.obs;

  // UI State
  var currentIndex = 0.obs;
  var isExpanded = false.obs;
  var isLoadingPlaces = false.obs;

  // Review State
  var reviewsList = <dynamic>[].obs;
  var isLoadingReviews = false.obs;
  var reviewSummary = <String, dynamic>{}.obs;

  // Nearby Places State
  var nearbyPlaces = <dynamic>[].obs;
  var favorites = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      place.assignAll(Get.arguments);

      print("IMAGE:");
      print(place["image_url"]);

      print("DESCRIPTION:");
      print(place["description_en"]);


      filterPlaces();
      fetchReviews();
    }
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

  Future<void> fetchReviews() async {
    final placeId = place["id"] ?? place["_id"];
    if (placeId == null || placeId.toString().isEmpty) return;

    try {
      isLoadingReviews.value = true;
      final response = await _reviewService.fetchReviews(placeId.toString());

      if (response != null &&
          response['result'] == true &&
          response['data'] != null) {
        final data = response['data'];
        reviewsList.assignAll(data['items'] ?? []);
        reviewSummary.assignAll(data['summary'] ?? {});
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> navigateToWriteReview() async {
    final placeId = place["id"] ?? place["_id"];

    if (placeId != null && placeId.toString().isNotEmpty) {
      final result = await Get.toNamed(
        Routes.PACKAGE_REVIEW,
        arguments: {'id': placeId.toString(), 'type': ReviewType.place},
      );

      if (result == true) {
        fetchReviews();
      }
    } else {
      Get.snackbar("Error", "Package ID is missing.");
    }
  }

  double get rating =>
      (reviewSummary["overall"] ?? place["rating"] ?? 0).toDouble();

  int get reviewCount =>
      reviewSummary["review_count"] ?? place["review_count"] ?? 0;

  void updateSelectedPlace(Map<String, dynamic> newPlace) {
    place.assignAll(newPlace);
    currentIndex.value = 0;
    isExpanded.value = false;

    filterPlaces();
    fetchReviews();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Calculates distance (in kilometers) between two sets of GPS coordinates using the Haversine formula
  double calculateDistance(
    dynamic lat1,
    dynamic lon1,
    dynamic lat2,
    dynamic lon2,
  ) {
    final double? p1Lat = double.tryParse(lat1?.toString() ?? '');
    final double? p1Lon = double.tryParse(lon1?.toString() ?? '');
    final double? p2Lat = double.tryParse(lat2?.toString() ?? '');
    final double? p2Lon = double.tryParse(lon2?.toString() ?? '');

    if (p1Lat == null || p1Lon == null || p2Lat == null || p2Lon == null) {
      return 0.0;
    }

    const double earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(p2Lat - p1Lat);
    double dLon = _degreesToRadians(p2Lon - p1Lon);

    double radLat1 = _degreesToRadians(p1Lat);
    double radLat2 = _degreesToRadians(p2Lat);

    double a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.sin(dLon / 2) *
            Math.sin(dLon / 2) *
            Math.cos(radLat1) *
            Math.cos(radLat2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (Math.pi / 180.0);
  }

  /// Filters all places from homeCtrl based on proximity to THIS place
  void filterPlaces() {
    if (homeCtrl.places.isEmpty || place.isEmpty) return;

    isLoadingPlaces.value = true;

    final List allPlaces = List.from(homeCtrl.places);
    final baseLat = place["latitude"];
    final baseLng = place["longitude"];
    final currentId = place["id"] ?? place["_id"];

    // Filter places within 10 km of THIS detail place (excluding itself)
    List filtered = allPlaces.where((p) {
      final pId = p["id"] ?? p["_id"];
      if (currentId != null && pId == currentId) return false;

      final distance = calculateDistance(
        baseLat,
        baseLng,
        p["latitude"],
        p["longitude"],
      );
      return distance < 10.0;
    }).toList();

    // Sort by nearest distance
    filtered.sort((a, b) {
      final d1 = calculateDistance(
        baseLat,
        baseLng,
        a["latitude"],
        a["longitude"],
      );
      final d2 = calculateDistance(
        baseLat,
        baseLng,
        b["latitude"],
        b["longitude"],
      );
      return d1.compareTo(d2);
    });

    nearbyPlaces.value = filtered.take(10).toList();
    favorites.value = List<bool>.filled(nearbyPlaces.length, false);

    isLoadingPlaces.value = false;
  }

  void toggleFavorite(int index) {
    if (index >= 0 && index < favorites.length) {
      favorites[index] = !favorites[index];
    }
  }

  // Reactive Getters reading directly from place
  List<String> get tags => List<String>.from(place["tags"] ?? []);

  // List<String> get images => List<String>.from(place["images"] ?? []);
  
  List<String> get images {
  if (place["images"] != null) {
    return List<String>.from(place["images"]);
  }

  if (place["image_url"] != null &&
      place["image_url"].toString().isNotEmpty) {
    return [place["image_url"].toString()];
  }

  return [];
}

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  String get openingHours => place["opening_hours"]?.toString() ?? "N/A";

  List<Map<String, String>> get weeklyOpeningHours => [
    {"day": "monday", "time": openingHours},
    {"day": "tuesday", "time": openingHours},
    {"day": "wednesday", "time": openingHours},
    {"day": "thursday", "time": openingHours},
    {"day": "friday", "time": openingHours},
    {"day": "saturday", "time": openingHours},
    {"day": "sunday", "time": openingHours},
  ];

  String get today {
    const days = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ];

    return days[DateTime.now().weekday - 1];
  }

  String? get phone {
    final value = place['phoneNum']?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  // Helpers forwarding to HomeScreenController
  String getPlaceName(Map<String, dynamic> p) => homeCtrl.getPlaceName(p);
  String getAddress(Map<String, dynamic> p) => homeCtrl.getAddress(p);
  String getCategory(Map<String, dynamic> p) => homeCtrl.getCategory(p);

  Future<void> callPhone(String phone) async {
    phone = phone.replaceAll(' ', '');

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    final Uri uri = Uri(scheme: 'tel', path: '+855$phone');

    if (!await launchUrl(uri)) {
      Get.snackbar("Error", "Could not open phone dialer.");
    }
  }

  Future<void> openGoogleMaps() async {
    final latitude = double.tryParse(place['latitude']?.toString() ?? '');
    final longitude = double.tryParse(place['longitude']?.toString() ?? '');

    if (latitude == null || longitude == null) {
      Get.snackbar("Error", "Location is unavailable.");
      return;
    }

    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving",
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open Google Maps.");
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
