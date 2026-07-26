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
  final String hotelName;
  final String location;
  final String roomType;
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

  BookingModel({
    required this.id,
    this.bookingType = 'hotel',
    required this.hotelId,
    this.packageId,
    this.packageName,
    required this.hotelName,
    required this.location,
    required this.roomType,
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
  });

  bool get isPackage => bookingType == 'package';

  // Room Type display matching ConfirmedBookingView
  String get roomTypeWithRooms {
    if (isPackage) {
      return "Tour Package";
    }
    if (roomsBooked > 1) {
      return "$roomType, $roomsBooked Rooms(s)";
    }
    return roomType;
  }

  // Guests display matching ConfirmedBookingView
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

    // --- TRANSACTION DATE IN UTC+7 ---
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

    // --- AUTOMATIC COMPLETED STATUS CALCULATION ---
    BookingStatus parseStatus(String? statusStr) {
      final now = DateTime.now();

      final DateTime? deadlineDate = checkOut ?? checkIn;

      if (deadlineDate != null) {
        final checkOutDeadline = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
          12, // 12:00 PM
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
      packageName: json['package_name'] ?? json['name_en'] ?? json['name_km'],
      hotelName:
          json['hotel_name'] ??
          json['package_name'] ??
          json['name'] ??
          (parsedBookingType == 'package' ? 'Tour Package' : 'Hotel'),
      location: json['address_en'] ?? json['location'] ?? 'Siem Reap, Cambodia',
      roomType: parsedBookingType == 'package'
          ? 'Tour Package'
          : (json['room_type_name'] ?? 'Standard Room'),
      price: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      nights: calculatedNights,
      startDate: formattedCheckIn,
      endDate: formattedCheckOut,
      guests: parsedGuests,
      adults: parsedAdults,
      children: parsedChildren,
      roomsBooked: json['rooms_booked'] ?? 1,
      status: parseStatus(json['status']),
      imageUrl: json['image_url'] ?? '',
      images: parsedImages,
      guestName: json['guest_name'] ?? '',
      guestEmail: json['guest_email'] ?? '',
      guestPhone: json['guest_phone'] ?? '',
      transactionDate: formattedTransactionDate,
      note:
          json['note'] ??
          json['special_request'] ??
          json['specialRequest'] ??
          json['remarks'] ??
          '',
    );
  }
}

// --- CONTROLLER ---

class BookingScreenController extends GetxController {
  final BookingServices _bookingServices = BookingServices();
  final HotelServices _hotelServices = HotelServices();
  final TravelPackageServices _packageServices =
      TravelPackageServices(); // Package services added

