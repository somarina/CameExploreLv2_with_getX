// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

import '../../../../localization/localization_service.dart';
import '../../controllers/company_screen_controller.dart';
import '../widgets/company_top_bar.dart';

enum _SettingsTab { profile, security, appearance }

class CompanySettingsPage extends StatefulWidget {
  final CompanyScreenController controller;
  final bool isDesktop;
  final bool isDark;
  final Color pageBg;
  final Color cardBg;
  final Color cardBorder;
  final Color titleColor;
  final Color subtitleColor;
  final Color mutedColor;
  final Color primaryColor;
  final Color redColor;

  const CompanySettingsPage({
    super.key,
    required this.controller,
    required this.isDesktop,
    required this.isDark,
    required this.pageBg,
    required this.cardBg,
    required this.cardBorder,
    required this.titleColor,
    required this.subtitleColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.redColor,
  });

  @override
  State<CompanySettingsPage> createState() => _CompanySettingsPageState();
}

class _CompanySettingsPageState extends State<CompanySettingsPage> {
  _SettingsTab _tab = _SettingsTab.profile;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _bioCtrl = TextEditingController();

  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;

  // ── Appearance: language state (mirrors the admin appearance tab) ──
  static const _langLabels = {'enUS': 'English', 'kmKH': 'Khmer'};
  static const _langCodes = {'English': 'enUS', 'Khmer': 'kmKH'};
  late String _language = _langLabels[Get.locale?.languageCode] ?? 'English';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.controller.companyName.value);
    _emailCtrl = TextEditingController(text: widget.controller.companyEmail.value);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _snack(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: widget.cardBg,
      colorText: widget.titleColor,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveAppearance() {
    final box = GetStorage();
    box.write('dashboard_language', _language);
    _snack("appearance_saved".tr, "appearance_saved_message".tr);
  }

  void _pickLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: widget.cardBg.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Lottie.asset('assets/icons/language_translator_globe.json', repeat: true),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "select_language".tr,
                          style: companyFont("x", color: widget.titleColor, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "select_language_message".tr,
                          textAlign: TextAlign.center,
                          style: companyFont("x", color: widget.subtitleColor, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ...['English', 'Khmer'].map((lang) {
                          final isSelected = lang == _language;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, lang),
                                style: TextButton.styleFrom(
                                  backgroundColor: isSelected ? widget.primaryColor : (widget.titleColor == Colors.white ? Colors.white : Colors.black).withOpacity(0.06),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(color: isSelected ? widget.primaryColor : widget.cardBorder),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.language, size: 16, color: isSelected ? Colors.white : widget.mutedColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      lang,
                                      style: companyFont(lang, color: isSelected ? Colors.white : widget.titleColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                          child: Text(
                            "cancel".tr,
                            style: companyFont("x", color: widget.mutedColor, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (selected != null && selected != _language) {
      setState(() => _language = selected);
      final code = _langCodes[selected] ?? 'enUS';
      LocalizationService().changeLocale(code);
    }
  }

  void _saveProfile() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) widget.controller.companyName.value = name;
    widget.controller.companyEmail.value = _emailCtrl.text.trim();

    final box = GetStorage();
    box.write("dashboard_admin_name", widget.controller.companyName.value);
    box.write("dashboard_email", widget.controller.companyEmail.value);

    _snack("profile_updated".tr, "profile_updated_message".tr);
  }

  void _updatePassword() {
    if (_currentPasswordCtrl.text.trim().isEmpty) {
      _snack("Error", "Current password is required.");
      return;
    }
    if (_newPasswordCtrl.text.length < 8) {
      _snack("Error", "New password must be at least 8 characters.");
      return;
    }
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      _snack("passwords_do_not_match".tr, "passwords_do_not_match_message".tr);
      return;
    }
    // TODO: wire to DashboardAuthService().changePasswordService(...)
    _currentPasswordCtrl.clear();
    _newPasswordCtrl.clear();
    _confirmPasswordCtrl.clear();
    _snack("password_updated".tr, "password_updated_message".tr);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isDesktop ? 28 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyTopBar(
                title: "settings".tr,
                subtitle: "settings_subtitle".tr,
                controller: widget.controller,
                isDesktop: widget.isDesktop,
                isDark: widget.isDark,
                titleColor: widget.titleColor,
                subtitleColor: widget.subtitleColor,
                mutedColor: widget.mutedColor,
                cardBg: widget.cardBg,
                cardBorder: widget.cardBorder,
                primaryColor: widget.primaryColor,
                showSearch: false,
              ),
              const SizedBox(height: 24),
              _profileSummaryCard(),
              const SizedBox(height: 20),
              _tabBar(),
              const SizedBox(height: 20),
              _card(child: _buildTabContent()),
              const SizedBox(height: 20),
              _dangerZoneCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(24)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.cardBorder),
      ),
      child: child,
    );
  }

  Widget _profileSummaryCard() {
    return Obx(() {
      final name = widget.controller.companyName.value;
      return _card(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(.35), blurRadius: 18, offset: const Offset(0, 6))],
              ),
              child: Text(
                name.isNotEmpty ? name.characters.first.toUpperCase() : "C",
                style: companyFont("C", color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: companyFont(name, color: widget.titleColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: widget.primaryColor.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_rounded, size: 13, color: widget.primaryColor),
                            const SizedBox(width: 5),
                            Text("Company", style: companyFont("Company", color: widget.primaryColor, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.controller.companyEmail.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: companyFont("x", color: widget.subtitleColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _tabBar() {
    final tabs = [
      _tabButton(icon: Icons.person_outline, label: "profile".tr, tab: _SettingsTab.profile),
      _tabButton(icon: Icons.lock_outline, label: "security".tr, tab: _SettingsTab.security),
      _tabButton(icon: Icons.palette_outlined, label: "appearance".tr, tab: _SettingsTab.appearance),
    ];
    return _card(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: tabs.map((t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: t)).toList()),
      ),
    );
  }

  Widget _tabButton({required IconData icon, required String label, required _SettingsTab tab}) {
    final selected = _tab == tab;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _tab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? widget.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : widget.subtitleColor),
              const SizedBox(width: 8),
              Text(label, style: companyFont(label, color: selected ? Colors.white : widget.subtitleColor, fontSize: 13.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case _SettingsTab.profile:
        return _profileTab();
      case _SettingsTab.security:
        return _securityTab();
      case _SettingsTab.appearance:
        return _appearanceTab();
    }
  }

  // ── Profile tab ──────────────────────────────────────────────────
  Widget _profileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("profile_information".tr, style: companyFont("x", color: widget.titleColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _fieldLabel("display_name".tr),
        _textField(_nameCtrl, hint: "Company name"),
        const SizedBox(height: 18),
        _fieldLabel("email_username".tr),
        _textField(_emailCtrl, hint: "you@company.com"),
        const SizedBox(height: 18),
        _fieldLabel("bio_description".tr),
        _textField(_bioCtrl, hint: "bio_hint".tr, maxLines: 4),
        const SizedBox(height: 22),
        _primaryButton(label: "save_profile".tr, onTap: _saveProfile),
      ],
    );
  }

  // ── Security tab ─────────────────────────────────────────────────
  Widget _securityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("change_password".tr, style: companyFont("x", color: widget.titleColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _fieldLabel("current_password".tr),
        _textField(
          _currentPasswordCtrl,
          hint: "enter_current_password".tr,
          obscure: !_showCurrentPassword,
          suffix: IconButton(
            icon: Icon(_showCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19, color: widget.mutedColor),
            onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
          ),
        ),
        const SizedBox(height: 18),
        _fieldLabel("new_password".tr),
        _textField(
          _newPasswordCtrl,
          hint: "min_8_characters".tr,
          obscure: !_showNewPassword,
          suffix: IconButton(
            icon: Icon(_showNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19, color: widget.mutedColor),
            onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
          ),
        ),
        const SizedBox(height: 18),
        _fieldLabel("confirm_new_password".tr),
        _textField(_confirmPasswordCtrl, hint: "repeat_new_password".tr, obscure: true),
        const SizedBox(height: 22),
        _primaryButton(label: "update_password".tr, onTap: _updatePassword),
      ],
    );
  }

  // ── Appearance tab ───────────────────────────────────────────────
  Widget _appearanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("theme".tr, style: companyFont("x", color: widget.titleColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Obx(() {
          final isDark = widget.controller.themeController.isDarkMode.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 480;
              final lightCard = _themeCard(
                label: "light".tr,
                icon: Icons.wb_sunny_rounded,
                selected: !isDark,
                previewColor: Colors.white,
                onTap: () {
                  if (isDark) widget.controller.themeController.toggleTheme();
                },
              );
              final darkCard = _themeCard(
                label: "dark".tr,
                icon: Icons.nightlight_round,
                selected: isDark,
                previewColor: const Color(0xFF111827),
                onTap: () {
                  if (!isDark) widget.controller.themeController.toggleTheme();
                },
              );
              if (isMobile) {
                return Column(children: [lightCard, const SizedBox(height: 14), darkCard]);
              }
              return Row(
                children: [
                  Expanded(child: lightCard),
                  const SizedBox(width: 16),
                  Expanded(child: darkCard),
                ],
              );
            },
          );
        }),
        const SizedBox(height: 24),
        Text("language".tr, style: companyFont("x", color: widget.titleColor, fontSize: 13.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.language, size: 19, color: widget.mutedColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_language, style: companyFont(_language, color: widget.titleColor, fontSize: 14)),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: widget.mutedColor),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: _primaryButton(label: "save_appearance".tr, onTap: _saveAppearance),
        ),
      ],
    );
  }

  Widget _themeCard({
    required String label,
    required IconData icon,
    required bool selected,
    required Color previewColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? widget.primaryColor : widget.cardBorder, width: selected ? 2 : 1),
            boxShadow: selected
                ? [
                    BoxShadow(color: widget.primaryColor.withOpacity(0.45), blurRadius: 16, spreadRadius: 1),
                    BoxShadow(color: widget.primaryColor.withOpacity(0.25), blurRadius: 28, spreadRadius: 2),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: previewColor == Colors.white ? widget.cardBorder : widget.cardBorder.withOpacity(0.6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: previewColor == Colors.white ? widget.cardBorder : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(color: widget.primaryColor, borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: selected ? widget.primaryColor : widget.mutedColor),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: companyFont(label, color: selected ? widget.primaryColor : widget.titleColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Danger zone ───────────────────────────────────────────────────
  Widget _dangerZoneCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.redColor.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.redColor.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("danger_zone".tr, style: companyFont("x", color: widget.redColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Divider(color: widget.cardBorder, height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("sign_out_all_sessions".tr, style: companyFont("x", color: widget.titleColor, fontSize: 14.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text("sign_out_all_sessions_subtitle".tr, style: companyFont("x", color: widget.subtitleColor, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => _confirmSignOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.redColor,
                  side: BorderSide(color: widget.redColor),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("sign_out".tr, style: companyFont("x", color: widget.redColor, fontSize: 13.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: widget.cardBg.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Lottie.asset('assets/icons/logout.json', repeat: true),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "sign_out".tr,
                          style: companyFont("x", color: widget.titleColor, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "sign_out_confirm_message".tr,
                          textAlign: TextAlign.center,
                          style: companyFont("x", color: widget.subtitleColor, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: (widget.titleColor == Colors.white ? Colors.white : Colors.black).withOpacity(0.06),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  "cancel".tr,
                                  style: companyFont("x", color: widget.titleColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.controller.logout();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: widget.redColor,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  "sign_out".tr,
                                  style: companyFont("x", color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: companyFont(text, color: widget.titleColor, fontSize: 13.5, fontWeight: FontWeight.w600)),
      );

  Widget _textField(TextEditingController controller, {required String hint, int maxLines = 1, bool obscure = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      maxLines: obscure ? 1 : maxLines,
      obscureText: obscure,
      style: companyFont("x", color: widget.titleColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: companyFont("x", color: widget.mutedColor, fontSize: 13.5),
        suffixIcon: suffix,
        filled: true,
        fillColor: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.primaryColor, width: 1.4)),
      ),
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: companyFont(label, color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}
