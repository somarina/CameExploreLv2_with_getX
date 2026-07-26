import 'package:flutter/material.dart';
import 'package:frontend/app/modules/detail_places_screen/Gallery/gallery_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'hotel_detail_photo_binding.dart';
part 'hotel_detail_photo_controller.dart';

class HotelDetailPhotoView extends GetView<HotelDetailPhotoViewController> {
  const HotelDetailPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Photos (${controller.hotelPhotos.length.toString()})",
          style: GoogleFonts.googleSans(
            fontSize: 20,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.hotelPhotos.isNotEmpty) ...[
                SizedBox(height: 18),

                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.hotelPhotos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () {
                        // Open Fullscreen Gallery
                        Get.to(
                          () => GalleryView(
                            images: controller.hotelPhotos,
                            initialIndex: index,
                          ),
                        );
                      },
                      child: Hero(
                        tag: controller.hotelPhotos[index],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            controller.hotelPhotos[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
