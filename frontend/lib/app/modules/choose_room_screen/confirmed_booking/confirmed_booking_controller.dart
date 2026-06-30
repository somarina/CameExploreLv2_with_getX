part of 'confirmed_booking_view.dart';

class ConfirmedBookingViewController extends GetxController {
  late Map<String, dynamic> bookingData;

  String get hotel => bookingData["hotel"] ?? "";

  String get roomType => bookingData["roomType"] ?? "";

  String get guests => bookingData["guests"] ?? "";

  String get totalPrice => bookingData["totalPrice"] ?? "";
  String get guestPhone => bookingData["phone"] ?? "";
  String get guestEmail => bookingData["email"] ?? "";

  String get checkIn {
    final date = bookingData["checkIn"];
    if (date == null) return "";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  String get checkOut {
    final date = bookingData["checkOut"];
    if (date == null) return "";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  String get guestName =>
      "${bookingData["firstName"] ?? ""} ${bookingData["lastName"] ?? ""}";

  String get transactionDate => bookingData["transactionDate"] ?? "";
  @override
  void onInit() {
    super.onInit();
    bookingData = Get.arguments ?? {};
  }
}
