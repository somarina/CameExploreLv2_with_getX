import 'package:flutter/material.dart';

import '../../../core/constants/app_fonts/app_fonst.dart';

class BuildTextfield extends StatelessWidget {
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const BuildTextfield({
    super.key,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 4,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.primaryContainer,
          hintText: "ស្វែងរកកន្លែងទេសចរណ៍...",
          hintStyle: AppFonts.fontBtnSearch.copyWith(
            color: Theme.of(context).textTheme.titleSmall!.color,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).textTheme.titleSmall!.color,
            size: 30,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}