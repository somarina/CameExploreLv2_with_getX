import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/discover_screen_controller.dart';

class DiscoverScreenView extends GetView<DiscoverScreenController> {
  const DiscoverScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DiscoverScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DiscoverScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
