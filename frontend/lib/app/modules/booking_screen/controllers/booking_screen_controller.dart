import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/core/api/services/booking_services.dart';
import 'package:frontend/app/core/api/services/hotels_services.dart';
import 'package:frontend/app/core/api/services/travel_package_services.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/modules/profile_screen/userProfile_screen/user_profile_screen_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

// --- ENUMS & MODELS ---
enum BookingStatus { all, upcoming, completed, pending }

class BookingModel {
  final String id;
  final String bookingType; // 'hotel' or 'package'
  final String hotelId;
  final String? packageId;
  final String? packageName;

  // Stored bilingual values for real-time reactivity
  final String nameKm;
  final String nameEn;
  final String locationKm;
  final String locationEn;
  final String roomTypeNameKm;
  final String roomTypeNameEn;

  final double price;
  final int nights;
  final String startDate;
  final String endDate;
  final int guests;
  final int adults;
  final int children;
  final int roomsBooked;
  final BookingStatus status;
  final bool isGroupStay;
  final String imageUrl;
  final List<String> images;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String transactionDate;
  final String note;
  final List<dynamic> itinerary;
  final String paymentMethod;
  final String paymentStatus;

  BookingModel({
    required this.id,
    this.bookingType = 'hotel',
    required this.hotelId,
    this.packageId,
    this.packageName,
    required this.nameKm,
    required this.nameEn,
    required this.locationKm,
    required this.locationEn,
    required this.roomTypeNameKm,
    required this.roomTypeNameEn,
    required this.price,
    required this.nights,
    required this.startDate,
    required this.endDate,
    required this.guests,
    this.adults = 0,
    this.children = 0,
    this.roomsBooked = 1,
    required this.status,
    this.isGroupStay = false,
    required this.imageUrl,
    this.images = const [],
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.transactionDate,
    this.note = '',
    this.itinerary = const [],
    this.paymentMethod = 'KHQR',
    this.paymentStatus = 'pending',
  });

  bool get isPackage => bookingType == 'package';

  /// Human-readable payment method label, e.g. "Pay at Hotel" instead of
  /// the raw backend value "PAY_AT_HOTEL".
  String get paymentMethodLabel {
    switch (paymentMethod.toUpperCase()) {
      case 'PAY_AT_HOTEL':
        return _isKhmer ? 'បង់នៅសណ្ឋាគារ' : 'Pay at Hotel';
      case 'VISA':
        return 'Visa / Mastercard';
      case 'KHQR':
      default:
        return 'KHQR';
    }
  }

