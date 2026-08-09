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
          'my_bookings'.tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Obx(
              () => Row(
                children: [
                  _buildFilterChip(
                    label: 'all'.tr,
                    count: controller.countAll,
                    isSelected:
                        controller.selectedStatus.value == BookingStatus.all,
                    onTap: () => controller.changeStatus(BookingStatus.all),
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'upcoming'.tr,
                    count: controller.countUpcoming,
                    isSelected:
                        controller.selectedStatus.value ==
                        BookingStatus.upcoming,
                    onTap: () =>
                        controller.changeStatus(BookingStatus.upcoming),
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'completed'.tr,
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
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }

              final items = controller.filteredBookings;
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchMyBookings(),
                  child: ListView(
                    children: [
                      const SizedBox(height: 150),
                      Center(
                        child: Text(
                          'no_bookings_found'.tr,
                          style: GoogleFonts.googleSans(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMyBookings(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(items[index], context);
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 50),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color.fromARGB(255, 238, 236, 236),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.googleSans(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
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
    bool isUpcoming =
        booking.status == BookingStatus.upcoming ||
        booking.status == BookingStatus.pending;

    bool isPackage = booking.bookingType == 'package';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  booking.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: Icon(
                        isPackage ? Icons.tour : Icons.hotel,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
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
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.85,
                      child: Text(
                        booking
                            .hotelName, // Contains Package Name or Hotel Name
                        style: GoogleFonts.googleSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isPackage && booking.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
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
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _buildStatusTag(isUpcoming),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                            isPackage ? booking.hotelName : booking.roomType,
                            style: GoogleFonts.googleSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                          isPackage
                              ? ''
                              : (booking.nights == 1
                                    ? 'night_singular'.tr
                                    : 'nights_plural'.trParams({
                                        'count': booking.nights.toString(),
                                      })),
                          style: GoogleFonts.googleSans(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPackage ||
                                booking.endDate.isEmpty ||
                                booking.endDate == booking.startDate
                            ? booking.startDate
                            : '${booking.startDate}  —  ${booking.endDate}',
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).textTheme.titleSmall!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.people_outline,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
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
                const SizedBox(height: 20),
                if (isUpcoming) ...[
                  CustomButton(
                    title: 'view_details'.tr,
                    margin: EdgeInsets.zero,
                    onTap: () => controller.showBookingDetailsBottomSheet(
                      context,
                      booking,
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      // --- 1. WRITE A REVIEW BUTTON ---
                      Expanded(
                        child: Bounceable(
                          onTap: () async {
                            final routeName = isPackage
                                ? Routes.PACKAGE_REVIEW
                                : Routes.REVIEW_HOTEL;

                            final result = await Get.toNamed(
                              routeName,
                              arguments: {
                                'id': isPackage
                                    ? booking.packageId
                                    : booking.hotelId,
                                'hotel_id': booking.hotelId,
                                'package_id': booking.packageId,
                                'booking_id': booking.id,
                                'name_en': booking.hotelName,
                                'name_km': booking.hotelName,
                                'hotelName': booking.hotelName,
                                'image_url': booking.imageUrl,
                                'imageUrl': booking.imageUrl,
                                'images': [booking.imageUrl],
                                'check_in': booking.startDate,
                              },
                            );

                            if (result == true) {
                              controller.fetchMyBookings();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                const SizedBox(width: 8),
                                Text(
                                  'write_a_review'.tr,
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
                      const SizedBox(width: 12),

                      // --- 2. BOOK AGAIN BUTTON ---
                      Expanded(
                        child: Bounceable(
                          onTap: () {
                            if (isPackage) {
                              Get.toNamed(
                                Routes.PACKAGE_DETAIL,
                                arguments: {
                                  "id": booking.packageId ?? booking.id,
                                  "package_id": booking.packageId ?? booking.id,
                                  "name_en": booking.nameEn,
                                  "name_km": booking.nameKm,
                                  "price_per_person": booking.price,
                                  "duration_days": booking.nights,
                                  "description_en": booking.note,
                                  "image_url": booking.imageUrl,
                                  "images": booking.images,
                                  "itinerary": booking.itinerary,
                                },
                              );
                            } else {
                              Get.toNamed(
                                Routes.CHOOSE_ROOM,
                                arguments: {
                                  'id': booking.hotelId,
                                  'hotel_id': booking.hotelId,
                                  'name_en': booking.nameEn,
                                  'image_url': booking.imageUrl,
                                  'location': booking.location,
                                },
                              );
                            }
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
                                "booking_again".tr,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUpcoming ? const Color(0xFFE0E7FF) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUpcoming ? Icons.access_time_filled : Icons.check_circle,
            color: isUpcoming
                ? const Color(0xFF2563EB)
                : const Color(0xFF059669),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isUpcoming ? 'upcoming'.tr : 'completed'.tr,
            style: GoogleFonts.googleSans(
              color: isUpcoming
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF059669),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}