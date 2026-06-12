import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomSheets {
  static Future<dynamic> showBottomSheet({required String title, required String label, TextEditingController? controller, FocusNode? focusNode, void Function()? onDone}) {
    return Get.bottomSheet(
      Container(
        height: Get.height *0.57,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Spacer(),
                  Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
                  Spacer(),
                  GestureDetector(
                    onTap: onDone,
                    child: Text("Done", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                autofocus: true,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xff009A3F), width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
