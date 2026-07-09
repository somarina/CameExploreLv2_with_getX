import 'package:flutter/material.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/favorite_screen/fav_screen_2/fav_screen_2_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomSheets {
  static Future<dynamic> showBottomSheet({
    required String title,
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    void Function()? onDone,
  }) {
    return Get.bottomSheet(
      Container(
        height: Get.height * 0.57,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Cancel".tr,
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Obx(() {
                    bool canCreate =
                        Get.isRegistered<FavoriteScreenController>()
                        ? Get.find<FavoriteScreenController>()
                              .canCreateList
                              .value
                        : false;

                    bool canRename =
                        Get.isRegistered<FavScreen2ViewController>()
                        ? Get.find<FavScreen2ViewController>().canRename.value
                        : false;

                    bool canSubmit = canCreate || canRename;

                    return TextButton(
                      onPressed: canSubmit ? onDone : null,
                      child: Text(
                        "Done".tr,
                        style: GoogleFonts.googleSans(
                          fontWeight: canSubmit
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: canSubmit
                              ? Color(0xff009A3F)
                              : Colors.black54,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                autofocus: true,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xff009A3F), width: 1),
                  ),
                  labelStyle: GoogleFonts.googleSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
