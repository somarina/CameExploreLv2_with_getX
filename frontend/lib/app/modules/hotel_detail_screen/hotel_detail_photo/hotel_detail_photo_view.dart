import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'hotel_detail_photo_binding.dart';
part 'hotel_detail_photo_controller.dart';

class HotelDetailPhotoView extends GetView<HotelDetailPhotoViewController> {
  const HotelDetailPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Bamboo Bunggalow Photos",
          style: GoogleFonts.googleSans(
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
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 120,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(12),
                    child: Image.asset(
                      "assets/images/bamboo.png",
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
