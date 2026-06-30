import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

part 'choose_room_screen_binding.dart';
part 'choose_room_screen_controller.dart';

class ChooseRoomScreenView extends GetView<ChooseRoomScreenViewController> {
  const ChooseRoomScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Choose your room",
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            _buildBookingCard(context),
            SizedBox(height: 24),
            _buildRoomList(context),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Double Economy",
                    style: GoogleFonts.googleSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),

                  SizedBox(height: 16),

                  _buildImageSlider(context),

                  SizedBox(height: 20),

                  _buildRoomInfo(context),

                  SizedBox(height: 20),

                  _buildAmenities(context),

                  SizedBox(height: 24),

                  Text(
                    "Free cancellation",
                    style: GoogleFonts.googleSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),

                  SizedBox(height: 16),

                  _buildCancellationSection(context),

                  SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "USD ",
                                style: GoogleFonts.googleSans(
                                  color: Colors.red,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: "10\$",
                                style: GoogleFonts.googleSans(
                                  color: Colors.red,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Incl. taxes & fees",
                          style: GoogleFonts.googleSans(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.titleSmall!.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  _buildBottomBar(context),

                  SizedBox(height: 20),
                ],
              ),
            ),
            Divider(thickness: 5, color: Colors.grey.shade300),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Bounceable(
                onTap: () => controller.pickDateRange(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Check-in & Check-out",
                      style: GoogleFonts.googleSans(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                    SizedBox(height: 8),

                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.dateText,
                              style: GoogleFonts.googleSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),

                          Text(
                            "${controller.nights} night(s)",
                            style: GoogleFonts.googleSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(height: 70, width: 1, color: Colors.grey.shade300),

            SizedBox(width: 8),

            Expanded(
              flex: 4,
              child: Bounceable(
                onTap: () {
                  controller.showRoomGuestBottomSheet(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rooms & guests",
                      style: GoogleFonts.googleSans(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Obx(
                          () => Text(
                            "${controller.rooms.value}",
                            style: GoogleFonts.googleSans(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),

                        SizedBox(width: 12),

                        Icon(
                          Icons.person_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Obx(
                          () => Text(
                            "${controller.adults.value}",
                            style: GoogleFonts.googleSans(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),

                        SizedBox(width: 12),

                        Icon(
                          Icons.child_care_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Obx(
                          () => Text(
                            "${controller.children.value}",
                            style: GoogleFonts.googleSans(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeFactor: 0.16,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              controller.changeIndex(index);
            },
          ),
          items: controller.imgList.map((img) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(img, fit: BoxFit.cover),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Obx(
          () => AnimatedSmoothIndicator(
            activeIndex: controller.currentIndex.value,
            count: controller.imgList.length,
            effect: ExpandingDotsEffect(
              dotWidth: 9,
              dotHeight: 9,
              dotColor: Colors.grey,
              activeDotColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "25 m² / 269 ft²",
            style: GoogleFonts.googleSans(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),

        Container(height: 30, width: 1, color: Colors.grey.shade300),

        Expanded(
          child: Center(
            child: Text(
              "1 king bed",
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),

        Container(height: 30, width: 1, color: Colors.grey.shade300),

        Expanded(
          child: Center(
            child: Text(
              "Mountain view",
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _AmenityTile(Icons.bathtub_outlined, "Private bathroom"),
              _AmenityTile(Icons.ac_unit, "Air conditioning"),
              _AmenityTile(Icons.wifi, "Free Wi-Fi"),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _AmenityTile(Icons.coffee_outlined, "Coffee/tea maker"),
              _AmenityTile(Icons.balcony_outlined, "Balcony"),
              _AmenityTile(Icons.smoke_free_outlined, "Non-smoking"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationSection(BuildContext context) {
    return Column(
      children: [
        _AmenityTile(
          Icons.check_circle_outline,
          "Free cancellation before 23:59, Jun19",
          greenText: true,
        ),
        _AmenityTile(Icons.person_outline, "Price for 2 adults"),
        _AmenityTile(Icons.child_care_outlined, "Your kid can stay for FREE!"),
        _AmenityTile(Icons.credit_card_outlined, "Prepay online"),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return CustomButton(
      title: "Book Now",
      margin: EdgeInsets.all(0),
      onTap: () {
        if (controller.checkInDate == null || controller.checkOutDate == null) {
          Get.snackbar(
            "Select Date",
            "Please select your check-in and check-out dates first.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          );
          return;
        }

        Get.toNamed(
          Routes.GUEST_INFO,
          arguments: {
            'checkIn': controller.checkInDate,
            'checkOut': controller.checkOutDate,
            'rooms': controller.rooms.value,
            'adults': controller.adults.value,
            'children': controller.children.value,
          },
        );
      },
    );
  }
}

class _AmenityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool greenText;

  const _AmenityTile(this.icon, this.title, {this.greenText = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.googleSans(
                fontSize: 13,
                color: greenText
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
