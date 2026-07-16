import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:frontend/app/modules/favorite_screen/fav_screen_2/fav_screen_2_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

part 'fav_screen_2_binding.dart';

class FavScreen2View extends GetView<FavScreen2ViewController> {
  const FavScreen2View({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Row(
                  children: [
                    _circleButton(
                      theme,
                      child: SvgPicture.asset(
                        "assets/svg/normalBack.svg",
                        width: 26,
                        height: 26,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () => Get.back(),
                    ),

                    const Spacer(),

                    Obx(
                      () => Text(
                        controller.listName.value,
                        style: AppFonts.fontsGeneral.copyWith(
                          fontSize: 18,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    _circleButton(
                      theme,
                      child: Icon(
                        Icons.share,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(text: controller.listName.value),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    _circleButton(
                      theme,
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: _showOptionsBottomSheet,
                    ),
                  ],
                ),

                _buildEmptyList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(
    ThemeData theme, {
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    final theme = Get.theme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: () {
                Get.back();

                controller.renameCtrl.text = controller.listName.value;

                AppBottomSheets.showBottomSheet(
                  title: "Rename list".tr,
                  label: "Enter new list name".tr,
                  controller: controller.renameCtrl,
                  focusNode: controller.renameFocusNode,
                  onDone: () async {
                    await controller.renameFavoriteList();
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.edit, color: theme.colorScheme.primary),
                  const SizedBox(width: 15),
                  Text(
                    "Rename list".tr,
                    style: AppFonts.fontsGeneral.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _deleteWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyList(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: controller.favoriteItems.isEmpty
          ? SizedBox(
              height: Get.height * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "This list is empty".tr,
                    style: AppFonts.fontsSubTitle.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.NEARBY_SCREEN);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Find things to do".tr,
                      style: AppFonts.fontsButton,
                    ),
                  ),
                ],
              ),
            )
          : _buildFavList(context),
    );
  }

  Widget _buildFavList(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.favoriteItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Card(
          color: theme.colorScheme.primaryContainer,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Angkor Wat",
                        style: AppFonts.fontsGeneral.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: theme.textTheme.titleSmall?.color,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Siem Reap",
                            style: AppFonts.fontDescriptionsmall,
                          ),
                        ],
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

  Widget _deleteWidget() {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          AlertDialog(
            backgroundColor: Get.theme.colorScheme.primaryContainer,
            title: Text(
              "Delete list".tr,
              style: AppFonts.fontsGeneral.copyWith(
                color: Get.theme.colorScheme.secondary,
              ),
            ),
            content: Text(
              "delete_list_confirm".trParams({
                'listName': controller.listName.value,
              }),
              style: AppFonts.fontDescriptionsmall,
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text(
                  "Cancel".tr,
                  style: GoogleFonts.googleSans(color: Get.theme.colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await controller.deleteFavoriteList();

                  Get.back();
                  Get.back();
                  Get.back();
                },
                child: Text(
                  "Delete".tr,
                  style: GoogleFonts.googleSans(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.delete, color: Colors.red),
          const SizedBox(width: 15),
          Text(
            "Delete list".tr,
            style: AppFonts.fontsGeneral.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
  // Widget showDialog() {
  //   return GestureDetector(
  //     onTap: () async {
  //       // Handle delete list logic here
  //       await controller.deleteFavoriteList();
  //       Get.dialog(
  //         Column(
  //           mainAxisSize: MainAxisSize.min,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Container(
  //               width: Get.width * 0.8,
  //               padding: EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     "Delete list".tr,
  //                     style: GoogleFonts.googleSans(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.black,
  //                       decoration: TextDecoration.none,
  //                     ),
  //                   ),
  //                   SizedBox(height: 10),
  //                   Text(
  //                     "delete_list_confirm".trParams({
  //                       'listName': controller.listName.value,
  //                     }),
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.googleSans(
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black54,
  //                       decoration: TextDecoration.none,
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: () {
  //                             Get.back();
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.grey[200],
  //                           ),
  //                           child: Text(
  //                             "Cancel".tr,
  //                             style: GoogleFonts.googleSans(
  //                               color: Color(0xff009A3F),
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(width: 10),
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: () async {
  //                             // Handle delete logic here
  //                             await controller.deleteFavoriteList();
  //                             Get.back();
  //                             Get.back();
  //                             Get.back();
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.grey[200],
  //                           ),
  //                           child: Text(
  //                             "Delete".tr,
  //                             style: GoogleFonts.googleSans(
  //                               color: Colors.red,
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //     child: Row(
  //       children: [
  //         Icon(Icons.delete, color: Colors.red),
  //         SizedBox(width: 15),
  //         Text(
  //           "Delete list".tr,
  //           style: GoogleFonts.googleSans(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.red,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
