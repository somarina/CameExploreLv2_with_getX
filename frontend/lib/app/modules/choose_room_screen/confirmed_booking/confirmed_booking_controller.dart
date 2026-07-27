part of 'confirmed_booking_view.dart';

class ConfirmedBookingViewController extends GetxController {
  late Map<String, dynamic> bookingData;

  String get bookingRef =>
      bookingData["bookingRef"] ?? bookingData["id"] ?? "N/A";

  String get hotel => bookingData["hotel"] ?? "";

  String get roomType => bookingData["roomType"] ?? "";

  String get guests => bookingData["guests"] ?? "";

  String get totalPrice {
    final rawPrice = bookingData["totalPrice"];
    if (rawPrice == null) return "\$0";

    if (rawPrice is num) {
      return "\$${rawPrice.toStringAsFixed(0)}";
    }

    String priceStr = rawPrice.toString();
    if (!priceStr.startsWith("\$")) {
      priceStr = "\$$priceStr";
    }
    return priceStr;
  }

  String get guestPhone => bookingData["phone"] ?? "";
  String get guestEmail => bookingData["email"] ?? "";

  String get rooms => bookingData["rooms"] ?? "";

  String get roomTypeWithRooms {
    if (rooms.isNotEmpty && !rooms.startsWith("1 ")) {
      return "$roomType, $rooms(s)";
    }
    return roomType;
  }

  String get checkIn {
    final date = bookingData["checkIn"];
    if (date == null) return "";
    if (date is DateTime) return DateFormat("MMM dd, yyyy").format(date);
    return date.toString();
  }

  String get checkOut {
    final date = bookingData["checkOut"];
    if (date == null) return "";
    if (date is DateTime) return DateFormat("MMM dd, yyyy").format(date);
    return date.toString();
  }

  String get guestName =>
      "${bookingData["firstName"] ?? ""} ${bookingData["lastName"] ?? ""}"
          .trim();

  String get transactionDate => bookingData["transactionDate"] ?? "";


String get note => bookingData["note"] ?? bookingData["specialRequest"] ?? "";
  @override
  void onInit() {
    super.onInit();
    bookingData = Get.arguments ?? {};
  }
}
