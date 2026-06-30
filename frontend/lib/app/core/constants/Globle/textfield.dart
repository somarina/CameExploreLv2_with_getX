import 'package:flutter/material.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isMultiLine;
  final FocusNode? focusNode;
  final String? text;
  final Widget? suffix;
  final bool isPwd;
  final bool isHide;
  final bool readOnly;
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isMultiLine = false,
    this.focusNode,
    this.text,
    this.suffix,
    this.isPwd = false,
    this.isHide = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != null) ...[
          Text(
            text!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
        SizedBox(height: 10),
        TextField(
          readOnly: readOnly,
          style: TextStyle(
            fontWeight: .w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
          focusNode: focusNode,
          obscureText: isPwd && isHide,
          maxLines: isMultiLine ? 10 : 1,
          minLines: isMultiLine ? 5 : 1,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffix,
            suffixIconColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.8),
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.lightPrimaryColor, // focus color
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.redAccent, width: 2),
            ),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }
}
