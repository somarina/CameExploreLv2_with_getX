import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

part 'about_app_screen_binding.dart';
part 'about_app_screen_controller.dart';

class AboutAppScreenView extends GetView<AboutAppScreenViewController> {
  const AboutAppScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SvgPicture.asset("frontend/assets/icons/arrow_back.svg"),
        title: Text("អំពី CamExplore"),
      ),
      body: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 170,
              height: 170,
            ),
          ),
        ],
      ),
    );
  }
}
