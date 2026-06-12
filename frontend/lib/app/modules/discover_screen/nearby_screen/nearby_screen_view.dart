import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:frontend/app/modules/discover_screen/nearby_screen/nearby_screen_controller.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../custom_textfield/build_textfield.dart';

class NearbyScreenView extends GetView<NearbyScreenController> {
  const NearbyScreenView({super.key});
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
        title: BuildTextfield(),
      ),
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      "Nearby",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 35),
                    Text(
                      "Activities near your current location",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 50),
                    Text(
                      "165 km away",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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
                    Text(
                      "79 activities",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 20),
                _buildNearbyPlaces(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey[300], height: 30),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(Routes.EXPLORE_SCREEN);
          },
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey[700]),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Phnom Penh",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 2),
                      Text("4.5", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Cambodia's capital city",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "150 km away",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
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
                      Text(
                        "50 activities",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        );
      },
    );
  }

}
