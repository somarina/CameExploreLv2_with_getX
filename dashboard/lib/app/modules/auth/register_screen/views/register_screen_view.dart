// ignore_for_file: deprecated_member_use, unused_local_variable, unused_element, unused_import

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../controllers/register_screen_controller.dart';

class RegisterScreenView extends GetView<RegisterScreenController> {
  const RegisterScreenView({super.key});

  // Dark teal for the button / focus states, gold for the headline —
  // matched to the reference "signup-page.html" design.
  static const primaryColor = Color(0xFF1F6F5C);
  static const goldAccent = Color(0xFFD79A3B);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.themeController.isDarkMode.value;

      final Color pageBg = isDark ? const Color(0xFF031024) : const Color(0xFFF8FAFC);
      final Color fieldFill = isDark
          ? Colors.white.withOpacity(.08)
          : Colors.white.withOpacity(.85);
      final Color fieldBorder = isDark
          ? Colors.white.withOpacity(.18)
          : Colors.black.withOpacity(.08);
      final Color fieldText = isDark ? Colors.white : Colors.black87;
      final Color fieldLabel = isDark ? Colors.white60 : Colors.black54;
      final Color titleColor = goldAccent;
      final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

      return Scaffold(
        backgroundColor: pageBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/angkor_wat.png", fit: BoxFit.cover),

            Container(color: Colors.black.withOpacity(isDark ? .35 : .15)),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 720;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(.08)
                                  : Colors.white.withOpacity(.75),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.10),
                                  blurRadius: 50,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: isMobile
                                ? SingleChildScrollView(
                                    child: _formPanel(
                                      isDark: isDark,
                                      isMobile: isMobile,
                                      fieldFill: fieldFill,
                                      fieldBorder: fieldBorder,
                                      fieldText: fieldText,
                                      fieldLabel: fieldLabel,
                                      titleColor: titleColor,
                                      subtitleColor: subtitleColor,
                                    ),
                                  )
                                : IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Photo panel — sharp, flush against the
                                        // glass form panel, rounded only on its
                                        // outer (left) edge via the parent clip.
                                        Expanded(
                                          flex: 4,
                                          child: Image.asset(
                                            "assets/images/angkor_wat.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: SingleChildScrollView(
                                            child: _formPanel(
                                              isDark: isDark,
                                              isMobile: isMobile,
                                              fieldFill: fieldFill,
                                              fieldBorder: fieldBorder,
                                              fieldText: fieldText,
                                              fieldLabel: fieldLabel,
                                              titleColor: titleColor,
                                              subtitleColor: subtitleColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  bool _isKhmerText(String text) {
    return RegExp(r'[\u1780-\u17FF]').hasMatch(text);
  }

  TextStyle _font(
    String text, {
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return _isKhmerText(text)
        ? GoogleFonts.googleSans(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          )
        : GoogleFonts.spaceGrotesk(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: CircleAvatar(
        backgroundColor: isDark
            ? Colors.white.withOpacity(.10)
            : Colors.black.withOpacity(.06),
        radius: 16,
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 16,
        ),
      ),
    );
  }

  /// Puts two fields side by side (like Phone / Business Type, or
  /// Password / Confirm Password in the reference design). The form
  /// panel already scrolls, so this stays simple and doesn't need its
  /// own mobile fallback.
  Widget _twoUp(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _formPanel({
    required bool isDark,
    required bool isMobile,
    required Color fieldFill,
    required Color fieldBorder,
    required Color fieldText,
    required Color fieldLabel,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Create Company Account",
                    style: _font(
                      "Create Company Account",
                      color: titleColor,
                      fontSize: isMobile ? 22 : 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _circleIconButton(
                      icon: isDark ? Icons.light_mode : Icons.dark_mode,
                      isDark: isDark,
                      onTap: controller.themeController.toggleTheme,
                    ),
                    const SizedBox(width: 8),
                    _circleIconButton(
                      icon: Icons.arrow_back,
                      isDark: isDark,
                      onTap: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Register your tourism company or organization",
              style: _font(
                "Register your tourism company or organization",
                color: subtitleColor,
                fontSize: 13.5,
              ),
            ),

            SizedBox(height: isMobile ? 20 : 26),

            _labeledField(
              label: 'Company / Organization Name',
              required: true,
              titleColor: fieldText,
              child: TextFormField(
                controller: controller.companyNameController,
                style: _font('x', color: fieldText, fontSize: 14),
                cursorColor: primaryColor,
                decoration: _decoration(
                  hint: 'Your company name',
                  fieldFill: fieldFill,
                  fieldBorder: fieldBorder,
                  fieldLabel: fieldLabel,
                ),
                validator: controller.validateCompanyName,
              ),
            ),
            const SizedBox(height: 14),

            _labeledField(
              label: 'Email Address',
              required: true,
              titleColor: fieldText,
              child: TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                style: _font('x', color: fieldText, fontSize: 14),
                cursorColor: primaryColor,
                decoration: _decoration(
                  hint: 'company@example.com',
                  fieldFill: fieldFill,
                  fieldBorder: fieldBorder,
                  fieldLabel: fieldLabel,
                ),
                validator: controller.validateEmail,
              ),
            ),
            const SizedBox(height: 14),

            _twoUp(
              _labeledField(
                label: 'Phone Number',
                required: true,
                titleColor: fieldText,
                child: TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  style: _font('x', color: fieldText, fontSize: 14),
                  cursorColor: primaryColor,
                  decoration: _decoration(
                    hint: '+855 XX XXX XXX',
                    fieldFill: fieldFill,
                    fieldBorder: fieldBorder,
                    fieldLabel: fieldLabel,
                  ),
                  validator: controller.validatePhone,
                ),
              ),
              _labeledField(
                label: 'Business Type',
                titleColor: fieldText,
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedBusinessType.value,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF10233F) : Colors.white,
                    style: _font('x', color: fieldText, fontSize: 14),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: fieldLabel),
                    decoration: _decoration(
                      hint: 'Select type',
                      fieldFill: fieldFill,
                      fieldBorder: fieldBorder,
                      fieldLabel: fieldLabel,
                    ),
                    items: controller.businessTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: controller.setBusinessType,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            _labeledField(
              label: 'Address',
              required: true,
              titleColor: fieldText,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GooglePlaceAutoCompleteTextField(
                    textEditingController: controller.addressController,
                    googleAPIKey: RegisterScreenController.googleMapsApiKey,
                    inputDecoration: _decoration(
                      hint: 'Company address in Cambodia',
                      fieldFill: fieldFill,
                      fieldBorder: fieldBorder,
                      fieldLabel: fieldLabel,
                      suffixIcon: IconButton(
                        tooltip: 'Pick on map',
                        icon: Icon(Icons.map_outlined, color: primaryColor, size: 20),
                        onPressed: controller.openLocationPicker,
                      ),
                    ),
                    textStyle: _font('x', color: fieldText, fontSize: 14),
                    debounceTime: 400,
                    countries: const ['kh'],
                    isLatLngRequired: true,
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      controller.onAddressSelected(
                        prediction.description ?? controller.addressController.text,
                        lat: double.tryParse(prediction.lat ?? ''),
                        lng: double.tryParse(prediction.lng ?? ''),
                      );
                    },
                    itemClick: (Prediction prediction) {
                      controller.onAddressSelected(prediction.description ?? '');
                    },
                    itemBuilder: (context, index, prediction) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined, size: 18, color: primaryColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                prediction.description ?? '',
                                style: _font(
                                  prediction.description ?? '',
                                  color: fieldText,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    seperatedBuilder: Divider(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    isCrossBtnShown: false,
                    containerHorizontalPadding: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Type it, pick a suggestion, or tap the map icon to drop a pin',
                      style: _font('x', color: subtitleColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _twoUp(
              _labeledField(
                label: 'Password',
                required: true,
                titleColor: fieldText,
                child: Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    style: _font('x', color: fieldText, fontSize: 14),
                    cursorColor: primaryColor,
                    decoration: _decoration(
                      hint: 'Create a password',
                      fieldFill: fieldFill,
                      fieldBorder: fieldBorder,
                      fieldLabel: fieldLabel,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: fieldLabel,
                          size: 19,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    validator: controller.validatePassword,
                  ),
                ),
              ),
              _labeledField(
                label: 'Confirm Password',
                required: true,
                titleColor: fieldText,
                child: Obx(
                  () => TextFormField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.obscureConfirmPassword.value,
                    style: _font('x', color: fieldText, fontSize: 14),
                    cursorColor: primaryColor,
                    decoration: _decoration(
                      hint: 'Re-enter password',
                      fieldFill: fieldFill,
                      fieldBorder: fieldBorder,
                      fieldLabel: fieldLabel,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: fieldLabel,
                          size: 19,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    validator: controller.validateConfirmPassword,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: controller.agreedToTerms.value,
                      activeColor: primaryColor,
                      onChanged: controller.toggleAgreedToTerms,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'I agree to the ',
                        style: _font('I agree to the ', color: subtitleColor, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: open Terms of Service
                        },
                        child: Text(
                          'Terms of Service',
                          style: _font(
                            'Terms of Service',
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        ' and ',
                        style: _font(' and ', color: subtitleColor, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: open Privacy Policy
                        },
                        child: Text(
                          'Privacy Policy',
                          style: _font(
                            'Privacy Policy',
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: controller.isLoading.value ? null : controller.register,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Create Account",
                          style: _font(
                            "Create Account",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: _font("Already have an account? ", color: subtitleColor, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: controller.goToSignIn,
                    child: Text(
                      "Sign In",
                      style: _font(
                        "Sign In",
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required Widget child,
    required Color titleColor,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: _font(label, color: titleColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              if (required)
                TextSpan(
                  text: ' *',
                  style: _font('*', color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _decoration({
    required String hint,
    required Color fieldFill,
    required Color fieldBorder,
    required Color fieldLabel,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _font(hint, color: fieldLabel, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: fieldFill,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}