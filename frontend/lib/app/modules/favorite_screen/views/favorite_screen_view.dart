import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../controllers/favorite_screen_controller.dart';

class FavoriteScreenView extends GetView<FavoriteScreenController> {
  const FavoriteScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        title: Text(
          "Favorite",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Bounceable(
            onTap: () {
              AppBottomSheets.showBottomSheet(
                title: "Create a list",
                controller: controller.createListCtrl,
                focusNode: controller.createListFocusNode,
                label: "List name",
                onDone: () {
                  // Handle create new list logic here
                  Get.back();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SizedBox(height: 30), _buildCard()],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => SizedBox(height: 20),
      itemCount: 5, // Replace with actual data count
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Handle card tap
            Get.toNamed(Routes.FAV_SCREEN_2);
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
                  child: Center(child: Text("No Image")),
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
                            "Phnom Penh",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "0 activity",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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
