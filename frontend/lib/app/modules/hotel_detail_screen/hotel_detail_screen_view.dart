import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

part 'hotel_detail_screen_binding.dart';
part 'hotel_detail_screen_controller.dart';

class HotelDetailScreenView extends GetView<HotelDetailScreenViewController> {
  const HotelDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomBar(context),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Stack(
          children: [
            _buildHeader(context),
            _buildThreeIcons(context),
            _buildcontent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildcontent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Get.height * .32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Rating
            _buildContentTitle(context),
            SizedBox(height: 10),

            _buildAmenities(context),
            SizedBox(height: 20),

            _buildLocation(context),
            SizedBox(height: 30),

            _buildNearby(context),
            SizedBox(height: 20),

            _buildContact(context),
            SizedBox(height: 30),

            _buildReviews(context),
            SizedBox(height: 20),

            _buildPolicy(context),
            SizedBox(height: 20),
            // SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews(BuildContext context) {
    return Column(
      children: [
        Bounceable(
          onTap: () {
            Get.toNamed(Routes.REVIEW_HOTEL);
          },
          child: Row(
            children: [
              Text(
                "review".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "8.1",
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " / 10",
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "good".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "54 ${'review'.tr}",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "cleaniness".tr,
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        "7.6",
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "location".tr,
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        "8.7",
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 50),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "service".tr,
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        "8.2",
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "amenities".tr,
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        "7.8",
                        style: GoogleFonts.googleSans(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        SizedBox(height: 10),

        _buildReviewItem(context),
      ],
    );
  }

  Widget _buildPolicy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "policies".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.access_time_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "checkin_out".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "checkin_".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "checkout_".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "front_desk".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "main_guest".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/child.svg",
              width: 24,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "child_policies".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "child_policies_stay".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "child_policies_fees".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/Restaurant.svg",
              width: 24,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "breakfast_title".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "breakfast_availability".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "breakfast_fees".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/pet.svg",
              width: 24,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "pet".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "pet_allowance".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: Get.width * 0.8,
                  child: Text(
                    "pet_service_animals".tr,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ReviewCard(
          userName: "Anonymous User",
          date: "${"stayed_in".tr} Apr 2026",
          rating: "7/10",
          review:
              "Overall, I love the atmosphere but just some rooms have problems with doors and toilets and also not recommend ...",
          images: [
            "https://images.unsplash.com/photo-1566073771259-6a8506099945",
            "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa",
            "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267",
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildContact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "contact".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),

        Row(
          children: [
            Icon(
              Icons.phone,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              "+855 70 665 766",
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.email,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              "kampotbamboo@gmail.com",
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNearby(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bounceable(
          onTap: () => controller.showNearbyBottomSheet(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "nearby_poplular".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildPlaceItem(context);
          },
        ),
      ],
    );
  }

  Widget _buildPlaceItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xffE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Text(
              "Farm Link",
              style: GoogleFonts.googleSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ),

          Text(
            "770 m",
            style: GoogleFonts.googleSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildLocation(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: .start,
  //     children: [
  //       Text(
  //         "location".tr,
  //         style: GoogleFonts.googleSans(
  //           fontSize: 20,
  //           fontWeight: FontWeight.w600,
  //           color: Theme.of(context).colorScheme.secondary,
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       Container(
  //         width: double.infinity,
  //         margin: const EdgeInsets.symmetric(horizontal: 5),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).colorScheme.primaryContainer,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.08),
  //               blurRadius: 15,
  //               offset: const Offset(0, 8),
  //             ),
  //           ],
  //         ),
  //         child: Padding(
  //           padding: EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               /// MAP CARD
  //               Container(
  //                 width: double.infinity,
  //                 height: 160,
  //                 decoration: BoxDecoration(
  //                   color: Color(0xffE8EEF3),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Stack(
  //                   alignment: Alignment.center,
  //                   children: [
  //                     Image.asset(
  //                       'assets/images/location_icon.gif',
  //                       width: 70,
  //                       height: 70,
  //                     ),

  //                     Positioned(
  //                       bottom: 18,
  //                       child: Container(
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 14,
  //                           vertical: 6,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: Theme.of(
  //                             context,
  //                           ).colorScheme.primaryContainer,
  //                           borderRadius: BorderRadius.circular(100),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black.withOpacity(0.1),
  //                               blurRadius: 6,
  //                             ),
  //                           ],
  //                         ),
  //                         child: Text(
  //                           controller.detailCtrl.place['name'] ??
  //                               "Unknown Place",
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: GoogleFonts.googleSans(
  //                             fontWeight: FontWeight.w500,
  //                             fontSize: 14,
  //                             color: Theme.of(context).colorScheme.secondary,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               SizedBox(height: 15),

  //               /// ADDRESS
  //               Container(
  //                 width: double.infinity,
  //                 padding: EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade100,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Text(
  //                       "${controller.detailCtrl.place['province']}, Cambodia",
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: GoogleFonts.googleSans(color: Colors.grey[700]),
  //                     ),
  //                     Spacer(),
  //                     Icon(Icons.navigation, size: 16, color: Colors.grey[700]),
  //                     Text(
  //                       "${controller.homeCtrl.calculateDistance(controller.detailCtrl.place["latitude"], controller.detailCtrl.place["longitude"]).toStringAsFixed(2)} km",

  //                       style: GoogleFonts.googleSans(color: Colors.grey[700]),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               SizedBox(height: 18),

  //               /// BUTTON
  //               Container(
  //                 width: double.infinity,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(30),

  //                   color: Theme.of(context).colorScheme.primary,
  //                 ),
  //                 child: Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     borderRadius: BorderRadius.circular(30),
  //                     onTap: () => controller.detailCtrl.openGoogleMaps(),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(Icons.navigation, color: Colors.white),
  //                         SizedBox(width: 8),
  //                         Text(
  //                           "get_direction".tr,
  //                           style: GoogleFonts.googleSans(
  //                             color: Colors.white,
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildLocation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "location".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),

        /// MAP
        Container(
          height: 180,
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
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.green, size: 26),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                "J599+F5W, kampot, kampot Province, Cambodia",
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  fontSize: 12,
                ),
              ),
            ),
            Icon(Icons.copy, color: Colors.green, size: 14),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenities(BuildContext context) {
    Widget amenityItem(String icon, String titleKey) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 16, height: 16),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                titleKey.tr, // .tr applied directly to the localization keys
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "popular_amenities".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  amenityItem("assets/svg/parking.svg", "free_parking"),
                  amenityItem("assets/svg/wifi.svg", "free_wifi"),
                  amenityItem("assets/svg/massage.svg", "massage"),
                  amenityItem("assets/svg/front_desk.svg", "front_desk_"),
                ],
              ),
            ),

            SizedBox(
              width: 20,
            ), // Reduced width slightly to prevent text overflow layout constraints

            Expanded(
              child: Column(
                children: [
                  amenityItem("assets/svg/Restaurant.svg", "restaurant"),
                  amenityItem("assets/svg/bar.svg", "bar"),
                  amenityItem("assets/svg/water_sport.svg", "water_sports"),
                  amenityItem("assets/svg/water_park.svg", "water_park"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Bamboo Bungalow",
                style: GoogleFonts.googleSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 6),

        /// Location
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.green, size: 26),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                "J599+F5W, kampot, kampot Province, Cambodia",
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  fontSize: 12,
                ),
              ),
            ),

            SizedBox(width: 4),
            Bounceable(
              onTap: () {},
              child: Text(
                "view_map".tr,
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        Divider(),
        Column(
          children: [
            SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "8.1/10",
                      style: GoogleFonts.googleSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "good".tr,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "54 reviews",
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "the staff were extremely friendly, welcoming, and helpful.".tr,
              style: GoogleFonts.googleSans(
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Divider(),
      ],
    );
  }

  Widget _circleButton(String asset, BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: 26,
          height: 26,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThreeIcons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Bounceable(
              onTap: () {
                Get.back();
              },
              child: _circleButton("assets/svg/normalBack.svg", context),
            ),
            Row(
              children: [
                _circleButton("assets/svg/normalShare.svg", context),
                SizedBox(width: 16),
                _circleButton("assets/svg/normalFav.svg", context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Get.height * .36,
          width: Get.width,
          child: Stack(
            children: [
              Bounceable(
                onTap: () {
                  Get.toNamed(Routes.HOTEL_PHOTO);
                },
                child: PageView(
                  onPageChanged: controller.currentIndex.call,
                  children: [
                    Image.asset("assets/images/bamboo.png", fit: BoxFit.cover),
                    Image.asset(
                      "assets/images/homescreen/slider2.png",
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/images/homescreen/slider3.png",
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 46,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(
                    () => AnimatedSmoothIndicator(
                      activeIndex: controller.currentIndex.value,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        expansionFactor: 3,
                        dotColor: Colors.white.withOpacity(.5),
                        activeDotColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 110,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "start_at".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "USD ",
                    style: GoogleFonts.googleSans(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "10\$",
                    style: GoogleFonts.googleSans(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Spacer(),

          SizedBox(
            height: 50,
            width: Get.width * 0.5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Get.toNamed(Routes.CHOOSE_ROOM);
              },
              child: Text(
                "choose_room".tr,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
