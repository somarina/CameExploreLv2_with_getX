import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

enum BookingStatus { all, upcoming, completed }

class BookingModel {
  final String id;
  final String hotelName;
  final String location;
  final String roomType;
  final double price;
  final int nights;
  final String startDate;
  final String endDate;
  final int guests;
  final BookingStatus status;
  final bool isGroupStay;
  final String imageUrl;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  BookingModel({
    required this.id,
    required this.hotelName,
    required this.location,
    required this.roomType,
    required this.price,
    required this.nights,
    required this.startDate,
    required this.endDate,
    required this.guests,
    required this.status,
    this.isGroupStay = false,
    required this.imageUrl,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
  });
}

class BookingScreenController extends GetxController {
  var selectedStatus = BookingStatus.all.obs;
  final GlobalKey screenshotKey = GlobalKey();

  final List<BookingModel> allBookings = [
    BookingModel(
      id: 'BK-2026-00142',
      hotelName: 'Raffles Grand Hotel',
      location: 'Phnom Penh, Cambodia',
      roomType: 'Deluxe Double Room',
      price: 149.0,
      nights: 1,
      startDate: 'Jun 27, 2026',
      endDate: 'Jun 28, 2026',
      guests: 2,
      status: BookingStatus.upcoming,
      imageUrl: 'https://picsum.photos/400/200?random=1',

      // 👇 ADD
      guestName: 'John Doe',
      guestEmail: 'john@gmail.com',
      guestPhone: '012345678',
    ),
    BookingModel(
      id: 'BK-2026-00142',
      hotelName: 'Raffles Grand Hotel',
      location: 'Phnom Penh, Cambodia',
      roomType: 'Deluxe Double Room',
      price: 149.0,
      nights: 1,
      startDate: 'Jun 27, 2026',
      endDate: 'Jun 28, 2026',
      guests: 2,
      status: BookingStatus.completed,
      imageUrl: 'https://picsum.photos/400/200?random=1',

      // 👇 ADD
      guestName: 'John Doe',
      guestEmail: 'john@gmail.com',
      guestPhone: '012345678',
    ),
  ];

  List<BookingModel> get filteredBookings {
    if (selectedStatus.value == BookingStatus.all) return allBookings;
    return allBookings.where((b) => b.status == selectedStatus.value).toList();
  }

  int get countAll => allBookings.length;
  int get countUpcoming =>
      allBookings.where((b) => b.status == BookingStatus.upcoming).length;
  int get countCompleted =>
      allBookings.where((b) => b.status == BookingStatus.completed).length;

  void changeStatus(BookingStatus status) {
    selectedStatus.value = status;
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted) {
        return true;
      }

      if (await Permission.storage.request().isGranted) {
        return true;
      }

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
      Get.snackbar("Permission", "Storage permission denied");
      return;
    }

    final boundary =
        screenshotKey.currentContext?.findRenderObject()
            as WidgetShotPlusRenderRepaintBoundary?;

    if (boundary == null) {
      Get.snackbar("Error", "Receipt not found");
      return;
    }

    final bytes = await boundary.screenshot(
      format: ShotFormat.png,
      quality: 100,
    );

    if (bytes == null) {
      Get.snackbar("Error", "Capture failed");
      return;
    }

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: "receipt_${DateTime.now().millisecondsSinceEpoch}",
    );

    if (result['isSuccess'] == true || result['success'] == true) {
      Get.snackbar(
        "Success",
        "Receipt saved to Gallery",
        backgroundColor: AppColors.lightPrimaryColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar("Error", "Failed to save image");
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
          padding: EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                      'Booking Details',
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
                SizedBox(height: 16),
                _buildDetailRow(context, 'Booking Ref', booking.id),
                _buildDetailRow(context, 'Hotel', booking.hotelName),
                _buildDetailRow(context, 'Location', booking.location),
                _buildDetailRow(context, 'Room Type', booking.roomType),
                _buildDetailRow(context, 'Check-in', booking.startDate),
                _buildDetailRow(context, 'Check-out', booking.endDate),
                _buildDetailRow(context, 'Guests', '${booking.guests} adults'),
                _buildDetailRow(context, 'Guest Name', booking.guestName),
                _buildDetailRow(
                  context,
                  'Guest Phone',
                  '+855 ${booking.guestPhone}',
                ),
                _buildDetailRow(context, 'Guest Email', booking.guestEmail),
                _buildDetailRow(context, 'Payment', 'ABA Pay'),
                _buildDetailRow(context, 'Transaction Date', '2222'),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1.2),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid',
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${booking.price.toStringAsFixed(2)}',
                      style: GoogleFonts.googleSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

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
                          Icon(Icons.download, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Download Receipt',
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
                SizedBox(height: 12),
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
    padding: EdgeInsets.symmetric(vertical: 10.0),
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
        SizedBox(width: 16),
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
