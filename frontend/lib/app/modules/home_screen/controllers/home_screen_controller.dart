import 'package:flutter/cupertino.dart';
import 'package:frontend/app/core/api/Model/user_model.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:frontend/app/core/api/services/category_service.dart';
import 'package:frontend/app/core/api/services/hotels_services.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:frontend/app/core/api/services/review_hotel_services.dart';
import 'package:frontend/app/core/api/services/travel_package_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  // final favoriteController = Get.find<FavoriteScreenController>();

  var currentIndex = 0.obs;
  var authService = AuthServices();
  var isLoadingPf = false.obs;
  var isLoadingCategory = false.obs;
  var isLoadingPlaces = false.obs;

  final CategoryService categoryService = CategoryService();
  bool get isKhmer => Get.locale?.languageCode == "kmKH";
  

  final PlacesServices placesService = PlacesServices();
  RxList categories = [].obs;
  RxList places = [].obs;
  Rxn<UserModel> user = Rxn<UserModel>();
  RxList trendingPlaces = [].obs;
  RxList topPlaces = [].obs;
  RxList nearbyPlaces = [].obs;

  final HotelServices hotelService = HotelServices();
  var isLoadingHotels = false.obs;
  RxList hotels = [].obs;
  final HotelReviewServices _reviewService = HotelReviewServices();
  final TravelPackageServices travelPackageServices = TravelPackageServices();
  final RxList packages = <dynamic>[].obs;
  final RxBool isLoadingPackages = false.obs;

  var reviewsList = <dynamic>[].obs;
  var isLoadingReviews = false.obs;
  var reviewSummary = <String, dynamic>{}.obs;

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
              try {
                final reviewRes = await _reviewService.fetchReviews(hotelId);
                if (reviewRes != null &&
                    reviewRes["result"] == true &&
                    reviewRes["data"] != null) {
                  final summary = reviewRes["data"]["summary"];
                  if (summary != null) {
                    hotelMap["overall_score"] =
                        double.tryParse(summary["overall"].toString()) ?? 0.0;
                    hotelMap["review_count"] =
                        int.tryParse(summary["review_count"].toString()) ??
                        hotelMap["review_count"] ??
                        0;
                  }
                }
              } catch (e) {
                debugPrint("Error fetching reviews for hotel $hotelId: $e");
              }
            }
            return hotelMap;
          }),
        );

        hotels.assignAll(updatedItems);
      }
    } catch (e) {
      debugPrint("Get Hotels Error: $e");
    } finally {
      isLoadingHotels.value = false;
    }
  }

  Future<void> getPackages() async {
    try {
      isLoadingPackages.value = true;
      final response = await TravelPackageServices().fetchTravelPackages();

      if (response != null && response["result"] == true) {
        packages.assignAll(response["data"]["items"]);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoadingPackages.value = false;
    }
  }

  ImageProvider? getAvatar() {
    final u = user.value;

    if (u == null || u.avatar.isEmpty) {
      return null;
    }

    if (u.avatar.startsWith("http")) {
      return NetworkImage(u.avatar);
    }

    return null;
  }

  Future<void> getProfile() async {
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
      debugPrint("Get Places Error: ${e.toString()}");
    } finally {
      isLoadingPlaces.value = false;
    }
  }
  // Rxn<Position> userPosition = Rxn<Position>();

  // RxString currentLocation = "Getting location...".obs;

  // Future<void> getCurrentLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  //   if (!serviceEnabled) return;

  //   LocationPermission permission = await Geolocator.checkPermission();

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }

  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     return;
  //   }

  //   userPosition.value = await Geolocator.getCurrentPosition();
  //   update();

  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     userPosition.value!.latitude,
  //     userPosition.value!.longitude,
  //   );

  //   if (placemarks.isNotEmpty) {
  //     final place = placemarks.first;
  //     currentLocation.value =
  //         "${place.locality ?? place.subAdministrativeArea}, ${place.country}";
  //   }
  // }

  // String calculateDistance(dynamic placeLat, dynamic placeLng) {
  //   final userPos = userPosition.value;
  //   if (userPos == null) return "Loading...";

  //   try {
  //     double targetLat = double.parse(placeLat.toString());
  //     double targetLng = double.parse(placeLng.toString());

  //     double distance = Geolocator.distanceBetween(
  //       userPos.latitude,
  //       userPos.longitude,
  //       targetLat,
  //       targetLng,
  //     );

  //     return "${(distance / 1000).toStringAsFixed(1)} km";
  //   } catch (e) {
  //     return "N/A";
  //   }
  // }

  final double currentLat = 13.3618;
  final double currentLng = 103.8606;
  String currentLocation = "Siem Reap, Cambodia";

  double calculateDistance(dynamic placeLat, dynamic placeLng) {
    try {
      return Geolocator.distanceBetween(
            currentLat,
            currentLng,
            double.parse(placeLat.toString()),
            double.parse(placeLng.toString()),
          ) /
          1000;
    } catch (_) {
      return double.infinity;
    }
  }

  void filterPlaces() {
    if (places.isEmpty) return;

    final List allPlaces = List.from(places);
    final currentProvince = currentLocation.split(",").first.trim();

    topPlaces.value =
        allPlaces.where((p) {
          final province = (p["province"] ?? "").toString().trim();
          final double ratingStar =
              double.tryParse((p["rating_star"] ?? 0).toString()) ?? 0.0;
          return province == currentProvince && ratingStar >= 4.5;
        }).toList()..sort((a, b) {
          final r1 = double.tryParse((a["rating_star"] ?? 0).toString()) ?? 0.0;
          final r2 = double.tryParse((b["rating_star"] ?? 0).toString()) ?? 0.0;
          return r2.compareTo(r1);
        });

    nearbyPlaces.value =
        allPlaces.where((p) {
          final distance = calculateDistance(p["latitude"], p["longitude"]);
          return distance < 10.0;
        }).toList()..sort((a, b) {
          final d1 = calculateDistance(a["latitude"], a["longitude"]);
          final d2 = calculateDistance(b["latitude"], b["longitude"]);
          return d1.compareTo(d2);
        });

    trendingPlaces.value =
        allPlaces.where((p) {
          final province = (p["province"] ?? "").toString().trim();
          final double ratingStar =
              double.tryParse((p["rating_star"] ?? 0).toString()) ?? 0.0;
          return province == currentProvince && ratingStar >= 4.0;
        }).toList()..sort((a, b) {
          final r1 = double.tryParse((a["rating_star"] ?? 0).toString()) ?? 0.0;
          final r2 = double.tryParse((b["rating_star"] ?? 0).toString()) ?? 0.0;
          return r2.compareTo(r1);
        });

    topPlaces.value = topPlaces.take(10).toList();
    nearbyPlaces.value = nearbyPlaces.take(5).toList();
    trendingPlaces.value = trendingPlaces.take(10).toList();
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
  Map<String, dynamic> convertPlace(Map place) {
    return {
      "id": place["id"],
      "name_en": place["nameEn"] ?? place["name"] ?? "",
      "name_km": place["nameKm"] ?? "",
      "description_en": place["description"] ?? "",
      "province": place["province"] ?? "",
      "image_url": place["imageUrl"] ?? place["image_url"] ?? "",
      "latitude": place["latitude"] ?? 0,
      "longitude": place["longitude"] ?? 0,
      "rating": place["rating"] ?? 0,
      "phoneNum": place["phoneNum"],
    };
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    
    getProfile();
    getAvatar();
    getCategories();
    getPlaces();
    getHotels();
    getPackages();

    await favoriteController.loadFavoriteStatus();
  }
}
