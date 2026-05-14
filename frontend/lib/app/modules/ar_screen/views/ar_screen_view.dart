import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ar_screen_controller.dart';

class ArScreenView extends GetView<ArScreenController> {
  const ArScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ArScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
