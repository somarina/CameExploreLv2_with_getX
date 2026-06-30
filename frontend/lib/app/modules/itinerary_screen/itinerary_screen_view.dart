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
        decoration: BoxDecoration(
          // color: Theme.of(context).scaffoldBackgroundColor
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.2),
          //     blurRadius: 10,
          //     offset:  Offset(0, 5),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "from",
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
                      "per adult",
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
              title: "Check Availability",
              margin: EdgeInsets.all(0),
              onTap: () {
                // Get.toNamed(Routes.PACKAGE_CHECKOUT);
                Get.back();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Itinerary",
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
                    "MAP",
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
                    "Main stop",
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
                        "Other stop",
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
                title: "2 pickup location options:",
                subtitle: "Krong Siem Reap, Krong Siem Reap",
                isFirst: true,
                context: context,
              ),

              _transportItem(context),

              _timelineItem(
                icon: Icons.location_on,
                title: "Angkor Wat",
                subtitle:
                    "Photo stop, Visit, Guided tour, Sightseeing, Sunrise",
                duration: "(3 hours)",
                context: context,
              ),

              _timelineItem(
                icon: Icons.location_on,
                title: "Ta Prohm Temple",
                subtitle:
                    "Photo stop, Visit, Guided tour, Sightseeing (1 hour)",
                context: context,
              ),

              _timelineItem(
                icon: Icons.circle,
                title: "2 Drop-off location options:",
                subtitle: "Krong Siem Reap, Krong Siem Reap",
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
                  "Bus/coach",
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "(45 minutes)",
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
