import 'package:flutter/cupertino.dart';
import 'package:frontend/app/core/api/Model/user_model.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:frontend/app/core/api/services/category_service.dart';
import 'package:frontend/app/core/api/services/hotels_services.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/core/api/services/review_hotel_services.dart';
import 'package:frontend/app/core/api/services/travel_package_services.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeScreenController extends GetxController {
  final favoriteController = Get.find<FavoriteScreenController>();
  final _box = GetStorage();
  bool get isGuest => _box.read('userMode') == 'guest';

  var currentIndex = 0.obs;
  var authService = AuthServices();
  var isLoadingPf = false.obs;
  var isLoadingCategory = false.obs;
  var isLoadingPlaces = false.obs;

  RxList foodPlaces = [].obs;
  RxList restaurantPlaces = [].obs;

  final CategoryService categoryService = CategoryService();
  bool get isKhmer => Get.locale?.languageCode == "kmKH";

  final PlacesServices placesService = PlacesServices();
  RxList categories = [].obs;
  RxList places = [].obs;
  Rxn<UserModel> user = Rxn<UserModel>();
  RxList trendingPlaces = [].obs;
  RxList topPlaces = [].obs;
  RxList nearbyPlaces = [].obs;

  // --- Hotel State ---
  final HotelServices hotelService = HotelServices();
  var isLoadingHotels = false.obs;
  RxList hotels = [].obs;
  RxList filteredHotels = [].obs; // <--- Filtered hotels by province

  // --- Package State ---
  final TravelPackageServices travelPackageServices = TravelPackageServices();
  final RxList packages = <dynamic>[].obs;
  final RxList filteredPackages =
      <dynamic>[].obs; // <--- Filtered packages by province
  final RxBool isLoadingPackages = false.obs;

  final HotelReviewServices _reviewService = HotelReviewServices();
  var reviewsList = <dynamic>[].obs;
  var isLoadingReviews = false.obs;
  var reviewSummary = <String, dynamic>{}.obs;

  // --- Dynamic Location State ---
  Rxn<Position> userPosition = Rxn<Position>();
  RxString currentLocation = "Locating...".obs;
  RxBool isLoadingLocation = false.obs;

  List<String> imgList = [
    'assets/images/homescreen/slider1.png',
    'assets/images/homescreen/slider2.png',
    'assets/images/homescreen/slider3.png',
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  final favorites = List.generate(20, (_) => false).obs;

  void toggleFavorite(int index) {
    favorites[index] = !favorites[index];
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = "Location Disabled";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = "Permission Denied";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentLocation.value = "Permission Permanently Denied";
        return;
      }

      // Fetch accurate GPS position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      userPosition.value = position;

      // Reverse-geocode to extract city/province and country
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city =
            place.administrativeArea ??
            place.locality ??
            place.subAdministrativeArea ??
            "";
        final country = place.country ?? "";

        currentLocation.value = city.isNotEmpty
            ? "$city, $country"
            : "Current Location";
      }

      // Re-filter all collections when location is updated
      if (places.isNotEmpty) {
        filterPlaces();
      }
      if (hotels.isNotEmpty) {
        filterHotels();
      }
      if (packages.isNotEmpty) {
        filterPackages();
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      currentLocation.value = "Location Unavailable";
    } finally {
      isLoadingLocation.value = false;
    }
  }

  double calculateDistance(dynamic targetLat, dynamic targetLng) {
    final pos = userPosition.value;
    if (pos == null) return double.infinity;

    try {
      double lat = double.parse(targetLat.toString());
      double lng = double.parse(targetLng.toString());

      return Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng) /
          1000;
    } catch (_) {
      return double.infinity;
    }
  }

  String getFormattedDistance(dynamic targetLat, dynamic targetLng) {
    final km = calculateDistance(targetLat, targetLng);
    if (km == double.infinity) return "N/A";
    return "${km.toStringAsFixed(1)} km";
  }

  // --- Place Filters ---
  void filterPlaces() {
    if (places.isEmpty) return;

    final List allPlaces = List.from(places);
    final String rawProvince = currentLocation.value
        .split(",")
        .first
        .trim()
        .toLowerCase();

    final bool isLocationUnknown =
        rawProvince.isEmpty ||
        currentLocation.value.startsWith("Locating") ||
        currentLocation.value.startsWith("Location");

    // 1. Trending Places: Exclude Restaurant, Food, and Hotel
    final Set<String> excludedCategories = {
      "restaurant",
      "food",
      "hotel",
      "សណ្ឋាគារ",
      "ម្ហូប",
      "ភោជនីយដ្ឋាន",
    };

    trendingPlaces.value =
        allPlaces.where((p) {
          final String category = (p["category"] ?? "")
              .toString()
              .trim()
              .toLowerCase();
          final String categoryKm = (p["category_km"] ?? "")
              .toString()
              .trim()
              .toLowerCase();
          final String province = (p["province"] ?? p["province_en"] ?? "")
              .toString()
              .trim()
              .toLowerCase();
          final String provinceKm = (p["province_km"] ?? "")
              .toString()
              .trim()
              .toLowerCase();

          final bool isExcluded =
              excludedCategories.contains(category) ||
              excludedCategories.contains(categoryKm);

          final double ratingStar =
              double.tryParse(
                (p["rating_star"] ?? p["rating"] ?? 0).toString(),
              ) ??
              0.0;

          final bool matchesLocation =
              isLocationUnknown ||
              province.contains(rawProvince) ||
              provinceKm.contains(rawProvince);

          return !isExcluded && matchesLocation && ratingStar >= 0.0;
        }).toList()..sort((a, b) {
          final r1 =
              double.tryParse(
                (a["rating_star"] ?? a["rating"] ?? 0).toString(),
              ) ??
              0.0;
          final r2 =
              double.tryParse(
                (b["rating_star"] ?? b["rating"] ?? 0).toString(),
              ) ??
              0.0;
          return r2.compareTo(r1);
        });

    // 2. Restaurant Places: Only Restaurant category + current location filter
    restaurantPlaces.value = allPlaces.where((p) {
      final String category = (p["category"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String categoryKm = (p["category_km"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String province = (p["province"] ?? p["province_en"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String provinceKm = (p["province_km"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String address = (p["address"] ?? p["address_en"] ?? "")
          .toString()
          .trim()
          .toLowerCase();

      final bool isRestaurant =
          category == "restaurant" || categoryKm == "ភោជនីយដ្ឋាន";

      if (!isRestaurant) return false;
      if (isLocationUnknown) return true;

      return province.contains(rawProvince) ||
          provinceKm.contains(rawProvince) ||
          address.contains(rawProvince);
    }).toList();

    // 3. Nearby places within 10 km
    nearbyPlaces.value =
        allPlaces.where((p) {
          final distance = calculateDistance(p["latitude"], p["longitude"]);
          return distance < 10.0;
        }).toList()..sort((a, b) {
          final d1 = calculateDistance(a["latitude"], a["longitude"]);
          final d2 = calculateDistance(b["latitude"], b["longitude"]);
          return d1.compareTo(d2);
        });

    // 4. Food places
    foodPlaces.value = allPlaces.where((p) {
      final category = (p["category"] ?? "").toString().trim().toLowerCase();
      final categoryKm = (p["category_km"] ?? "").toString().trim();
      return category == "food" || categoryKm == "ម្ហូប";
    }).toList();

    // Limit collection sizes for UI performance
    trendingPlaces.value = trendingPlaces.take(10).toList();
    restaurantPlaces.value = restaurantPlaces.take(10).toList();
    nearbyPlaces.value = nearbyPlaces.take(6).toList();
    foodPlaces.value = foodPlaces.take(10).toList();
  }

  // --- Hotel Filters & Distance Sorting ---
  void filterHotels() {
    if (hotels.isEmpty) return;

    final String rawProvince = currentLocation.value
        .split(",")
        .first
        .trim()
        .toLowerCase();

    final bool isLocationUnknown =
        rawProvince.isEmpty ||
        currentLocation.value.startsWith("Locating") ||
        currentLocation.value.startsWith("Location");

    // 1. Filter by province/location
    List<dynamic> filteredList = hotels.where((h) {
      if (isLocationUnknown) return true;

      final String province = (h["province"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String provinceKm = (h["province_km"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String provinceEn = (h["province_en"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String address = (h["address"] ?? h["address_en"] ?? "")
          .toString()
          .trim()
          .toLowerCase();

      return province.isEmpty ||
          province == rawProvince ||
          provinceKm == rawProvince ||
          provinceEn == rawProvince ||
          address.contains(rawProvince);
    }).toList();

    // 2. Sort nearest to farthest using calculateDistance()
    filteredList.sort((a, b) {
      final double distA = calculateDistance(a["latitude"], a["longitude"]);
      final double distB = calculateDistance(b["latitude"], b["longitude"]);
      return distA.compareTo(distB);
    });

    // 3. Assign to RxList and force GetX reactivity update
    filteredHotels.value = filteredList;
    filteredHotels.refresh();
  }

  // --- Package Filters ---
  void filterPackages() {
    if (packages.isEmpty) return;

    final currentProvince = currentLocation.value
        .split(",")
        .first
        .trim()
        .toLowerCase();

    // Fall back to showing all packages only if location is uninitialized
    if (currentProvince.isEmpty ||
        currentLocation.value.startsWith("Locating") ||
        currentLocation.value.startsWith("Location")) {
      filteredPackages.assignAll(packages);
      return;
    }

    filteredPackages.value = packages.where((pkg) {
      final String province =
          (pkg["province"] ?? pkg["destination_province"] ?? "")
              .toString()
              .trim()
              .toLowerCase();
      final String provinceKm = (pkg["province_km"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String provinceEn = (pkg["province_en"] ?? "")
          .toString()
          .trim()
          .toLowerCase();
      final String location =
          (pkg["location"] ?? pkg["address_en"] ?? pkg["address"] ?? "")
              .toString()
              .trim()
              .toLowerCase();
      final String name = (pkg["name_en"] ?? pkg["name_km"] ?? "")
          .toString()
          .trim()
          .toLowerCase();

      // Check if current province matches any location field or package title
      final bool matchesProvince =
          province == currentProvince ||
          provinceKm == currentProvince ||
          provinceEn == currentProvince;

      final bool matchesLocationString =
          location.contains(currentProvince) || name.contains(currentProvince);

      return matchesProvince || matchesLocationString;
    }).toList();
  }

  Future<void> fetchReviews(String placeId) async {
    try {
      isLoadingReviews.value = true;
      final response = await _reviewService.fetchReviews(placeId);

      if (response != null && response['result'] == true) {
        final data = response['data'];
        reviewsList.assignAll(data['items'] ?? []);
        reviewSummary.assignAll(data['summary'] ?? {});
      }
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> getHotels() async {
    try {
      isLoadingHotels.value = true;
      final response = await hotelService.fetchHotels();

      if (response != null && response["result"] == true) {
        final List<dynamic> loadedItems = response["data"]["items"] ?? [];

        final List<dynamic> updatedItems = await Future.wait(
          loadedItems.map((item) async {
            final hotelMap = Map<String, dynamic>.from(item as Map);
            final String hotelId =
                (hotelMap["id"] ??
                        hotelMap["_id"] ??
                        hotelMap["hotel_id"] ??
                        "")
                    .toString();

            if (hotelId.isNotEmpty) {
              final reviewData = await _fetchReviewSummary(hotelId);
              hotelMap.addAll(reviewData);
            }
            return hotelMap;
          }),
        );

        hotels.assignAll(updatedItems);
        filterHotels(); // Filter after fetching
      }
    } catch (e) {
      debugPrint("Get Hotels Error: $e");
    } finally {
      isLoadingHotels.value = false;
    }
  }

  Future<Map<String, dynamic>> _fetchReviewSummary(String hotelId) async {
    try {
      final reviewRes = await _reviewService.fetchReviews(hotelId);
      if (reviewRes != null &&
          reviewRes["result"] == true &&
          reviewRes["data"] != null) {
        final summary = reviewRes["data"]["summary"];
        if (summary != null) {
          return {
            "overall_score":
                double.tryParse(summary["overall"].toString()) ?? 0.0,
            "review_count":
                int.tryParse(summary["review_count"].toString()) ?? 0,
          };
        }
      }
    } catch (e) {
      debugPrint("Error fetching reviews for hotel $hotelId: $e");
    }
    return {};
  }

  Future<void> getPackages() async {
    try {
      isLoadingPackages.value = true;
      final response = await travelPackageServices.fetchTravelPackages();

      if (response != null && response["result"] == true) {
        packages.assignAll(response["data"]["items"] ?? []);
        filterPackages(); // Filter after fetching
      }
    } catch (e) {
      debugPrint("Get Packages Error: $e");
    } finally {
      isLoadingPackages.value = false;
    }
  }

  ImageProvider? getAvatar() {
    final u = user.value;
    if (u == null || u.avatar.isEmpty) return null;
    if (u.avatar.startsWith("http")) return NetworkImage(u.avatar);
    return null;
  }

  Future<void> getProfile() async {
    if (isGuest) {
      user.value = null;
      return;
    }
    try {
      isLoadingPf.value = true;
      var response = await authService.fetchProfile();
      if (response['data'] != null) {
        user.value = UserModel.fromMap(response['data']);
      }
    } catch (e) {
      debugPrint("Get Profile Error: $e");
    } finally {
      isLoadingPf.value = false;
    }
  }

  Future<void> getCategories() async {
    try {
      isLoadingCategory.value = true;
      final response = await categoryService.getCategories();

      if (response["result"] == true) {
        categories.value = response["data"] ?? [];
      }
    } catch (e) {
      debugPrint("Get Categories Error: $e");
    } finally {
      isLoadingCategory.value = false;
    }
  }

  Future<void> getPlaces() async {
    try {
      isLoadingPlaces.value = true;
      final response = await placesService.fetchPlaces();

      if (response is List) {
        places.value = response;
      } else if (response != null &&
          response["data"] != null &&
          response["data"]["items"] != null) {
        places.value = response["data"]["items"];
      }

      filterPlaces();
    } catch (e) {
      debugPrint("Get Places Error: $e");
    } finally {
      isLoadingPlaces.value = false;
    }
  }

  String getPlaceName(Map place) {
    return isKhmer
        ? (place["name_km"] ?? place["name_en"] ?? "")
        : (place["name_en"] ?? "");
  }

  String getDescription(Map place) {
    return isKhmer
        ? (place["description_km"] ?? place["description_en"] ?? "")
        : (place["description_en"] ?? "");
  }

  String getCategory(Map place) {
    return isKhmer
        ? (place["category_km"] ?? place["category"] ?? "")
        : (place["category"] ?? "");
  }

  String getAddress(Map place) {
    return isKhmer
        ? (place["address_km"] ?? place["address_en"] ?? "")
        : (place["address_en"] ?? "");
  }

  String getProvince(Map place) {
    return isKhmer
        ? (place["province_km"] ?? place["province"] ?? "")
        : (place["province"] ?? "");
  }

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    getProfile();
    getCategories();
    getPlaces();
    getHotels();
    getPackages();
  }
}
