import 'package:frontend/app/core/api/services/base_api_service.dart';
import 'package:intl/intl.dart';

class PackageBookingServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> bookPackage({
    required String packageId,
    required DateTime startDate,
    required int numberOfPeople,
    String? guestNote,
    String bookingType = "package",
  }) async {
    final Map<String, dynamic> body = {
      "booking_type": bookingType,
      "package_id": packageId,
      "start_date": DateFormat('yyyy-MM-dd').format(startDate),
      "number_of_people": numberOfPeople,
      "guest_note": guestNote ?? "",
    };

    return await baseApi.post(endpoint: "/bookings/package", data: body);
  }
}
