import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

part 'package_cf_booking_binding.dart';
part 'package_cf_booking_controller.dart';

class PackageCfBookingView extends GetView<PackageCfBookingViewController> {
  const PackageCfBookingView({super.key});

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
                    child: Icon(
                      Icons.check,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Booking Confirmed!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.googleSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Your activity has been successfully booked",
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
                          "Booking Details",
                          style: GoogleFonts.googleSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),

                        SizedBox(height: 24),

                        _detailRow(
                          "Date",
                          controller.selectedDate != null
                              ? DateFormat(
                                  'EEEE, dd MMM yyyy',
                                ).format(controller.selectedDate!)
                              : "No date selected",
                          context,
                        ),
                        _detailRow("Start time", controller.startTime, context),
                        _detailRow(
                          "Participants",
                          "${controller.adults} adults",
                          context,
                        ),
                        _detailRow("Guest Name", controller.guestName, context),

                        _detailRow(
                          "Guest Number",
                          "+855 ${controller.phone}",
                          context,
                        ),

                        _detailRow("Guest Email", controller.email, context),

                        _detailRow(
                          "Payment",
                          controller.payment == "VISA"
                              ? "Visa / Card"
                              : "KHQR",
                          context,
                        ),
                        _detailRow(
                          "Payment Status",
                          controller.paymentStatus == "pending"
                              ? "Waiting for payment verification"
                              : "Paid",
                          context,
                        ),

                        _detailRow(
                          "Transaction Date",
                          controller.transactionDate != null
                              ? DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(controller.transactionDate!)
                              : "-",
                          context,
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Price",
                              style: GoogleFonts.googleSans(
                                fontSize: 18,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.color,
                              ),
                            ),
                            Text(
                              "\$${controller.total.toStringAsFixed(2)}",
                              style: GoogleFonts.googleSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF008C2A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  /// Back Home Button
                  Bounceable(
                    onTap: () {
                      Get.offAllNamed(Routes.BUTTON_NAVBAR);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
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
                            "Back to Home",
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

                  SizedBox(height: 20),

                  Text(
                    "A confirmation email has been sent to your email address",
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
