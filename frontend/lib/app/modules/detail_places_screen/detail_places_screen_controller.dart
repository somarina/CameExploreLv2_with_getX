part of 'detail_places_screen_view.dart';

class DetailPlacesScreenViewController extends GetxController {
  final HomeScreenController homeCtrl = Get.find<HomeScreenController>();
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

    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic>) {
        place.assignAll(Get.arguments);
      } else if (Get.arguments is Map) {
        place.assignAll(Map<String, dynamic>.from(Get.arguments));
      } else if (Get.arguments is List && (Get.arguments as List).isNotEmpty) {
        final firstItem = Get.arguments[0];
        if (firstItem is Map) {
          place.assignAll(Map<String, dynamic>.from(firstItem));
        }
      }

      filterPlaces();
      fetchReviews();
    }
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

  /// Filters items from homeCtrl:
  /// - If current place is FOOD: shows ONLY recommended Food items.
  /// - If current place is LOCATION: shows nearby places (excluding Food).
  void filterPlaces() {
    if (homeCtrl.places.isEmpty || place.isEmpty) return;

    isLoadingPlaces.value = true;

    final baseLat = place["latitude"];
    final baseLng = place["longitude"];
    final currentId = place["id"] ?? place["_id"];

    // Check if current place belongs to Food category
    final currentCategory = getCategory(place).trim().toLowerCase();
    final bool isCurrentPlaceFood =
        currentCategory == "food" ||
        currentCategory == "អាហារ" ||
        currentCategory == "ម្ហូប";

    List<Map<String, dynamic>> filtered = [];

    for (var item in homeCtrl.places) {
      Map<String, dynamic> p;
      if (item is Map<String, dynamic>) {
        p = item;
      } else if (item is Map) {
        p = Map<String, dynamic>.from(item);
      } else {
        continue;
      }

      // 1. Exclude the current item itself
      final pId = p["id"] ?? p["_id"];
      if (currentId != null &&
          pId != null &&
          currentId.toString() == pId.toString()) {
        continue;
      }

      // 2. Safe Category Checking
      String rawName = "";
      String rawNameKm = "";

      final cat = p["category"];
      if (cat is Map) {
        rawName = cat["name"]?.toString().trim().toLowerCase() ?? "";
        rawNameKm = cat["name_km"]?.toString().trim() ?? "";
      } else if (cat is List && cat.isNotEmpty) {
        final firstCat = cat.first;
        if (firstCat is Map) {
          rawName = firstCat["name"]?.toString().trim().toLowerCase() ?? "";
          rawNameKm = firstCat["name_km"]?.toString().trim() ?? "";
        }
      }

      final itemCategory = getCategory(p).trim().toLowerCase();
      final bool isItemFood =
          itemCategory == "food" ||
          itemCategory == "អាហារ" ||
          itemCategory == "ម្ហូប" ||
          rawName == "food" ||
          rawNameKm == "អាហារ" ||
          rawNameKm == "ម្ហូប";

      // 3. Category Logic Switch:
      if (isCurrentPlaceFood) {
        // Current place IS Food -> Only keep OTHER Food items
        if (!isItemFood) continue;
      } else {
        // Current place IS NOT Food -> Exclude Food items
        if (isItemFood) continue;
      }

      // 4. Calculate Distance
      final distance = calculateDistance(
        baseLat,
        baseLng,
        p["latitude"],
        p["longitude"],
      );

      // (Optional) Distance constraint: If current place is food, take all foods; otherwise, within 10 km.
      if (isCurrentPlaceFood || distance < 10.0) {
        filtered.add(p);
      }
    }

    // Sort by distance or rating
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

  // Safe Getters to prevent List vs Map indexing crashes
  List<String> get tags {
    final rawTags = place["tags"];
    if (rawTags is List) {
      return rawTags
          .map((e) => e is Map ? (e["name"] ?? "").toString() : e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  List<String> get images {
    final rawImages = place["images"];
    if (rawImages is List) {
      return rawImages
          .map((e) => e is Map ? (e["url"] ?? "").toString() : e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  String get openingHours => place["opening_hours"]?.toString().trim() ?? "N/A";

  /// Helper map to easily compare weekday indexes (1 to 7)
  static const Map<String, int> _dayIndexMap = {
    "monday": 1,
    "tuesday": 2,
    "wednesday": 3,
    "thursday": 4,
    "friday": 5,
    "saturday": 6,
    "sunday": 7,
  };

  /// Parse the API string to construct opening hours for every day
  List<Map<String, String>> get weeklyOpeningHours {
    final raw = openingHours;

    if (raw.isEmpty || raw == "N/A") {
      return [];
    }

    // Regex to extract time (e.g., "09:00 - 18:00") and optional day range (e.g., "Tuesday - Sunday")
    final regExp = RegExp(r'^([\d:\s\-]+|\w+)(?:\s*\((.*?)\))?$');
    final match = regExp.firstMatch(raw);

    if (match == null) {
      // Fallback if parsing fails
      return _defaultWeeklyHours(raw);
    }

    final timePart = match.group(1)?.trim() ?? raw;
    final daysPart = match.group(2)?.toLowerCase().trim();

    // If no day constraint is provided in parentheses, assume open every day
    if (daysPart == null || daysPart.isEmpty) {
      return _defaultWeeklyHours(timePart);
    }

    // Handle day ranges like "tuesday - sunday"
    int startDay = 1;
    int endDay = 7;

    if (daysPart.contains('-')) {
      final parts = daysPart.split('-').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        startDay = _dayIndexMap[parts[0]] ?? 1;
        endDay = _dayIndexMap[parts[1]] ?? 7;
      }
    }

    const days = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ];

    return List.generate(7, (index) {
      final dayName = days[index];
      final dayNum = index + 1; // 1 = Monday, 7 = Sunday

      // Check if dayNum falls within [startDay, endDay]
      bool isOpen;
      if (startDay <= endDay) {
        isOpen = dayNum >= startDay && dayNum <= endDay;
      } else {
        // Handles wraparound ranges like "Friday - Tuesday"
        isOpen = dayNum >= startDay || dayNum <= endDay;
      }

      return {
        "day": dayName,
        "time": isOpen
            ? timePart
            : "closed".tr, // Translate "closed" in your i18n
      };
    });
  }

  List<Map<String, String>> _defaultWeeklyHours(String time) {
    const days = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ];
    return days.map((day) => {"day": day, "time": time}).toList();
  }

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

  // Safe Forwarding Helpers to HomeScreenController
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
