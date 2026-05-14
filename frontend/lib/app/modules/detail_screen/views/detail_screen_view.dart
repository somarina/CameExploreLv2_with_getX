import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detail_screen_controller.dart';

class DetailScreenView extends GetView<DetailScreenController> {
  const DetailScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
