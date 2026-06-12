import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
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
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 20),
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
            child: Center(child: Icon(Icons.arrow_back_ios)),
          ),
        ),
        title: SizedBox(height: 50, child: BuildTextfield()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff009A3F),
                        ),
                        child: Center(child: Text("icon")),
                      ),
                      SizedBox(height: 10),
                      Text("Name"),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 20);
                },
                itemCount: 5,
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("100 results:"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
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
                            top: 10,
                            right: 10,
                            child: Icon(Icons.favorite),
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Angkor Wat"),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.location_on_sharp),
                              SizedBox(width: 5),
                              Text("Siem Reap, Cambodia"),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  
                                },
                                child: Icon(Icons.star, color: Colors.amber)),
                              SizedBox(width: 5),
                              Text("5.0"),
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
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
