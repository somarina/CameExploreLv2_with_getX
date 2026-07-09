import 'package:flutter/material.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:google_fonts/google_fonts.dart';

class CardPlace extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final String location;
  final double rating;
  final String distance;
  final VoidCallback? onFavorite;
  final double width;
  final bool isFavorite;

  const CardPlace({
    super.key,
    required this.image,
    required this.category,
    required this.title,
    required this.location,
    required this.rating,
    required this.distance,
    this.onFavorite,
    required this.width,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Trending
              // Positioned(
              //   top: 16,
              //   left: 16,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 8,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.primaryContainer,
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text("🔥"),
              //         SizedBox(width: 2),
              //         Text(
              //           "Trending",
              //           style: GoogleFonts.googleSans(
              //             fontWeight: FontWeight.w500,
              //             color: Theme.of(context).colorScheme.secondary,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Favorite
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : Theme.of(context).textTheme.titleSmall!.color,
                    ),
                  ),
                ),
              ),

              // Category
              Positioned(
                bottom: 20,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.googleSans(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: .w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        style: AppFonts.fontsSubTitlew500.copyWith(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.secondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Icon(Icons.star, color: Colors.amber, size: 22),
                    SizedBox(width: 4),
                    Text(
                      "$rating",
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        fontWeight: .bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      " (500+)",
                      style: GoogleFonts.googleSans(
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Location + Distance
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Theme.of(context).textTheme.titleSmall!.color,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.googleSans(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.titleSmall!.color,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Theme.of(context).textTheme.titleSmall!.color,
                    ),
                    Text(
                      distance,
                      style: GoogleFonts.googleSans(
                        //  color: Theme.of(context).textTheme.titleSmall!.color,
                        color: Theme.of(context).textTheme.titleSmall!.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
