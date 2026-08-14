import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

part 'confirmed_booking_binding.dart';
part 'confirmed_booking_controller.dart';

class ConfirmedBookingView extends GetView<ConfirmedBookingViewController> {
  const ConfirmedBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 6,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    controller.paymentMethod == "PAY_AT_HOTEL"
                        ? "Booking Reserved"
                        : "booking_confirmed".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16),

                  Text(
                    controller.paymentMethod == "PAY_AT_HOTEL"
                        ? "Your room has been reserved. Payment will be collected at the hotel."
                        : "booking_success_msg".tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).textTheme.titleSmall!.color,
                    ),
                  ),

                  SizedBox(height: 20),

                  /// Details Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "booking_details".tr,
                          style: GoogleFonts.googleSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),

                        SizedBox(height: 24),
                        _detailRow(
                          "booking_ref".tr,
                          controller.bookingRef,
                          context,
                        ),
                        _detailRow("hotel".tr, controller.hotel, context),

                        _detailRow(
                          "room_type".tr,
                          controller.roomTypeWithRooms,
                          context,
                        ),
                        _detailRow("check_in".tr, controller.checkIn, context),
                        _detailRow(
                          "check_out".tr,
                          controller.checkOut,
                          context,
                        ),
                        _detailRow("guests".tr, controller.guests, context),
                        _detailRow(
                          "guest_name".tr,
                          controller.guestName,
                          context,
                        ),
                        _detailRow(
                          "guest_number".tr,
                          "+855 ${controller.guestPhone}",
                          context,
                        ),
                        _detailRow(
                          "guest_email".tr,
                          controller.guestEmail,
                          context,
                        ),
                        if (controller.note.isNotEmpty)
                          _detailRow("note".tr, controller.note, context),
                        _detailRow(
                          "payment".tr,
                          controller.paymentMethod == "PAY_AT_HOTEL"
                              ? "Pay at Hotel"
                              : controller.paymentMethod == "VISA"
                                  ? "Visa / Card"
                                  : "KHQR",
                          context,
                        ),
                        _detailRow(
                          "payment_status".tr,
                          controller.paymentStatus == "unpaid"
                              ? "Payment due at hotel"
                              : controller.paymentStatus == "pending"
                                  ? "Waiting for payment verification"
                                  : "Paid",
                          context,
                        ),
                        if (controller.paymentMethod != "PAY_AT_HOTEL")
                          _detailRow(
                            "transaction_date".tr,
                            controller.transactionDate,
                            context,
                          ),

                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "total_price".tr,
                              style: GoogleFonts.googleSans(
                                fontSize: 18,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.color,
                              ),
                            ),
                            Text(
                              controller.totalPrice,
                              style: GoogleFonts.googleSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF008C2A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (controller.paymentMethod == "PAY_AT_HOTEL")
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.payments_outlined, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "No online payment was made. Please pay the amount shown above directly at the hotel when you arrive.",
                              style: GoogleFonts.googleSans(
                                color: Colors.orange.shade800,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 30),

                  Bounceable(
                    onTap: () {
                      // Get.offAllNamed(Routes.HOME_SCREEN);
                      // Get.find<ButtonNavbarController>().changePage(0);
                      Get.offAllNamed(Routes.BUTTON_NAVBAR);
                    },
                    child: Container(
                      width: Get.width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_filled,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "back_to_home".tr,
                              style: GoogleFonts.googleSans(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "email_sent_msg".tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).textTheme.titleSmall!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.googleSans(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.titleSmall!.color?.withValues(alpha: 0.7),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.googleSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
