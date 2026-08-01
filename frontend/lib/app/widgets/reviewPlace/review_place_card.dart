import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery/gallery_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String date;
  final String review;
  final String rating;
  final String avatar;
  final List<String> images;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.date,
    required this.review,
    required this.rating,
    required this.avatar,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// User Info Header
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
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

          /// Review Text (only renders if non-empty)
          if (review.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              review,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.googleSans(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).textTheme.titleSmall!.color,
              ),
            ),
          ],

          /// Review Images Gallery Horizontal List
          if (images.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Bounceable(
                    onTap: () {
                      Get.to(
                        () => GalleryView(images: images, initialIndex: index),
                        transition: Transition.fadeIn,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 90,
                          height: 90,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final bool hasValidUrl =
        avatar.trim().isNotEmpty && avatar.startsWith("http");

    if (hasValidUrl) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: CachedNetworkImageProvider(avatar),
      );
    }

    final String initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : "?";

    return CircleAvatar(
      radius: 24,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.2),
      child: Text(
        initial,
        style: GoogleFonts.googleSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }
}