  /// Human-readable payment status label.
  String get paymentStatusLabel {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return _isKhmer ? 'បានបង់ប្រាក់' : 'Paid';
      case 'unpaid':
        return _isKhmer ? 'មិនទាន់បង់ប្រាក់' : 'Unpaid';
      case 'pending':
      default:
        return _isKhmer
            ? 'កំពុងរង់ចាំផ្ទៀងផ្ទាត់ការទូទាត់'
            : 'Waiting for payment verification';
    }
  }

  // Check language dynamically whenever getter is accessed
  bool get _isKhmer {
    final code = Get.locale?.languageCode ?? '';
    final fullLocale = Get.locale?.toString() ?? '';
    return code == 'km' || code == 'kh' || fullLocale.contains('kmKH');
  }

  String get hotelName {
    if (_isKhmer) {
      return nameKm.isNotEmpty ? nameKm : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameKm;
  }

  String get location {
    if (_isKhmer) {
      return locationKm.isNotEmpty ? locationKm : locationEn;
    }
    return locationEn.isNotEmpty ? locationEn : locationKm;
  }

  String get roomType {
    if (isPackage) {
      return _isKhmer ? 'កញ្ចប់ទេសចរណ៍' : 'Tour Package';
    }
    if (_isKhmer) {
      return roomTypeNameKm.isNotEmpty ? roomTypeNameKm : roomTypeNameEn;
    }
    return roomTypeNameEn.isNotEmpty ? roomTypeNameEn : roomTypeNameKm;
  }

  String get roomTypeWithRooms {
    if (isPackage) {
      return _isKhmer ? "កញ្ចប់ទេសចរណ៍" : "Tour Package";
    }
    if (roomsBooked > 1) {
      return _isKhmer
          ? "$roomType, $roomsBooked បន្ទប់"
          : "$roomType, $roomsBooked Room(s)";
    }
    return roomType;
  }

  String get guestsSummary {
    if (adults > 0 || children > 0) {
      List<String> parts = [];
      if (adults > 0) parts.add("$adults Adults");
      if (children > 0) parts.add("$children Children");
      return parts.join(", ");
    }
    return guests == 1 ? "1 Guest" : "$guests Guests";
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final String parsedBookingType = json['booking_type'] ?? 'hotel';

    DateTime? checkIn = json['check_in'] != null || json['start_date'] != null
        ? DateTime.tryParse((json['check_in'] ?? json['start_date']).toString())
        : null;

    DateTime? checkOut = json['check_out'] != null || json['end_date'] != null
        ? DateTime.tryParse((json['check_out'] ?? json['end_date']).toString())
        : null;

    int calculatedNights = 1;
    if (checkIn != null && checkOut != null) {
      calculatedNights = checkOut.difference(checkIn).inDays;
      if (calculatedNights <= 0) calculatedNights = 1;
    }

    String formattedCheckIn = checkIn != null
        ? DateFormat("MMM dd, yyyy").format(checkIn)
        : (json['check_in'] ?? json['start_date'] ?? '');

    String formattedCheckOut = checkOut != null
        ? DateFormat("MMM dd, yyyy").format(checkOut)
        : (json['check_out'] ?? json['end_date'] ?? '');

    String formattedTransactionDate = '';
    final createdAtRaw =
        json['created_at'] ?? json['createdAt'] ?? json['transaction_date'];

    if (createdAtRaw != null) {
      String dateStr = createdAtRaw.toString().trim();
      if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
        dateStr = '${dateStr.replaceAll(' ', 'T')}Z';
      }

      DateTime? parsedTime = DateTime.tryParse(dateStr);
      if (parsedTime != null) {
        formattedTransactionDate = DateFormat(
          "MMM dd, yyyy • h:mm a",
        ).format(parsedTime.toLocal());
      }
    }

    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = List<String>.from(json['images']);
    } else if (json['image_url'] != null) {
      parsedImages = [json['image_url'].toString()];
    }

    BookingStatus parseStatus(String? statusStr) {
      final now = DateTime.now();
      final DateTime? deadlineDate = checkOut ?? checkIn;

      if (deadlineDate != null) {
        final checkOutDeadline = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
          12,
          0,
        );

        if (now.isAfter(checkOutDeadline)) {
          return BookingStatus.completed;
        }
      }

      switch (statusStr?.toLowerCase()) {
        case 'completed':
          return BookingStatus.completed;
        case 'pending':
          return BookingStatus.pending;
        case 'upcoming':
          return BookingStatus.upcoming;
        default:
          return BookingStatus.upcoming;
      }
    }

    int parsedAdults = json['adults'] ?? 0;
    int parsedChildren = json['children'] ?? 0;
    int parsedGuests =
        json['number_of_people'] ??
        json['guests'] ??
        (parsedAdults + parsedChildren);

    if (parsedGuests <= 0) parsedGuests = 1;

    String nameKm =
        json['name_km']?.toString() ??
        json['hotel_name']?.toString() ??
        json['name']?.toString() ??
        '';

    String nameEn =
        json['name_en']?.toString() ??
        json['hotel_name']?.toString() ??
        json['name']?.toString() ??
        '';

    String addressKm =
        json['address_km']?.toString() ??
        json['province_km']?.toString() ??
        json['location']?.toString() ??
        '';

    String addressEn =
        json['address_en']?.toString() ??
        json['province']?.toString() ??
        json['location']?.toString() ??
        '';

    String packageName =
        json['package_name']?.toString() ??
        json['name_en']?.toString() ??
        json['name_km']?.toString() ??
        '';

    String roomTypeNameKm =
        json['room_type_name_km']?.toString() ??
        json['room_type_name']?.toString() ??
        'បន្ទប់ស្តង់ដារ';

    String roomTypeNameEn =
        json['room_type_name_en']?.toString() ??
        json['room_type_name']?.toString() ??
        'Standard Room';

    final String note =
        json['note'] ??
        json['special_request'] ??
        json['specialRequest'] ??
        json['remarks'] ??
        '';

    List<dynamic> parsedItinerary = [];
    if (json['itinerary'] is List) {
      parsedItinerary = List<dynamic>.from(json['itinerary']);
    }

    return BookingModel(
      id: json['id'] ?? json['_id'] ?? '',
      bookingType: parsedBookingType,
      hotelId:
          json['hotel_id'] ??
          json['hotel']?['_id'] ??
          json['hotel']?['id'] ??
          '',
      packageId:
          json['package_id'] ??
          json['package']?['_id'] ??
          json['package']?['id'],
      packageName: packageName,
      nameKm: nameKm,
      nameEn: nameEn,
      locationKm: addressKm,
      locationEn: addressEn,
      roomTypeNameKm: roomTypeNameKm,
      roomTypeNameEn: roomTypeNameEn,
      price: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      nights: calculatedNights,
      startDate: formattedCheckIn,
      endDate: formattedCheckOut,
      guests: parsedGuests,
      adults: parsedAdults,
      children: parsedChildren,
      roomsBooked: (json['rooms_booked'] as num?)?.toInt() ?? 1,
      status: parseStatus(json['status']),
      imageUrl: json['image_url'] ?? '',
      images: parsedImages,
      guestName: json['guest_name'] ?? '',
      guestEmail: json['guest_email'] ?? '',
      guestPhone: json['guest_phone'] ?? '',
      transactionDate: formattedTransactionDate,
      note: note,
      itinerary: parsedItinerary,
      paymentMethod: (json['payment_method'] ?? 'KHQR').toString(),
      paymentStatus: (json['payment_status'] ?? 'pending').toString(),
    );
  }
}

