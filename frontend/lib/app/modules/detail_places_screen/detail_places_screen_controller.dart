part of 'detail_places_screen_view.dart';

class DetailPlacesScreenViewController extends GetxController {
  var currentIndex = 0.obs;
  var isExpanded = false.obs;
  var homeCtrl = HomeScreenController();
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  final List<Map<String, String>> openingHours = [
    {"day": "Monday", "time": "5am - 5pm"},
    {"day": "Tuesday", "time": "5am - 5pm"},
    {"day": "Wednesday", "time": "5am -5pm"},
    {"day": "Thursday", "time": "5am - 5pm"},
    {"day": "Friday", "time": "5am - 5pm"},
    {"day": "Saturday", "time": "5am - 5pm"},
    {"day": "Sunday", "time": "5am - 5pm"},
  ];

  String get today {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[DateTime.now().weekday - 1];
  }
}
