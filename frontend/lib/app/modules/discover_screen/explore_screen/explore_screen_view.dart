import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/api/services/category_service.dart';
import 'package:frontend/app/core/api/services/places_services.dart';
import 'package:get/get.dart';

import '../custom_textfield/build_textfield.dart';

part 'explore_screen_binding.dart';
part 'explore_view_controller.dart';

class ExploreView extends GetView<ExploreViewController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        leading: Bounceable(
          onTap: () => Get.back(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset("assets/svg/arrow_back.svg"),
          ),
        ),
        title: SizedBox(height: 50, child: BuildTextfield()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final item = controller.categories[index];

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.getPlaces(category: item["name"]);
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff009A3F),
                              ),
                              child: Center(child: Text(item["icon"] ?? "")),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(item["name"] ?? ""),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("100 results:"),
            ),
            SizedBox(height: 20),
            ListView.separated(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final place = controller.places[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Obx(
                              () => GestureDetector(
                                onTap: () => controller.toggleFavorite(index),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    controller.favorites[index]
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: controller.favorites[index]
                                        ? Colors.red
                                        : Theme.of(
                                            context,
                                          ).textTheme.titleSmall!.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place["name"] ?? "Unnamed Place"),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.location_on_sharp),
                              SizedBox(width: 5),
                              Text(place["province"] ?? "")
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Icon(Icons.star, color: Colors.amber),
                              ),
                              SizedBox(width: 5),
                              Text(place["category"] ?? ""),
                              SizedBox(width: 10),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xffCEDFCE),
                                  borderRadius: BorderRadius.circular(12),
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
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(height: 40);
              },
              itemCount: controller.places.length,
            ),
          
          ],
        ),
      ),
    );
  }
}