  var selectedStatus = BookingStatus.all.obs;
  var isLoading = false.obs;
  var isLoadingUser = false.obs;
  var allBookings = <BookingModel>[].obs;
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

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<UserProfileScreenViewController>()) {
      userPfCtrl = Get.find<UserProfileScreenViewController>();
    } else {
      userPfCtrl = Get.put(UserProfileScreenViewController());
    }
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

      // Ensure user profile details are fetched first
      await loadUserInfo();

      final response = await _bookingServices.fetchMyBookings();

      if (response != null && response['result'] == true) {
        final List<dynamic> items = response['data']['items'] ?? [];

        bool isKhmer =
            Get.locale?.languageCode == 'km' ||
            Get.locale?.languageCode == 'kh';

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

            // --- USER INFO INJECTION FOR GUEST DETAILS ---
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

            // --- PACKAGE BOOKING DETAILS EXTRACTION ---
            // --- PACKAGE BOOKING DETAILS EXTRACTION ---
            if (bookingType == 'package' &&
                packageId != null &&
                packageId.isNotEmpty) {
              try {
                final packageResponse = await _packageServices
                    .fetchTravelPackageById(packageId);

                if (packageResponse != null &&
                    (packageResponse['result'] == true ||
                        packageResponse['data'] != null)) {
                  final pkgData = packageResponse['data'] ?? packageResponse;

                  String? pkgName = isKhmer
                      ? (pkgData['name_km'] ?? pkgData['name_en'])
                      : (pkgData['name_en'] ?? pkgData['name_km']);
                  pkgName ??= pkgData['name'] ?? pkgData['title'];
                  bookingData['hotel_name'] = pkgName;
                  bookingData['package_name'] = pkgName;

                  // Extract images list
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

            // --- HOTEL BOOKING DETAILS EXTRACTION ---
            if (bookingType != 'package' &&
                hotelId != null &&
                hotelId.isNotEmpty) {
              try {
                final hotelResponse = await _hotelServices.fetchHotelById(
                  hotelId,
                );

                if (hotelResponse != null && hotelResponse['result'] == true) {
                  final hotelData = hotelResponse['data'];

                  // 1. Hotel Name (name_km / name_en)
                  String? hotelName;
                  if (isKhmer) {
                    hotelName = hotelData['name_km'] ?? hotelData['name_en'];
                  } else {
                    hotelName = hotelData['name_en'] ?? hotelData['name_km'];
                  }
                  hotelName ??= hotelData['name'] ?? hotelData['title'];
                  bookingData['hotel_name'] = hotelName;

                  // 2. Room Type Name (name_km / name_en)
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
                      String? roomName;
                      if (isKhmer) {
                        roomName =
                            matchedRoom['name_km'] ?? matchedRoom['name_en'];
                      } else {
                        roomName =
                            matchedRoom['name_en'] ?? matchedRoom['name_km'];
                      }

                      if (roomName != null && roomName.isNotEmpty) {
                        bookingData['room_type_name'] = roomName;
                      }
                    } else if (roomTypes.isNotEmpty) {
                      final firstRoom = roomTypes.first;
                      bookingData['room_type_name'] = isKhmer
                          ? (firstRoom['name_km'] ?? firstRoom['name_en'])
                          : (firstRoom['name_en'] ?? firstRoom['name_km']);
                    }
                  }

                  // 3. Image (image_url or cover_image)
                  if (hotelData['image_url'] != null) {
                    bookingData['image_url'] = hotelData['image_url'];
                  } else if (hotelData['cover_image'] != null) {
                    bookingData['image_url'] = hotelData['cover_image'];
                  } else if (hotelData['images'] is List &&
                      (hotelData['images'] as List).isNotEmpty) {
                    bookingData['image_url'] = hotelData['images'][0]
                        .toString();
                  }

                  // 4. Location Extraction (address_km, address_en, province_km, province)
                  String? locationName;
                  if (isKhmer) {
                    locationName =
                        hotelData['address_km'] ??
                        hotelData['province_km'] ??
                        hotelData['address_en'] ??
                        hotelData['province'];
                  } else {
                    locationName =
                        hotelData['address_en'] ??
                        hotelData['province'] ??
                        hotelData['address_km'] ??
                        hotelData['province_km'];
                  }

                  if (locationName != null && locationName.isNotEmpty) {
                    bookingData['location'] = locationName;
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
      WidgetShotPlus(
        key: screenshotKey,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
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
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Booking Ref
                _buildDetailRow(context, 'booking_ref'.tr, booking.id),

                // Name (Package Name or Hotel)
                _buildDetailRow(
                  context,
                  booking.isPackage ? 'Package'.tr : 'hotel'.tr,
                  booking.hotelName,
                ),

                // Room Type (or Package)
                if (!booking.isPackage)
                  _buildDetailRow(
                    context,
                    'room_type'.tr,
                    booking.roomTypeWithRooms,
                  ),

                // Start Date / Check-in
                _buildDetailRow(
                  context,
                  booking.isPackage ? 'Date'.tr : 'check_in'.tr,
                  booking.startDate,
                ),

                // End Date / Check-out (Only shown for hotel bookings when endDate is present and different)
                if (!booking.isPackage &&
                    booking.endDate.isNotEmpty &&
                    booking.endDate != booking.startDate)
                  _buildDetailRow(context, 'check_out'.tr, booking.endDate),
                // Guests
                _buildDetailRow(context, 'guests'.tr, booking.guestsSummary),

                // Guest Name
                _buildDetailRow(
                  context,
                  'guest_name'.tr,
                  booking.guestName.isNotEmpty
                      ? booking.guestName
                      : userPfCtrl.user.name,
                ),

                // Guest Phone
                _buildDetailRow(
                  context,
                  'guest_number'.tr,
                  booking.guestPhone.isNotEmpty
                      ? (booking.guestPhone.startsWith("+")
                            ? booking.guestPhone
                            : "+855 ${booking.guestPhone}")
                      : "+855 ${userPfCtrl.user.phone}",
                ),

                // Guest Email
                _buildDetailRow(
                  context,
                  'guest_email'.tr,
                  booking.guestEmail.isNotEmpty
                      ? booking.guestEmail
                      : userPfCtrl.user.email,
                ),
                if (booking.note.isNotEmpty)
                  _buildDetailRow(context, 'note'.tr, booking.note),

                // Payment
                _buildDetailRow(context, 'payment'.tr, 'KHQR'),

                // Transaction Date
                _buildDetailRow(
                  context,
                  'transaction_date'.tr,
                  booking.transactionDate,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1.2),
                ),

                // Total Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total_price'.tr,
                      style: GoogleFonts.googleSans(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.titleSmall!.color,
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
                const SizedBox(height: 24),

                // Download Receipt Button
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
                const SizedBox(height: 12),
              ],
            ),
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
