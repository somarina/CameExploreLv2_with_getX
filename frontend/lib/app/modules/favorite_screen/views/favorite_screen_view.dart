import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/favorite_screen/controllers/favorite_screen_controller.dart';
import 'package:frontend/app/modules/favorite_screen/custom_bottomSheet/show_bottom_sheet.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class FavoriteScreenView extends GetView<FavoriteScreenController> {
  const FavoriteScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Favorites".tr,
          style: AppFonts.fontHeader.copyWith(
            fontSize: 24,
            color: theme.colorScheme.secondary,
            overflow: TextOverflow.ellipsis,
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
                  await controller.createFavoriteList();
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        if (controller.favoriteLists.isEmpty) {
          return Center(
            child: Text(
              "No favorite lists yet".tr,
              style: AppFonts.fontsGeneral.copyWith(
                color: theme.textTheme.titleSmall?.color,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildCard(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.favoriteLists.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = controller.favoriteLists[index];
        final imageUrl = item["cover_image"] ?? "";

        return GestureDetector(
          onTap: () async {
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
            height: 210,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: Get.width,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                  ),
                  child: imageUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 35,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        )
                      : null,
                ),

                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.fontsGeneral.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Obx(() {
                              final count =
                                  controller.activityCounts[item["id"]
                                      .toString()] ??
                                  0;

                              return Text(
                                "$count ${count == 1 ? 'activity' : 'activities'}",
                                style: AppFonts.fontDescriptionsmall.copyWith(
                                  color: theme.textTheme.titleSmall?.color,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: theme.colorScheme.secondary,
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
