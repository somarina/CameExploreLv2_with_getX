part of 'detail_places_screen_view.dart';

class DetailPlacesScreenViewController extends GetxController {
  var currentIndex = 0.obs;
  var isExpanded = false.obs;
  // var homeCtrl = HomeScreenController();
  final HomeScreenController homeCtrl = Get.find<HomeScreenController>();
  late final Map<String, dynamic> place;
  late final DiscoverPlaceModel places;
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  final List<Map<String, String>> openingHours = [
    {"day": "monday", "time": "5am - 5pm"},
    {"day": "tuesday", "time": "5am - 5pm"},
    {"day": "wednesday", "time": "5am - 5pm"},
    {"day": "thursday", "time": "5am - 5pm"},
    {"day": "friday", "time": "5am - 5pm"},
    {"day": "saturday", "time": "5am - 5pm"},
    {"day": "sunday", "time": "5am - 5pm"},
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

  Future<void> openGoogleMaps() async {
    final latitude = double.tryParse(place['latitude'].toString());
    final longitude = double.tryParse(place['longitude'].toString());

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
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    place = Get.arguments;

    print("DETAIL KEYS:");
    place.forEach((key, value) {
      print("$key => $value");
    });
  }
}
