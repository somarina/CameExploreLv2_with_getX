import 'package:dio/dio.dart';
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
    String paymentMethod = "KHQR",
    String paymentStatus = "pending",
  }) async {
    final Map<String, dynamic> body = {
      "booking_type": bookingType,
      "package_id": packageId,
      "start_date": DateFormat('yyyy-MM-dd').format(startDate),
      "number_of_people": numberOfPeople,
      "guest_note": guestNote ?? "",
      "payment_method": paymentMethod,
      "payment_status": paymentStatus,
    };

    return await baseApi.post(endpoint: "/bookings/package", data: body);
  }

  /// Uploads the KHQR payment receipt/screenshot for a package booking so a
  /// human (package owner/admin) can actually see and verify it — this is
  /// what lets payment_status move past "pending".
  Future<dynamic> uploadPaymentProof({
    required String bookingId,
    required String imagePath,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      ),
    });

    return await baseApi.postFormData(
      endpoint: "/bookings/$bookingId/payment-proof",
      data: formData,
    );
  }
}
