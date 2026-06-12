import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

part 'fav_screen_2_binding.dart';
part 'fav_screen_2_controller.dart';

class FavScreen2View extends GetView<FavScreen2ViewController> {
  const FavScreen2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Bounceable(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300]!,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Phnom Penh",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(),
                    Bounceable(
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(text: controller.listName.value,),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300]!,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(child: Icon(Icons.share)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Bounceable(
                      onTap: () {
                        Get.bottomSheet(
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    Get.bottomSheet(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  "Rename list",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  "Done",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.back();
                                      AppBottomSheets.showBottomSheet(
                                        title: "Rename list",
                                        label: "Enter new list name",
                                        controller: controller.renameCtrl,
                                        focusNode: controller.renameFocusNode,
                                        onDone: () {
                                          // Handle rename list logic here
                                          Get.back();
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Color(0xff009A3F),
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          "Rename list",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff009A3F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 30),
                                showDialog(),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300]!,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(child: Icon(Icons.more_vert)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 2,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return Bounceable(
                        onTap: () {},
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        width: 112,
                                        height: 112,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Angkor Wat"),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_sharp,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(child: Text("Siem Reap")),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 20,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 5),
                                            Text("8.9"),
                                            SizedBox(width: 15),
                                            Container(
                                              width: 5,
                                              height: 5,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffCEDFCE),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "Temple",
                                                style: const TextStyle(
                                                  color: Color(0xff009A3F),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 5),
                                            Text("បានរក្សាទុកថ្មីៗ"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showDialog() {
    return GestureDetector(
      onTap: () {
        // Handle delete list logic here
        Get.dialog(
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Delete list",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Are you sure you want to delete your [name] list? All the activities you've saved will be lost.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xff009A3F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle delete logic here
                              Get.back();
                              Get.back();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                            ),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
      },
      child: Row(
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 15),
          Text(
            "Delete list",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
