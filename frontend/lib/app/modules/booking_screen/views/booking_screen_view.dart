import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/booking_screen/controllers/booking_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class BookingScreenView extends GetView<BookingScreenController> {
  const BookingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'My Bookings',
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    count: controller.countAll,
                    isSelected:
                        controller.selectedStatus.value == BookingStatus.all,
                    onTap: () => controller.changeStatus(BookingStatus.all),
                    context: context,
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Upcoming',
                    count: controller.countUpcoming,
                    isSelected:
                        controller.selectedStatus.value ==
                        BookingStatus.upcoming,
                    onTap: () =>
                        controller.changeStatus(BookingStatus.upcoming),
                    context: context,
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Completed',
                    count: controller.countCompleted,
                    isSelected:
                        controller.selectedStatus.value ==
                        BookingStatus.completed,
                    onTap: () =>
                        controller.changeStatus(BookingStatus.completed),
                    context: context,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              final items = controller.filteredBookings;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No bookings found.',
                    style: GoogleFonts.googleSans(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(items[index], context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.googleSans(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Color.fromARGB(255, 238, 236, 236),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.googleSans(
                  color: isSelected ? Colors.white : Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, BuildContext context) {
    bool isUpcoming = booking.status == BookingStatus.upcoming;

    return Container(
      margin: EdgeInsets.only(bottom: 16), // Increased slightly for spacing
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graphic Image Layer Stack
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  booking.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              // Header Geo Text Labeling
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.hotelName,
                      style: GoogleFonts.googleSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          booking.location,
                          style: GoogleFonts.googleSans(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Operational Status Notification Banner
              Positioned(
                top: 16,
                right: 16,
                child: _buildStatusTag(isUpcoming),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomType,
                            style: GoogleFonts.googleSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.id,
                            style: GoogleFonts.googleSans(
                              color: Theme.of(
                                context,
                              ).textTheme.titleSmall!.color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${booking.price.toInt()}',
                          style: GoogleFonts.googleSans(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '${booking.nights} night${booking.nights > 1 ? 's' : ''}',
                          style: GoogleFonts.googleSans(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${booking.startDate}  —  ${booking.endDate}',
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).textTheme.titleSmall!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${booking.guests}',
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).textTheme.titleSmall!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                if (isUpcoming) ...[
                  CustomButton(
                    title: 'View Details',
                    margin: EdgeInsets.all(0),
                    onTap: () => controller.showBookingDetailsBottomSheet(
                      context,
                      booking,
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Bounceable(
                          onTap: () {
                            Get.toNamed(Routes.REVIEW_HOTEL);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Write a Review',
                                  style: GoogleFonts.googleSans(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      Expanded(
                        child: Bounceable(
                          onTap: () {
                            Get.toNamed(Routes.CHOOSE_ROOM);
                          },
                          child: Container(
                            width: Get.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                "Booking again",
                                style: GoogleFonts.googleSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(bool isUpcoming) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUpcoming ? Color(0xFFE0E7FF) : Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUpcoming ? Icons.access_time_filled : Icons.check_circle,
            color: isUpcoming ? Color(0xFF2563EB) : Color(0xFF059669),
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            isUpcoming ? 'Upcoming' : 'Completed',
            style: GoogleFonts.googleSans(
              color: isUpcoming ? Color(0xFF2563EB) : Color(0xFF059669),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
