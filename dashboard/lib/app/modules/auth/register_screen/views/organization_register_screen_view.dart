import 'package:dashboard/app/modules/auth/register_screen/controllers/register_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizationRegisterScreenView extends GetView<RegisterScreenController> {
  const OrganizationRegisterScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('fffffff'),
          ],
        ),
      ),
    );
  }
}