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
        padding: EdgeInsets.fromLTRB(24, 16, 24, 30),
        decoration: BoxDecoration(),
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
                      "\$10",
                      style: GoogleFonts.googleSans(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 6),
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

            SizedBox(height: 20),

            CustomButton(
              title: "check_availability".tr,
              margin: EdgeInsets.all(0),
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
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              /// MAP
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    "map_placeholder".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 18),

              /// LEGEND
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "main_stop".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(width: 40),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 6),
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

              SizedBox(height: 30),

              /// TIMELINE
              _timelineItem(
                icon: Icons.location_on,
                title: "pickup_options".tr,
                subtitle: "siem_reap_krong".tr,
                isFirst: true,
                context: context,
              ),

              _transportItem(context),

              _timelineItem(
                icon: Icons.location_on,
                title: "angkor_wat_title".tr,
                subtitle: "angkor_wat_details".tr,
                duration: "duration_3h".tr,
                context: context,
              ),

              _timelineItem(
                icon: Icons.location_on,
                title: "ta_prohm_temple".tr,
                subtitle: "ta_prohm_details".tr,
                context: context,
              ),

              _timelineItem(
                icon: Icons.circle,
                title: "dropoff_options".tr,
                subtitle: "siem_reap_krong".tr,
                isLast: true,
                context: context,
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? duration,
    bool isFirst = false,
    bool isLast = false,
    required BuildContext context,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xff008C2A),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 3, color: Color(0xff008C2A)),
                  ),
              ],
            ),
          ),

          SizedBox(width: 18),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
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

                  SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),

                  if (duration != null) ...[
                    SizedBox(height: 8),
                    Text(
                      duration,
                      style: GoogleFonts.googleSans(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transportItem(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xff008C2A),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_bus, color: Colors.white),
                ),
                Expanded(child: Container(width: 3, color: Color(0xff008C2A))),
              ],
            ),
          ),

          SizedBox(width: 18),

          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "bus_coach".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "duration_45m".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
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
