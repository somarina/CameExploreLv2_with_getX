import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/forget_password_controller.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text('ភ្លេចពាក្យសម្ងាត់',style: GoogleFonts.kantumruyPro(fontSize: 24,color: Colors.black,fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          
        ],
      )
    );
  }
}
