import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String date;
  final String review;
  final String rating;
  final List<String> images;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.date,
    required this.review,
    required this.rating,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// User Info
          Row(
            children: [
              CircleAvatar(radius: 26, backgroundColor: Colors.grey.shade300),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.googleSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.googleSans(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  rating,
                  style: GoogleFonts.googleSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          /// Review Text
          Text(
            review,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.googleSans(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),

          SizedBox(height: 20),

          /// Images
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    images[index],
                    width: 140,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
