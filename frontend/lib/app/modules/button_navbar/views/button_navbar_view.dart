import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/button_navbar_controller.dart';

class ButtonNavbarView extends GetView<ButtonNavbarController> {
  const ButtonNavbarView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ButtonNavbarView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ButtonNavbarView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
