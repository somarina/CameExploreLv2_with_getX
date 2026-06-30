part of 'choose_room_screen_view.dart';

class ChooseRoomScreenViewController extends GetxController {
  var roomCount = 1.obs;

  var currentIndex = 0.obs;
  List<String> imgList = [
    'assets/images/homescreen/slider1.png',
    'assets/images/homescreen/slider2.png',
    'assets/images/homescreen/slider3.png',
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  var rooms = 1.obs;
  var adults = 2.obs;
  var children = 0.obs;

  DateTime? get checkInDate => selectedRange.value?.start;
  DateTime? get checkOutDate => selectedRange.value?.end;

  void showRoomGuestBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    Center(
                      child: Text(
                        "Rooms and Guests",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.googleSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1),

              _counterTile(
                title: "Rooms",
                value: rooms,
                min: 1,
                context: Get.context!,
              ),

              _counterTile(
                title: "Adults",
                value: adults,
                min: 1,
                context: Get.context!,
              ),

              _counterTile(
                title: "Children",
                value: children,
                min: 0,
                context: Get.context!,
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _counterTile({
    required String title,
    required var value,
    required int min,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.googleSans(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),

          Obx(
            () => IconButton(
              onPressed: value.value > min ? () => value.value-- : null,
              icon: Icon(
                Icons.remove_circle_outline,
                size: 32,
                color: value.value > min
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
              ),
            ),
          ),

          Obx(
            () => SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  "${value.value}",
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: () => value.value++,
            icon: Icon(
              Icons.add_circle_outline_sharp,
              color: Color(0xFF009A3F),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Rx<DateTimeRange?> selectedRange = Rx<DateTimeRange?>(null);

  int get nights {
    if (selectedRange.value == null) return 1;
    return selectedRange.value!.end
        .difference(selectedRange.value!.start)
        .inDays;
  }

  String get dateText {
    if (selectedRange.value == null) {
      return "Select Date";
    }

    final start = selectedRange.value!.start;
    final end = selectedRange.value!.end;

    return "${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}";
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange.value,
    );

    if (picked != null) {
      selectedRange.value = picked;
    }
  }
}