// --- CONTROLLER ---

class BookingScreenController extends GetxController {
  final BookingServices _bookingServices = BookingServices();
  final HotelServices _hotelServices = HotelServices();
  final TravelPackageServices _packageServices = TravelPackageServices();

  var selectedStatus = BookingStatus.all.obs;
  var isLoading = false.obs;
  var isLoadingUser = false.obs;
  var allBookings = <BookingModel>[].obs;

  // Reactive map for full package payload if needed locally
  final RxMap<String, dynamic> package = <String, dynamic>{}.obs;

  final GlobalKey screenshotKey = GlobalKey();

  late UserProfileScreenViewController userPfCtrl;
  late Map<String, dynamic> bookingData;

  String get hotel => bookingData["hotel"] ?? "";
  String get roomType => bookingData["roomType"] ?? "";
  String get guests => bookingData["guests"] ?? "";
  String get totalPrice => bookingData["totalPrice"] ?? "";
  String get guestPhone => bookingData["phone"] ?? "";
  String get guestEmail => bookingData["email"] ?? "";
  String get bookingRef =>
      bookingData["bookingRef"] ??
      "BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

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

  String get transactionDate {
    final date =
        bookingData["transactionDate"] ??
        bookingData["created_at"] ??
        bookingData["createdAt"];

    if (date == null) {
      return DateFormat("MMM dd, yyyy • h:mm a").format(DateTime.now());
    }
    if (date is DateTime) {
      return DateFormat("MMM dd, yyyy • h:mm a").format(date.toLocal());
    }

    DateTime? parsed = DateTime.tryParse(date.toString());
    if (parsed != null) {
      return DateFormat("MMM dd, yyyy • h:mm a").format(parsed.toLocal());
    }

    return date.toString();
  }

  String get note =>
      bookingData["note"] ??
      bookingData["specialRequest"] ??
      bookingData["special_request"] ??
      "";

