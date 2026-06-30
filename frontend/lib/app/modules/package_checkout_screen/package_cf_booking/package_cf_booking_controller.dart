part of 'package_cf_booking_view.dart';

class PackageCfBookingViewController extends GetxController {
  Map<String, dynamic> bookingData = {};

  double price = 0;
  int adultCount = 1;
  double total = 0;

  @override
  void onInit() {
    super.onInit();

    bookingData = Map<String, dynamic>.from(Get.arguments ?? {});

    price = (bookingData["price"] ?? 0).toDouble();
    adultCount = bookingData["adultCount"] ?? 1;
    total = (bookingData["total"] ?? price * adultCount).toDouble();
  }

  DateTime? get selectedDate {
    final data = bookingData["date"];
    if (data == null) return null;

    if (data is DateTime) return data;

    return DateTime.tryParse(data.toString());
  }

  DateTime? get transactionDate {
    final data = bookingData["transactionDate"];
    if (data == null) return null;

    return DateTime.tryParse(data.toString());
  }

  String get startTime => bookingData["startTime"] ?? "";

  int get adults => adultCount;

  String get firstName => bookingData["firstName"] ?? "";

  String get lastName => bookingData["lastName"] ?? "";

  String get guestName => "$firstName $lastName";

  String get email => bookingData["email"] ?? "";

  String get phone => bookingData["phone"] ?? "";

  String get payment => bookingData["payment"] ?? "ABA Pay";

  String get guide => bookingData["guide"] ?? "Live tour guide";
}