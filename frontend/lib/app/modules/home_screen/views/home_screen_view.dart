import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_screen_controller.dart';

class HomeScreenView extends GetView<HomeScreenController> {
  const HomeScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'HomeScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