  Future<void> fetchPackageDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _packageServices.fetchTravelPackageById(id);
      if (response != null) {
        final Map<String, dynamic>? data =
            (response is Map<String, dynamic> && response['data'] != null)
            ? Map<String, dynamic>.from(response['data'])
            : (response is Map<String, dynamic> ? response : null);

        if (data != null) {
          package.assignAll(data);
        }
      }
    } catch (e) {
      debugPrint("Error fetching package details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<UserProfileScreenViewController>()) {
      userPfCtrl = Get.find<UserProfileScreenViewController>();
    } else {
      userPfCtrl = Get.put(UserProfileScreenViewController());
    }

    ever(allBookings, (_) {});

    fetchMyBookings();
    bookingData = Get.arguments ?? {};
  }

  Future<void> loadUserInfo() async {
    try {
      isLoadingUser.value = true;
      await userPfCtrl.getProfile();
    } catch (e) {
      print("Error loading user info: $e");
    } finally {
      isLoadingUser.value = false;
    }
  }

  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;

      await loadUserInfo();

      final response = await _bookingServices.fetchMyBookings();

      if (response != null && response['result'] == true) {
        final List<dynamic> items = response['data']['items'] ?? [];

        final List<BookingModel> loadedBookings = await Future.wait(
          items.map((item) async {
            final bookingData = Map<String, dynamic>.from(item as Map);
            final String? bookingType = bookingData['booking_type'];
            final String? hotelId = bookingData['hotel_id'];
            final String? packageId =
                bookingData['package_id'] ??
                bookingData['package']?['_id'] ??
                bookingData['package']?['id'];
            final String? roomTypeId = bookingData['room_type_id'];

            // --- USER INFO INJECTION ---
            final user = userPfCtrl.user;
            if (bookingData['guest_name'] == null ||
                bookingData['guest_name'].toString().isEmpty) {
              bookingData['guest_name'] = user.name;
            }
            if (bookingData['guest_email'] == null ||
                bookingData['guest_email'].toString().isEmpty) {
              bookingData['guest_email'] = user.email;
            }
            if (bookingData['guest_phone'] == null ||
                bookingData['guest_phone'].toString().isEmpty) {
              bookingData['guest_phone'] = user.phone;
            }

            // --- PACKAGE DETAILS ---
            if (bookingType == 'package' &&
                packageId != null &&
                packageId.isNotEmpty) {
              try {
                final packageResponse = await _packageServices
                    .fetchTravelPackageById(packageId);

                if (packageResponse != null) {
                  final pkgData =
                      (packageResponse is Map<String, dynamic> &&
                          packageResponse['data'] != null)
                      ? packageResponse['data']
                      : packageResponse;

                  bookingData['name_km'] = pkgData['name_km'];
                  bookingData['name_en'] = pkgData['name_en'];
                  bookingData['address_km'] =
                      pkgData['address_km'] ?? pkgData['province_km'];
                  bookingData['address_en'] =
                      pkgData['address_en'] ?? pkgData['province'];

                  // Preserve itinerary array
                  if (pkgData['itinerary'] != null) {
                    bookingData['itinerary'] = pkgData['itinerary'];
                  }

                  if (pkgData['images'] is List &&
                      (pkgData['images'] as List).isNotEmpty) {
                    bookingData['images'] = List<String>.from(
                      pkgData['images'],
                    );
                    bookingData['image_url'] = pkgData['images'][0].toString();
                  } else if (pkgData['image_url'] != null) {
                    bookingData['image_url'] = pkgData['image_url'];
                    bookingData['images'] = [pkgData['image_url'].toString()];
                  }
                }
              } catch (e) {
                print("Error fetching package details for ID $packageId: $e");
              }
            }

            // --- HOTEL DETAILS ---
            if (bookingType != 'package' &&
                hotelId != null &&
                hotelId.isNotEmpty) {
              try {
                final hotelResponse = await _hotelServices.fetchHotelById(
                  hotelId,
                );

                if (hotelResponse != null && hotelResponse['result'] == true) {
                  final hotelData = hotelResponse['data'];

                  bookingData['name_km'] = hotelData['name_km'];
                  bookingData['name_en'] = hotelData['name_en'];
                  bookingData['address_km'] =
                      hotelData['address_km'] ?? hotelData['province_km'];
                  bookingData['address_en'] =
                      hotelData['address_en'] ?? hotelData['province'];

                  if (hotelData['room_types'] is List) {
                    final List<dynamic> roomTypes = hotelData['room_types'];
                    final matchedRoom = roomTypes.firstWhere(
                      (r) =>
                          r['_id'] == roomTypeId ||
                          r['id'] == roomTypeId ||
                          r['room_type_id'] == roomTypeId,
                      orElse: () => null,
                    );

                    if (matchedRoom != null) {
                      bookingData['room_type_name_km'] = matchedRoom['name_km'];
                      bookingData['room_type_name_en'] = matchedRoom['name_en'];
                    } else if (roomTypes.isNotEmpty) {
                      final firstRoom = roomTypes.first;
                      bookingData['room_type_name_km'] = firstRoom['name_km'];
                      bookingData['room_type_name_en'] = firstRoom['name_en'];
                    }
                  }

                  if (hotelData['image_url'] != null) {
                    bookingData['image_url'] = hotelData['image_url'];
                  } else if (hotelData['cover_image'] != null) {
                    bookingData['image_url'] = hotelData['cover_image'];
                  } else if (hotelData['images'] is List &&
                      (hotelData['images'] as List).isNotEmpty) {
                    bookingData['image_url'] = hotelData['images'][0]
                        .toString();
                  }
                }
              } catch (e) {
                print("Error fetching hotel details for ID $hotelId: $e");
              }
            }

            return BookingModel.fromJson(bookingData);
          }),
        );

        allBookings.assignAll(loadedBookings);
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      Get.snackbar("error".tr, "failed_to_fetch_bookings".tr);
    } finally {
      isLoading.value = false;
    }
  }

  List<BookingModel> get filteredBookings {
    if (selectedStatus.value == BookingStatus.all) return allBookings;
    return allBookings.where((b) {
      if (selectedStatus.value == BookingStatus.upcoming) {
        return b.status == BookingStatus.upcoming ||
            b.status == BookingStatus.pending;
      }
      return b.status == selectedStatus.value;
    }).toList();
  }

  int get countAll => allBookings.length;
  int get countUpcoming => allBookings
      .where(
        (b) =>
            b.status == BookingStatus.upcoming ||
            b.status == BookingStatus.pending,
      )
      .length;
  int get countCompleted =>
      allBookings.where((b) => b.status == BookingStatus.completed).length;

  void changeStatus(BookingStatus status) {
    selectedStatus.value = status;
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted) return true;
      if (await Permission.storage.request().isGranted) return true;
      return false;
    }
    if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  Future<void> downloadReceipt() async {
    final granted = await requestPermission();

    if (!granted) {
      Get.snackbar("error".tr, "perm_denied".tr);
      return;
    }

    final boundary =
        screenshotKey.currentContext?.findRenderObject()
            as WidgetShotPlusRenderRepaintBoundary?;

    if (boundary == null) {
      Get.snackbar("error".tr, "receipt_not_found".tr);
      return;
    }

    final bytes = await boundary.screenshot(
      format: ShotFormat.png,
      quality: 100,
    );

    if (bytes == null) {
      Get.snackbar("error".tr, "capture_failed".tr);
      return;
    }

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: "receipt_${DateTime.now().millisecondsSinceEpoch}",
    );

    if (result['isSuccess'] == true || result['success'] == true) {
      Get.snackbar(
        "done".tr,
        "receipt_saved".tr,
        backgroundColor: AppColors.lightPrimaryColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar("error".tr, "save_failed".tr);
    }
  }

  void showBookingDetailsBottomSheet(
    BuildContext context,
    BookingModel booking,
  ) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetShotPlus(
                key: screenshotKey,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'booking_details'.tr,
                            style: GoogleFonts.googleSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildDetailRow(context, 'booking_ref'.tr, booking.id),

                      _buildDetailRow(
                        context,
                        booking.isPackage ? 'package'.tr : 'hotel'.tr,
                        booking.hotelName,
                      ),

                      if (!booking.isPackage)
                        _buildDetailRow(
                          context,
                          'room_type'.tr,
                          booking.roomTypeWithRooms,
                        ),

                      _buildDetailRow(
                        context,
                        booking.isPackage ? 'date'.tr : 'check_in'.tr,
                        booking.startDate,
                      ),

                      if (!booking.isPackage &&
                          booking.endDate.isNotEmpty &&
                          booking.endDate != booking.startDate)
                        _buildDetailRow(
                          context,
                          'check_out'.tr,
                          booking.endDate,
                        ),

                      _buildDetailRow(
                        context,
                        'guests'.tr,
                        booking.guestsSummary,
                      ),

                      _buildDetailRow(
                        context,
                        'guest_name'.tr,
                        booking.guestName.isNotEmpty
                            ? booking.guestName
                            : userPfCtrl.user.name,
                      ),

                      _buildDetailRow(
                        context,
                        'guest_number'.tr,
                        booking.guestPhone.isNotEmpty
                            ? (booking.guestPhone.startsWith("+")
                                  ? booking.guestPhone
                                  : "+855 ${booking.guestPhone}")
                            : "+855 ${userPfCtrl.user.phone}",
                      ),

                      _buildDetailRow(
                        context,
                        'guest_email'.tr,
                        booking.guestEmail.isNotEmpty
                            ? booking.guestEmail
                            : userPfCtrl.user.email,
                      ),
                      if (booking.note.isNotEmpty)
                        _buildDetailRow(context, 'note'.tr, booking.note),

                      _buildDetailRow(
                        context,
                        'payment'.tr,
                        booking.paymentMethodLabel,
                      ),

                      if (booking.paymentMethod.toUpperCase() == 'KHQR')
                        _buildDetailRow(
                          context,
                          'payment_status'.tr,
                          booking.paymentStatusLabel,
                        ),

                      _buildDetailRow(
                        context,
                        'transaction_date'.tr,
                        booking.transactionDate,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(thickness: 1.2),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total_price'.tr,
                            style: GoogleFonts.googleSans(
                              fontSize: 18,
                              color: Theme.of(
                                context,
                              ).textTheme.titleSmall!.color,
                            ),
                          ),
                          Text(
                            '\$${booking.price.toStringAsFixed(0)}',
                            style: GoogleFonts.googleSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF008C2A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Bounceable(
                        onTap: downloadReceipt,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'download_receipt'.tr,
                                style: GoogleFonts.googleSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}

Widget _buildDetailRow(BuildContext context, String key, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key,
          style: GoogleFonts.googleSans(
            color: Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
