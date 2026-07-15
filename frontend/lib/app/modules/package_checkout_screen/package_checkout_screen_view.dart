import 'package:flutter/material.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

part 'package_checkout_screen_binding.dart';
part 'package_checkout_screen_controller.dart';

class PackageCheckoutScreenView
    extends GetView<PackageCheckoutScreenViewController> {
  const PackageCheckoutScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          "Guest details",
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bookingCard(context),

            SizedBox(height: 24),

            Text(
              "Guest info",
              style: GoogleFonts.googleSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),

            SizedBox(height: 16),

            _textField(controller.firstNameCtrl, "First name*", context),

            SizedBox(height: 14),

            _textField(controller.lastNameCtrl, "Last name*", context),

            SizedBox(height: 14),

            _textField(controller.emailCtrl, "Email*", context),

            SizedBox(height: 14),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
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
                        hintText: "Mobile*",
                        hintStyle: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            Text(
              "Payment Method",
              style: GoogleFonts.googleSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),

            SizedBox(height: 16),

            Obx(
              () => Container(
                padding: EdgeInsets.all(6),
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

                    Icon(Icons.qr_code_2, color: Colors.green, size: 30),

                    SizedBox(width: 8),

                    Text(
                      "KHQR",
                      style: GoogleFonts.googleSans(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),

                    SizedBox(width: 12),

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
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Popular",
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

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.qr_code, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Scan with ABA, ACLEDA, Wing, or any KHQR-supported app to complete payment instantly.",
                      style: GoogleFonts.googleSans(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.bookingData["title"] ?? "Package Tour",
                          style: GoogleFonts.googleSans(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Text(
                        "\$${controller.price.toStringAsFixed(2)}",
                        style: GoogleFonts.googleSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${controller.adultCount} Adult${controller.adultCount > 1 ? 's' : ''}",
                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Text(
                        "x \$${controller.price.toStringAsFixed(2)}",
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Taxes & fees",
                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Text(
                        "Included",
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Total",
                          style: GoogleFonts.googleSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Text(
                        "\$${controller.total.toStringAsFixed(2)}",
                        style: GoogleFonts.googleSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: controller.themeCtrl.getDark()
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        )
                      : BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: controller.themeCtrl.getDark()
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        )
                      : BorderSide.none,
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
           
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (!controller.validateGuestInfo()) return;
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            SizedBox(height: 20),

                            Text(
                              "Scan KHQR to Pay",
                              style: GoogleFonts.googleSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 20),

                            Container(
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                "assets/svg/qrr.png",
                                height: 260,
                                width: 320,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(height: 16),

                            Text(
                              "Open your banking app and scan this QR code.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.googleSans(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: 24),
                            CustomButton(
                              title: "Done",
                              margin: EdgeInsets.all(0),
                              onTap: () {
                                Get.offAllNamed(
                                  Routes.PACKAGE_CF_BOOKING,
                                  arguments: {
                                    ...controller.bookingData,

                                    "total": controller.total,

                                    "firstName": controller.firstNameCtrl.text
                                        .trim(),
                                    "lastName": controller.lastNameCtrl.text
                                        .trim(),
                                    "email": controller.emailCtrl.text.trim(),
                                    "phone": controller.phoneCtrl.text.trim(),

                                    "payment": controller.selectedPayment.value,

                                    "transactionDate": DateTime.now()
                                        .toIso8601String(),
                                  },
                                );
                              },
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  "Pay via KHQR",
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

  Widget _bookingCard(BuildContext context) {
    final DateTime? selectedDate = controller.bookingData["date"] as DateTime?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://images.unsplash.com/photo-1563492065599-3520f775eeed",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.bookingData["title"] ?? "Package Tour",
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          "5.0 (11311)",
                          style: GoogleFonts.googleSans(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.delete_outline, color: Colors.red),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.local_activity_outlined,
                size: 20,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.bookingData["title"] ?? "Tour Package",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Icon(
                Icons.language,
                size: 20,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Language: ${controller.bookingData["language"] ?? "English"}",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedDate != null
                      ? "${DateFormat('EEEE, dd MMM yyyy').format(selectedDate)} • ${controller.bookingData["startTime"] ?? ""}"
                      : "No date selected",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Icon(
                Icons.people,
                size: 20,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${controller.bookingData["adultCount"] ?? 1} Adult(s)",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.attach_money, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "\$${controller.bookingData["price"] ?? 0}",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.check_circle, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Book now and pay later",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.check_circle, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Free cancellation available",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                ),
              ),
            ],
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
          contentPadding: EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
