import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/favorite_screen_controller.dart';

class FavoriteScreenView extends GetView<FavoriteScreenController> {
  const FavoriteScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FavoriteScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'FavoriteScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
