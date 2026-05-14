import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ai_screen_controller.dart';

class AiScreenView extends GetView<AiScreenController> {
  const AiScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AiScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AiScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
