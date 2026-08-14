part of 'guest_info_screen_view.dart';

class GuestInfoScreenViewController extends GetxController {
  var themeCtrl = Get.find<ThemeModeViewController>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var selectedPayment = "KHQR".obs;
  DateTime? checkIn;
  DateTime? checkOut;
  RxString transactionDate = ''.obs;
  final noteCtrl = TextEditingController();
  final cardHolderCtrl = TextEditingController();
  final cardNumberCtrl = TextEditingController();
  final cardExpiryCtrl = TextEditingController();
  final cardCvvCtrl = TextEditingController();
  final noteLength = 0.obs;
  var isLoading = false.obs;
  var isLoadingUser = true.obs;

  // --- Timer & Invoice Upload State ---
  RxInt remainingSeconds = 180.obs; // 3 minutes = 180 seconds
  Timer? _timer;
  Rx<XFile?> uploadedInvoice = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  void startPaymentTimer() {
    remainingSeconds.value = 180;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void stopPaymentTimer() {
    _timer?.cancel();
  }

  String get formattedTimer {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> pickInvoiceImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      uploadedInvoice.value = image;
      Get.snackbar(
        "success".tr,
        "Invoice uploaded successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  // ------------------------------------

  // Hotel & Room Type Data
  Map<String, dynamic> hotel = {};
  Map<String, dynamic> roomType = {};
  int roomsCount = 1;
  int adultsCount = 2;
  int childrenCount = 0;

  final userPfCtrl = Get.find<UserProfileScreenViewController>();
  final BookingServices _bookingServices = BookingServices();

  String get checkInText =>
      checkIn != null ? DateFormat('EEE, MMM dd').format(checkIn!) : '';
  String get checkOutText =>
      checkOut != null ? DateFormat('EEE, MMM dd').format(checkOut!) : '';

  int get nights => checkIn != null && checkOut != null
      ? checkOut!.difference(checkIn!).inDays
      : 0;

  bool validateGuestInfo() {
    if (firstNameCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_first_name".tr);
      return false;
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_last_name".tr);
      return false;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_email".tr);
      return false;
    }

    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      _showErrorSnackBar("err_valid_email".tr);
      return false;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("err_phone".tr);
      return false;
    }

    if (!RegExp(r'^(0|855)?[1-9][0-9]{7,8}$').hasMatch(phoneCtrl.text.trim())) {
      _showErrorSnackBar("err_valid_phone".tr);
      return false;
    }

    return true;
  }

  double get pricePerNight {
    final price = roomType["price_per_night"];
    if (price == null) return 0.0;
    return (price is num)
        ? price.toDouble()
        : double.tryParse(price.toString()) ?? 0.0;
  }

  double get calculatedTotalPrice {
    final countNights = nights > 0 ? nights : 1;
    return pricePerNight * countNights * roomsCount;
  }

  String get hotelName =>
      hotel["name_en"] ?? hotel["name_kh"] ?? hotel["name"] ?? "Hotel Booking";

  String get roomTypeName =>
      roomType["name_en"] ?? roomType["name_kh"] ?? roomType["name"] ?? "Room";

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "error".tr,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> loadUserInfo() async {
    try {
      isLoadingUser.value = true;
      await userPfCtrl.getProfile();

      final user = userPfCtrl.user;
      final names = user.name.trim().split(' ');

      firstNameCtrl.text = names.isNotEmpty ? names.first : '';
      lastNameCtrl.text = names.length > 1 ? names.sublist(1).join(' ') : '';
      emailCtrl.text = user.email;
      phoneCtrl.text = user.phone;
    } finally {
      isLoadingUser.value = false;
    }
  }

  bool validateCard() {
    if (cardHolderCtrl.text.trim().isEmpty ||
        cardNumberCtrl.text.replaceAll(' ', '').length < 12 ||
        cardExpiryCtrl.text.trim().isEmpty ||
        cardCvvCtrl.text.trim().length < 3) {
      _showErrorSnackBar("Please enter valid card details.");
      return false;
    }
    return true;
  }

  Future<String?> createBooking({
    String? paymentMethod,
    String? paymentStatus,
  }) async {
    final method = paymentMethod ?? selectedPayment.value;
    final status = paymentStatus ??
        (method == "VISA" ? "paid" : method == "PAY_AT_HOTEL" ? "unpaid" : "pending");

    if (method == "KHQR" && uploadedInvoice.value == null) {
      _showErrorSnackBar("Please upload your payment invoice before proceeding.");
      return null;
    }

    try {
      isLoading.value = true;

      final String formattedCheckIn = checkIn != null
          ? DateFormat('yyyy-MM-dd').format(checkIn!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final String formattedCheckOut = checkOut != null
          ? DateFormat('yyyy-MM-dd').format(checkOut!)
          : DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.now().add(const Duration(days: 1)));

      String hotelId = hotel["_id"] ?? hotel["id"] ?? hotel["hotel_id"] ?? "";
      String roomTypeId =
          roomType["_id"] ?? roomType["id"] ?? roomType["room_type_id"] ?? "";

      final int totalGuests = adultsCount + childrenCount;

      final bookingPayload = {
        "booking_type": "hotel",
        "hotel_id": hotelId,
        "room_type_id": roomTypeId,
        "check_in": formattedCheckIn,
        "check_out": formattedCheckOut,
        "rooms_booked": roomsCount,
        "number_of_people": totalGuests,
        "adults": adultsCount,
        "children": childrenCount,
        "total_price": calculatedTotalPrice,
        "guest_note": noteCtrl.text.trim(),
        "payment_method": method,
        "payment_status": status,
      };

      final response = await _bookingServices.createHotelBooking(
        bookingPayload,
      );

      if (response != null &&
          (response['result'] == true || response['success'] == true)) {
        if (Get.isRegistered<BookingScreenController>()) {
          Get.find<BookingScreenController>().fetchMyBookings();
        }

        final bookingId =
            response['data']?['_id'] ??
            response['data']?['id'] ??
            response['booking_id'] ??
            response['id'];

        return bookingId?.toString();
      } else {
        _showErrorSnackBar(response?['message'] ?? "Failed to save booking");
        return null;
      }
    } catch (e) {
      _showErrorSnackBar("Error creating booking: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();

    final args = Get.arguments;
    if (args != null && args is Map) {
      checkIn = args['checkIn'];
      checkOut = args['checkOut'];
      hotel = args['hotel'] != null
          ? Map<String, dynamic>.from(args['hotel'])
          : {};
      roomType = args['roomType'] != null
          ? Map<String, dynamic>.from(args['roomType'])
          : {};
      roomsCount = args['rooms'] ?? 1;
      adultsCount = args['adults'] ?? 2;
      childrenCount = args['children'] ?? 0;
    }

    noteCtrl.addListener(() {
      noteLength.value = noteCtrl.text.length;
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    noteCtrl.dispose();
    cardHolderCtrl.dispose();
    cardNumberCtrl.dispose();
    cardExpiryCtrl.dispose();
    cardCvvCtrl.dispose();
    super.onClose();
  }
}