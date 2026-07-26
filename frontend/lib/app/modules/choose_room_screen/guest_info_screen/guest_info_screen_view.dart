import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/booking_services.dart';
import 'package:frontend/app/modules/booking_screen/controllers/booking_screen_controller.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:frontend/app/modules/profile_screen/userProfile_screen/user_profile_screen_view.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

part 'guest_info_screen_binding.dart';
part 'guest_info_screen_controller.dart';

class GuestInfoScreenView extends GetView<GuestInfoScreenViewController> {
  const GuestInfoScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          "guest_details".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bookingCard(context),
            const SizedBox(height: 24),
            Text(
              "guest_info".tr,
              style: GoogleFonts.googleSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            _textField(controller.firstNameCtrl, "first_name_hint".tr, context),
            const SizedBox(height: 14),
            _textField(controller.lastNameCtrl, "last_name_hint".tr, context),
            const SizedBox(height: 14),
            _textField(controller.emailCtrl, "email_hint".tr, context),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "+855",
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  Expanded(
                    child: TextField(
                      controller: controller.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: "mobile_hint".tr,
                        hintStyle: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "payment_method".tr,
              style: GoogleFonts.googleSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: "KHQR",
                      groupValue: controller.selectedPayment.value,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        controller.selectedPayment.value = value ?? "KHQR";
                      },
                    ),
                    const Icon(Icons.qr_code_2, color: Colors.green, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      "khqr".tr,
                      style: GoogleFonts.googleSans(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "pay_via_khqr".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "popular".tr,
                        style: GoogleFonts.googleSans(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.qr_code, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "khqr_instruction".tr,
                      style: GoogleFonts.googleSans(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildPriceSummaryCard(context),

            const SizedBox(height: 30),

            Row(
              children: [
                Text(
                  "Note ",
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  "(Optional)",
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller.noteCtrl,
              maxLines: 5,
              maxLength: 250,
              decoration: InputDecoration(
                hintText: "add_your_request".tr,
                hintStyle: GoogleFonts.googleSans(
                  color: Theme.of(context).textTheme.titleSmall!.color,
                ),
                filled: true,
                fillColor: controller.themeCtrl.getDark()
                    ? Color(0xFF1a1a1a)
                    : Color(0xffF3F4F6),

                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(24),
                //   borderSide: BorderSide.none,
                // ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                counterText: "",
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(
                () => Text(
                  "${controller.noteLength.value}/250",
                  style: GoogleFonts.googleSans(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          controller.isLoading.value = true;

                          try {
                            final now = DateTime.now();

                            controller.transactionDate.value = DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(now);

                            if (!controller.validateGuestInfo()) {
                              return;
                            }

                            await showModalBottomSheet(
                              context: context,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "scan_to_pay".tr,
                                        style: GoogleFonts.googleSans(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Image.asset(
                                        "assets/svg/qrr.png",
                                        height: 260,
                                        width: 320,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "scan_instruction".tr,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.googleSans(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      CustomButton(
                                        title: "done".tr,
                                        margin: EdgeInsets.zero,
                                        onTap: () async {
                                          Get.back();

                                          String? createdBookingId =
                                              await controller.createBooking();

                                          if (createdBookingId != null) {
                                            final int count =
                                                controller.roomsCount;
                                            final String roomsText = count > 1
                                                ? "$count Rooms"
                                                : "$count Room";

                                            Get.offAllNamed(
                                              Routes.CONFIRM_BOOKING,
                                              arguments: {
                                                "bookingRef": createdBookingId,
                                                "firstName": controller
                                                    .firstNameCtrl
                                                    .text,
                                                "lastName": controller
                                                    .lastNameCtrl
                                                    .text,
                                                "email":
                                                    controller.emailCtrl.text,
                                                "phone":
                                                    controller.phoneCtrl.text,
                                                "checkIn": controller.checkIn,
                                                "checkOut": controller.checkOut,
                                                "roomType":
                                                    controller.roomTypeName,
                                                "hotel": controller.hotelName,
                                                "guests":
                                                    "${controller.adultsCount} Adults, ${controller.childrenCount} Children",
                                                "rooms": roomsText,
                                                "totalPrice":
                                                    "\$${controller.calculatedTotalPrice.toStringAsFixed(0)}",
                                                "transactionDate": DateFormat(
                                                  'MMM dd, yyyy hh:mm a',
                                                ).format(DateTime.now()),
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              },
                            );
                          } finally {
                            controller.isLoading.value = false;
                          }
                        },

                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "pay_via_khqr".tr,
                          style: GoogleFonts.googleSans(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: controller.roomTypeName,
                            style: GoogleFonts.googleSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          if (controller.roomsCount > 1)
                            TextSpan(
                              text: "  (${controller.roomsCount} Rooms)",
                              style: GoogleFonts.googleSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      "\$${controller.pricePerNight.toStringAsFixed(0)} x ${controller.nights > 0 ? controller.nights : 1} ${controller.nights == 1 ? 'night' : 'nights'}",
                      style: GoogleFonts.googleSans(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "\$${controller.calculatedTotalPrice.toStringAsFixed(0)}",
                style: GoogleFonts.googleSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  "taxes_and_fees".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Text(
                "included".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(
                child: Text(
                  "total".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Text(
                "\$${controller.calculatedTotalPrice.toStringAsFixed(0)}",
                style: GoogleFonts.googleSans(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(BuildContext context) {
    // Dynamic values from roomType map
    final String roomName =
        controller.roomType["name_en"] ??
        controller.roomType["name_kh"] ??
        "Standard Room";
    final int capacity =
        controller.roomType["capacity"] ??
        (controller.adultsCount + controller.childrenCount);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "check_in".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.checkInText,
                        style: GoogleFonts.googleSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "after_14_00".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      Text(
                        "nights".trParams({
                          'count': controller.nights.toString(),
                        }),
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "check_out".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.checkOutText,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.googleSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "before_12_00".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        roomName,
                        style: GoogleFonts.googleSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        "room_count".trParams({
                          'count': '${controller.roomsCount}',
                        }),
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _roomInfoRow(
                  Icons.person_outline,
                  "price_for_adults".trParams({'count': '$capacity'}),
                  context,
                ),
                _roomInfoRow(Icons.block, "non_smoking".tr, context),
                _roomInfoRow(
                  Icons.free_breakfast_outlined,
                  "breakfast_available".tr,
                  context,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "free_cancellation".tr,
                        style: GoogleFonts.googleSans(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE8F8F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.discount_outlined,
                        color: Color(0xff00897B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "special_discount".tr,
                          style: GoogleFonts.googleSans(
                            color: const Color(0xff00897B),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomInfoRow(IconData icon, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint,
    BuildContext context,
  ) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        style: GoogleFonts.googleSans(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
          ),
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
