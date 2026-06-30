import 'package:flutter/material.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:frontend/app/widgets/buttons/custome_button.dart';
import 'package:frontend/app/widgets/reviewPlace/review_place_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'reviews_hotel_screen_binding.dart';
part 'reviews_hotel_screen_controller.dart';

class ReviewsHotelScreenView extends GetView<ReviewsHotelScreenViewController> {
  const ReviewsHotelScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "54 Reviews",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.secondary,
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Very good",
                          style: GoogleFonts.googleSans(
                            color: Color(0xFF078C2E),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "8.1",
                                style: GoogleFonts.googleSans(
                                  color: Color(0xFF078C2E),
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " / 10",
                                style: GoogleFonts.googleSans(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 24),

                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ratingBar("Cleanliness", 7.6, context),
                        SizedBox(height: 10),
                        _ratingBar("Location", 10, context),
                        SizedBox(height: 10),
                        _ratingBar("Service", 8.2, context),
                        SizedBox(height: 10),
                        _ratingBar("Amenities", 7.8, context),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              CustomButton(
                title: "Write a review",
                margin: EdgeInsets.all(0),
                onTap: () {
                  Get.toNamed(Routes.WRITE_REVIEW);
                },
              ),
              SizedBox(height: 20),
              _buildReviewItem(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
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
        SizedBox(height: 10),
        ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ReviewCard(
                userName: "Anonymous User",
                date: "Stayed in Apr 2026",
                rating: "7/10",
                review:
                    "Overall, I love the atmosphere but just some rooms have problems with doors and toilets and also not recommend ...",
                images: [
                  "https://images.unsplash.com/photo-1566073771259-6a8506099945",
                  "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa",
                  "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267",
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _ratingBar(String title, double rating, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.googleSans(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        // SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: rating / 10,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF009A3F)),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.googleSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
