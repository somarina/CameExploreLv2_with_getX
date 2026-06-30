import 'package:flutter/material.dart';
import 'package:frontend/app/modules/discover_screen/search_screen/search_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../custom_textfield/build_textfield.dart';

class SearchScreenView extends GetView<SearchScreenController> {
  const SearchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        title: SizedBox(
          height: 50,
          child: BuildTextfield(
            readOnly: true,
            onTap: () {
              Get.toNamed(Routes.NEARBY_SCREEN);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text("Most search", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              SizedBox(height: 200, child: _buildMostSearch()),
              SizedBox(height: 20),
              Text("Popular places", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              _buildPopularPlaces(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularPlaces() {
    return Obx(
      () => ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final place = controller.popularPlaces[index];
          return Container(
            width: Get.width,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //dak image jol
                  ),
                  SizedBox(width: 20),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place['name'] ?? ''),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14),
                            Text(place['province'] ?? '', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            Text("4.5", style: TextStyle(fontSize: 12)),
                            SizedBox(width: 10),
                            Text("10.7K people searched this"),
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
        separatorBuilder: (context, index) {
          return SizedBox(height: 12);
        },
        itemCount: controller.popularPlaces.length,
      ),
    );
  }

  Widget _buildMostSearch() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Container(
          width: 160,
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 160,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    //dak image jol
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text("4.5"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: .only(left: 10, bottom: 10, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Angkor Wat",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14),
                        Text("Siem Reap", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Text("10.7k searches", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(width: 15);
      },
      itemCount: 5,
    );
  }
}
