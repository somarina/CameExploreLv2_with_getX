import 'package:frontend/app/core/api/services/base_api_service.dart';

class BookingServices {
  final BaseApiService baseApi = BaseApiService();

  Future<dynamic> fetchMyBookings() async {
    return await baseApi.get(
      endpoint: "/bookings/mine",
    );
  }

  Future<dynamic> createHotelBooking(Map<String, dynamic> payload) async {
    return await baseApi.post(
      endpoint: "/bookings/hotel",
      data: payload, 
    );
  }
}