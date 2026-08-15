import 'package:dio/dio.dart';
import 'package:frontend/app/core/api/services/base_api_service.dart';

class BookingServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchMyBookings() async {
    return await baseApi.get(
      endpoint: "/bookings/mine",
    );
  }

  Future<dynamic> getBooking(String bookingId) async {
    return await baseApi.get(
      endpoint: "/bookings/$bookingId",
    );
  }

  Future<dynamic> createHotelBooking(Map<String, dynamic> payload) async {
    return await baseApi.post(
      endpoint: "/bookings/hotel",
      data: payload, 
    );
  }

  Future<dynamic> createPackageBooking(Map<String, dynamic> payload) async {
    return await baseApi.post(
      endpoint: "/bookings/package",
      data: payload,
    );
  }

  /// Uploads the KHQR payment receipt/screenshot for a booking.
  /// This only stores the proof for review — it does NOT mark the
  /// booking as paid. A hotel/package owner or admin still has to
  /// confirm it via [updatePaymentStatus].
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

  /// Marks a booking's payment as verified/rejected. Only the hotel/package
  /// owner or an admin is allowed to call this on the backend.
  Future<dynamic> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus, // "paid" | "unpaid" | "pending"
  }) async {
    return await baseApi.put(
      endpoint: "/bookings/$bookingId/payment-status",
      data: {"payment_status": paymentStatus},
    );
  }
}