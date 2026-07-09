import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreenView extends GetView<FavoriteScreenController> {
  const FavoriteScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        title: Text(
          "Favorites".tr,
          style: GoogleFonts.googleSans(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Bounceable(
            onTap: () {
              AppBottomSheets.showBottomSheet(
                title: "Create a list".tr,
                controller: controller.createListCtrl,
                focusNode: controller.createListFocusNode,
                label: "List name".tr,
                onDone: () async {
                  // Handle create new list logic here
                  await controller.createFavoriteList();
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 20),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(child: Icon(Icons.add)),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [SizedBox(height: 30), _buildCard(), SizedBox(height: 30),],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCard() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => SizedBox(height: 20),
      itemCount:
          controller.favoriteLists.length, // Replace with actual data count
      itemBuilder: (context, index) {
        final item = controller.favoriteLists[index];
        return GestureDetector(
          onTap: () async {
            // Handle card tap
            final result = await Get.toNamed(
              Routes.FAV_SCREEN_2,
              arguments: {'listName': item['name'], 'listId': item['id']},
            );

            if (result == true) {
              controller.getFavoriteLists();
            }
          },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Get.width,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  // child: Image.asset("")
                  child: Center(child: Icon(Icons.image_outlined, size: 28)),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: GoogleFonts.googleSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "0 activities",
                            style: GoogleFonts.googleSans(
                              fontSize: 14,
                              color: Colors.black54
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 18,
                        color: Colors.grey[900],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
