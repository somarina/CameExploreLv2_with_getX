import 'package:flutter/cupertino.dart';
import 'package:frontend/app/core/api/Model/user_model.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:frontend/app/core/api/services/category_service.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  var currentIndex = 0.obs;
  var authService = AuthServices();
  var isLoadingPf = false.obs;
  var isLoadingAvatar = false.obs;
  var isLoadingCategory = false.obs;
  var isLoadingPlaces = false.obs;
  final CategoryService categoryService = CategoryService();

  final PlacesServices placesService = PlacesServices();
  RxList categories = [].obs;
  RxList places = [].obs;
  Rxn<UserModel> user = Rxn<UserModel>();
  RxList trendingPlaces = [].obs;
  RxList topPlaces = [].obs;
  RxList nearbyPlaces = [].obs;

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

  Future<void> getProfile() async {
    try {
      isLoadingPf.value = true;
      var response = await authService.fetchProfile();
      user.value = UserModel.fromMap(response['data']);
    } finally {
      isLoadingPf.value = false;
    }
  }

  ImageProvider? getAvatar() {
    final user = this.user.value;
    if (user == null) return null;

    final avatar = user.avatar;

    if (avatar.isEmpty) return null;
    if (avatar.startsWith("http")) return NetworkImage(avatar);

    return null;
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
      } else if (response["data"] != null) {
        places.value = response["data"];
      }

      filterPlaces();
    } catch (e) {
      debugPrint(e.toString());
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

  // Fixed location
  // final double currentLat = 13.3618;
  // final double currentLng = 103.8606;

  // String currentLocation = "Siem Reap, Cambodia";
  final double currentLat = 11.5564;
  final double currentLng = 104.9282;

  String currentLocation = "Phnom Penh, Cambodia";

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

    /// Current province from currentLocation
    final currentProvince = currentLocation.split(",").first.trim();

    /// TOP PLACES: same province + rating >= 4.5
    topPlaces.value = allPlaces.where((p) {
      final province = (p["province"] ?? "").toString().trim();
      return province == currentProvince &&
          (p["rating"] ?? 0).toDouble() >= 4.5;
    }).toList()..sort((a, b) => (b["rating"] ?? 0).compareTo(a["rating"] ?? 0));

    /// NEARBY PLACES: within 10 km
    nearbyPlaces.value =
        allPlaces.where((p) {
          final distance = calculateDistance(p["latitude"], p["longitude"]);
          return distance < 10;
        }).toList()..sort((a, b) {
          final d1 = calculateDistance(a["latitude"], a["longitude"]);
          final d2 = calculateDistance(b["latitude"], b["longitude"]);
          return d1.compareTo(d2);
        });

    /// TRENDING: same province + rating >= 4.0
    trendingPlaces.value = allPlaces.where((p) {
      final province = (p["province"] ?? "").toString().trim();
      return province == currentProvince &&
          (p["rating"] ?? 0).toDouble() >= 4.0;
    }).toList()..sort((a, b) => (b["rating"] ?? 0).compareTo(a["rating"] ?? 0));

    topPlaces.value = topPlaces.take(10).toList();
    nearbyPlaces.value = nearbyPlaces.take(10).toList();
    trendingPlaces.value = trendingPlaces.take(10).toList();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getProfile();
    getAvatar();
    getCategories();
    getPlaces();
  }
}
