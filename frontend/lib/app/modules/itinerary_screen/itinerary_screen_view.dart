import 'package:flutter/material.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'itinerary_screen_binding.dart';
part 'itinerary_screen_controller.dart';

class ItineraryScreenView extends GetView<ItineraryScreenViewController> {
  const ItineraryScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "from".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "\$${controller.price}",
                      style: GoogleFonts.googleSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "per_adult".tr,
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).textTheme.titleSmall!.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              title: "check_availability".tr,
              margin: EdgeInsets.zero,
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "itinerary".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// LEGEND
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "main_stop".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "other_stop".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// TIMELINE LIST
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.itinerary.length,
                itemBuilder: (context, index) {
                  final item = controller.itinerary[index];
                  final isLast = index == controller.itinerary.length - 1;
                  final String stopType = item["stop_type"] ?? "other";
                  final bool isMain = stopType == "main";

                  final String title = item[controller.titleKey] ?? item["title_en"] ?? "";
                  final String subtitle = item[controller.noteKey] ?? item["note_en"] ?? "";
                  final int transportMinutes = item["transport_duration_minutes"] ?? 0;
                  final String transportMode = item["transport_mode"] ?? "Van";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stop Node
                      _timelineItem(
                        isMainStop: isMain,
                        title: title,
                        subtitle: subtitle,
                        isLast: isLast,
                        context: context,
                      ),

                      // Intermediary Transport Section (Rendered only between items)
                      if (!isLast)
                        _transportItem(
                          context: context,
                          mode: transportMode,
                          durationMinutes: transportMinutes,
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Timeline Node for Stops
  Widget _timelineItem({
    required bool isMainStop,
    required String title,
    required String subtitle,
    required bool isLast,
    required BuildContext context,
  }) {
    const Color brandGreen = Color(0xff008C2A);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isMainStop ? brandGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isMainStop
                        ? null
                        : Border.all(color: brandGreen, width: 2),
                  ),
                  child: Icon(
                    isMainStop ? Icons.location_on : Icons.circle,
                    color: isMainStop ? Colors.white : brandGreen,
                    size: isMainStop ? 18 : 10,
                  ),
                ),
                // Only render vertical connector line if NOT the last item
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: brandGreen),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Timeline Node for Transport / Travel between stops
  Widget _transportItem({
    required BuildContext context,
    required String mode,
    required int durationMinutes,
  }) {
    const Color brandGreen = Color(0xff008C2A);

    IconData getTransportIcon(String transportMode) {
      switch (transportMode.toLowerCase()) {
        case 'bus':
        case 'coach':
          return Icons.directions_bus;
        case 'van':
        case 'minivan':
          return Icons.airport_shuttle;
        case 'car':
        case 'taxi':
          return Icons.directions_car;
        case 'walking':
        case 'walk':
          return Icons.directions_walk;
        default:
          return Icons.airport_shuttle;
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: brandGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getTransportIcon(mode),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Container(width: 2, color: brandGreen),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode,
                  style: GoogleFonts.googleSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$durationMinutes ${"mins".tr}",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}