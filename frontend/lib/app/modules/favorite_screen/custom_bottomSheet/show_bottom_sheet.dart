import 'package:flutter/material.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/favorite_screen/fav_screen_2/fav_screen_2_controller.dart';
import 'package:get/get.dart';

class AppBottomSheets {
  static Future<dynamic> showBottomSheet({
    required String title,
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    void Function()? onDone,
  }) {
    final theme = Get.theme;

    return Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                      style: AppFonts.fontsGeneral.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),

                  Spacer(),

                  Text(
                    title,
                    style: AppFonts.fontsGeneral.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Spacer(),

                  Obx(() {
                    final controller = Get.find<FavoriteScreenController>();

                    print("Button sees: ${controller.canCreateList.value}");
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
                        style: AppFonts.fontsGeneral.copyWith(
                          fontWeight: canSubmit
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: canSubmit
                              ? theme.colorScheme.primary
                              : theme.textTheme.titleSmall?.color,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                autofocus: true,
                controller: controller,
                focusNode: focusNode,
                style: AppFonts.fontsGeneral.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                decoration: InputDecoration(
                  labelText: label.tr,
                  labelStyle: AppFonts.fontsGeneral.copyWith(
                    color: theme.textTheme.titleSmall?.color,
                  ),

                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor, width: 1),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
