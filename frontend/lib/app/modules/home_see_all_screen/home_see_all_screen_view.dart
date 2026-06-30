import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/modules/home_screen/controllers/home_screen_controller.dart';
import 'package:frontend/app/widgets/cardPlace/card_place.dart';
import 'package:get/get.dart';

part 'home_see_all_screen_binding.dart';
part 'home_see_all_screen_controller.dart';

class HomeSeeAllScreenView extends GetView<HomeSeeAllScreenViewController> {
  const HomeSeeAllScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBtnSearch(context),
              _buildCategory(),
              _buildListview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtnSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Bounceable(
            onTap: () {
              Get.back();
            },
            child: SvgPicture.asset(
              "assets/svg/arrow_back.svg",
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  //get tv search screen
                },
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.primaryContainer,
                  filled: true,
                  hintText: "ស្វែងរកកន្លែងទេសចរណ៍...",
                  hintStyle: AppFonts.fontBtnSearch.copyWith(
                    color: Theme.of(context).textTheme.titleSmall!.color,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.titleSmall!.color,
                    size: 30,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(width: 2, color: Colors.transparent),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListview() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildContainer(index);
      },
    );
  }

  Widget _buildContainer(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Obx(
          () => CardPlace(
            width: Get.width,
            image: "assets/images/homescreen/slider1.png",
            category: "Temple",
            title: "អង្គរវត្ត",
            location: "សៀមរាប, ប្រទេសកម្ពុជា",
            rating: 4.9,
            distance: "200.10 km",
            isFavorite: controller.homeCtrl.favorites[index],
            onFavorite: () => controller.homeCtrl.toggleFavorite(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                // var category = CategoryModel.fromMap(categoryData[index]);
                return Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Bounceable(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: CachedNetworkImage(
                            imageUrl: "",
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Icon",
                          style: AppFonts.fontCategory.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: 6,
            ),
          ),
        ],
      ),
    );
  }
}
