part of 'hotel_detail_screen_view.dart';

class HotelDetailScreenViewController extends GetxController {
  final currentIndex = 0.obs;
  final HotelReviewServices _reviewService = HotelReviewServices();
  late Map<String, dynamic> hotel;
  final reviews = <dynamic>[].obs;
  final isLoading = false.obs;
  final overallScore = 0.0.obs;
  final reviewCount = 0.obs;
  final breakdown = <String, dynamic>{}.obs;
  var reviewsList = <dynamic>[].obs;

  final nearbyPlaces = <Map<String, dynamic>>[].obs;
  final trendingPlaces = <Map<String, dynamic>>[].obs;
  final isPlacesLoading = false.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> openGoogleMaps() async {
    final latitude = double.tryParse(hotel['latitude'].toString());
    final longitude = double.tryParse(hotel['longitude'].toString());

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

  String get hotelName {
    final isKhmer = Get.locale?.languageCode.startsWith("km") ?? false;

    return isKhmer
        ? hotel["name_km"] ?? hotel["name_en"]
        : hotel["name_en"] ?? "";
  }

  String get address {
    final isKhmer = Get.locale?.languageCode.startsWith("km") ?? false;

    return isKhmer ? hotel["address_km"] ?? "" : hotel["address_en"] ?? "";
  }

  List<String> get images => List<String>.from(hotel["images"] ?? []);

  List get amenities => hotel["amenities"] ?? [];

  List get rooms => hotel["room_types"] ?? [];

  @override
  void onInit() {
    super.onInit();

    hotel = Get.arguments ?? {};
    overallScore.value =
        double.tryParse((hotel["star_rating"] ?? 0.0).toString()) ?? 0.0;
    reviewCount.value =
        int.tryParse((hotel["review_count"] ?? 0).toString()) ?? 0;

    getHotelReviews();
    fetchNearbyAndTrendingPlaces();
  }

  /// Calculates straight-line distance in kilometers using the Haversine formula
  double _calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String _formatDistance(double distanceInKm) {
    final isKhmer = Get.locale?.languageCode.startsWith("km") ?? false;

    if (distanceInKm < 1.0) {
      final meters = (distanceInKm * 1000).round();
      return isKhmer ? "$meters ម៉ែត្រ" : "$meters m";
    } else {
      final formatted = distanceInKm.toStringAsFixed(1);
      return isKhmer ? "$formatted គ.ម" : "$formatted km";
    }
  }

  Future<void> fetchNearbyAndTrendingPlaces() async {
    final hotelLat = double.tryParse(hotel['latitude']?.toString() ?? '');
    final hotelLng = double.tryParse(hotel['longitude']?.toString() ?? '');

    if (hotelLat == null || hotelLng == null) return;

    try {
      isPlacesLoading.value = true;

      final homeController = Get.find<HomeScreenController>();
      final List rawPlaces = homeController.places;

      if (rawPlaces.isEmpty) return;

      final processedPlaces = rawPlaces.map((item) {
        final Map<String, dynamic> place = Map<String, dynamic>.from(item);

        final pLat =
            double.tryParse(place['latitude']?.toString() ?? '0.0') ?? 0.0;
        final pLng =
            double.tryParse(place['longitude']?.toString() ?? '0.0') ?? 0.0;

        final distanceKm = _calculateDistanceInKm(
          hotelLat,
          hotelLng,
          pLat,
          pLng,
        );

        return {
          ...place,
          'distance_km': distanceKm,
          'distance': _formatDistance(distanceKm),
        };
      }).toList();

      final sortedNearby =
          processedPlaces.where((p) {
            final distance = p['distance_km'] as double;
            return distance > 0.001 && distance <= 15.0;
          }).toList()..sort(
            (a, b) => (a['distance_km'] as double).compareTo(
              b['distance_km'] as double,
            ),
          );

      nearbyPlaces.assignAll(sortedNearby.take(10));

      final sortedTrending =
          processedPlaces.where((p) {
            final rating =
                double.tryParse(
                  (p['rating_star'] ?? p['rating'] ?? 0).toString(),
                ) ??
                0.0;
            final distanceKm = p['distance_km'] as double;
            return rating >= 4.0 && distanceKm <= 25.0;
          }).toList()..sort((a, b) {
            final r1 =
                double.tryParse((a['rating_star'] ?? 0).toString()) ?? 0.0;
            final r2 =
                double.tryParse((b['rating_star'] ?? 0).toString()) ?? 0.0;
            return r2.compareTo(r1);
          });

      trendingPlaces.assignAll(sortedTrending.take(10));
    } catch (e) {
      print("[GETX DETAILS] Error calculating distances: $e");
    } finally {
      isPlacesLoading.value = false;
    }
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
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(parsedDate);
    } catch (_) {
      try {
        final DateTime parsedDate = DateFormat('MMM yyyy').parse(dateStr);
        return DateFormat('dd-MMM-yyyy').format(parsedDate);
      } catch (_) {
        return dateStr;
      }
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

  void showNearbyBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "nearby_poplular".tr,
              style: GoogleFonts.googleSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey.shade400),

            Expanded(
              child: Obx(() {
                if (isPlacesLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (trendingPlaces.isNotEmpty) ...[
                      _buildSectionTitle(context, "trending".tr),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: trendingPlaces.length,
                        itemBuilder: (_, index) =>
                            _buildPlaceItem(context, trendingPlaces[index]),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (nearbyPlaces.isNotEmpty) ...[
                      _buildSectionTitle(context, "near_places".tr),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: nearbyPlaces.length,
                        itemBuilder: (_, index) =>
                            _buildPlaceItem(context, nearbyPlaces[index]),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.googleSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildPlaceItem(BuildContext context, Map<String, dynamic> place) {
    final isKhmer = Get.locale?.languageCode.startsWith("km") ?? false;

    final placeName = isKhmer
        ? (place["name_km"] ?? place["name_en"] ?? place["name"] ?? "")
        : (place["name_en"] ?? place["name"] ?? "");

    final String formattedDistance = (place["distance"] ?? "").toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(Routes.DETAIL_PLACES, arguments: place);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.place,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  placeName,
                  style: GoogleFonts.googleSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
              ),
              if (formattedDistance.isNotEmpty) ...[
                Text(
                  formattedDistance,
                  style: GoogleFonts.googleSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Theme.of(context).textTheme.titleSmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}