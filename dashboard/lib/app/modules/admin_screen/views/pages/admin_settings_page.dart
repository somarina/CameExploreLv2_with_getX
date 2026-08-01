import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../core/api/services/dashboard_auth_service.dart';
import '../../../../localization/localization_service.dart';
import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

enum _SettingsTab { profile, security, notifications, appearance }

class AdminSettingsPage extends StatefulWidget {
  final AdminScreenController controller;
  const AdminSettingsPage({super.key, required this.controller});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  _SettingsTab _tab = _SettingsTab.profile;

  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _bioCtrl = TextEditingController();

  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    _displayNameCtrl = TextEditingController(
      text: widget.controller.adminName.value,
    );
    _emailCtrl = TextEditingController(
      text:
          box.read<String>('dashboard_email') ??
          widget.controller.adminName.value,
    );
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminTopBar(
                title: 'settings'.tr,
                subtitle: 'settings_subtitle'.tr,
                controller: controller,
              ),
              const SizedBox(height: 24),

              // ---------- Profile summary card ----------
              Obx(
                () => AdminSectionCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AdminColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AdminColors.primary.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          controller.adminName.value.isNotEmpty
                              ? controller.adminName.value[0].toUpperCase()
                              : 'A',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.adminName.value,
                            style: GoogleFonts.inter(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    AdminRadii.chip,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.shield,
                                      size: 13,
                                      color: AdminColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      controller.adminRole.value,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                controller.adminName.value,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: AdminColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------- Tab bar ----------
              AdminSectionCard(
                padding: const EdgeInsets.all(10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 640;
                    final tabs = [
                      _TabButton(
                        icon: Icons.person_outline,
                        label: 'profile'.tr,
                        selected: _tab == _SettingsTab.profile,
                        onTap: () =>
                            setState(() => _tab = _SettingsTab.profile),
                      ),
                      _TabButton(
                        icon: Icons.lock_outline,
                        label: 'security'.tr,
                        selected: _tab == _SettingsTab.security,
                        onTap: () =>
                            setState(() => _tab = _SettingsTab.security),
                      ),
                      _TabButton(
                        icon: Icons.notifications_none_rounded,
                        label: 'notifications'.tr,
                        selected: _tab == _SettingsTab.notifications,
                        onTap: () =>
                            setState(() => _tab = _SettingsTab.notifications),
                      ),
                      _TabButton(
                        icon: Icons.palette_outlined,
                        label: 'appearance'.tr,
                        selected: _tab == _SettingsTab.appearance,
                        onTap: () =>
                            setState(() => _tab = _SettingsTab.appearance),
                      ),
                    ];
                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tabs
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: t,
                                ),
                              )
                              .toList(),
                        ),
                      );
                    }
                    return Row(
                      children: tabs
                          .map(
                            (t) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: t,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ---------- Tab content ----------
              AdminSectionCard(
                padding: const EdgeInsets.all(24),
                child: _buildTabContent(),
              ),
              const SizedBox(height: 20),

              // ---------- Danger zone ----------
              _DangerZoneCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case _SettingsTab.profile:
        return _ProfileTab(
          displayNameCtrl: _displayNameCtrl,
          emailCtrl: _emailCtrl,
          bioCtrl: _bioCtrl,
          onSave: () {
            widget.controller.adminName.value =
                _displayNameCtrl.text.trim().isEmpty
                ? widget.controller.adminName.value
                : _displayNameCtrl.text.trim();
            final box = GetStorage();
            box.write(
              'dashboard_admin_name',
              widget.controller.adminName.value,
            );
            box.write('dashboard_email', _emailCtrl.text.trim());
            Get.snackbar(
              'profile_updated'.tr,
              'profile_updated_message'.tr,
              backgroundColor: AdminColors.surfaceLight,
              colorText: AdminColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      case _SettingsTab.security:
        return _SecurityTab(
          currentPasswordCtrl: _currentPasswordCtrl,
          newPasswordCtrl: _newPasswordCtrl,
          confirmPasswordCtrl: _confirmPasswordCtrl,
          showCurrentPassword: _showCurrentPassword,
          showNewPassword: _showNewPassword,
          onToggleCurrent: () =>
              setState(() => _showCurrentPassword = !_showCurrentPassword),
          onToggleNew: () =>
              setState(() => _showNewPassword = !_showNewPassword),
          onUpdate: () async {
            if (_currentPasswordCtrl.text.trim().isEmpty) {
              Get.snackbar(
                "Error",
                "Current password is required.",
                backgroundColor: AdminColors.redDark,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            if (_newPasswordCtrl.text.length < 8) {
              Get.snackbar(
                "Error",
                "New password must be at least 8 characters.",
                backgroundColor: AdminColors.redDark,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
              Get.snackbar(
                "Error",
                "Passwords do not match.",
                backgroundColor: AdminColors.redDark,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            Get.dialog(
              const Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );

            final response = await DashboardAuthService().changePasswordService(
              currentPassword: _currentPasswordCtrl.text.trim(),
              newPassword: _newPasswordCtrl.text.trim(),
              confirmPassword: _confirmPasswordCtrl.text.trim(),
            );

            Get.back(); // close loading

            if (response["result"] == true) {
              _currentPasswordCtrl.clear();
              _newPasswordCtrl.clear();
              _confirmPasswordCtrl.clear();

              Get.snackbar(
                "Success",
                response["message"] ?? "Password updated successfully.",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            } else {
              Get.snackbar(
                "Failed",
                response["message"] ?? "Unable to update password.",
                backgroundColor: AdminColors.redDark,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        );
      case _SettingsTab.notifications:
        return const _NotificationsTab();
      case _SettingsTab.appearance:
        return const _AppearanceTab();
    }
  }
}

// ══════════════════════════ Tab button ══════════════════════════

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AdminRadii.button),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AdminColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AdminRadii.button),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AdminColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : AdminColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Shared: settings text field ══════════════════════════

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final Widget? suffix;
  final int maxLines;

  const _SettingsField({
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 4 : 0,
          ),
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(AdminRadii.button),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  maxLines: maxLines,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AdminColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: maxLines > 1 ? 14 : 15,
                    ),
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AdminColors.textTertiary,
                    ),
                  ),
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════ Profile tab ══════════════════════════

class _ProfileTab extends StatelessWidget {
  final TextEditingController displayNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController bioCtrl;
  final VoidCallback onSave;

  const _ProfileTab({
    required this.displayNameCtrl,
    required this.emailCtrl,
    required this.bioCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_information'.tr,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 640;
            final fields = [
              Expanded(
                child: _SettingsField(
                  label: 'display_name'.tr,
                  controller: displayNameCtrl,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _SettingsField(
                  label: 'email_username'.tr,
                  controller: emailCtrl,
                ),
              ),
            ];
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsField(
                    label: 'display_name'.tr,
                    controller: displayNameCtrl,
                  ),
                  const SizedBox(height: 18),
                  _SettingsField(
                    label: 'email_username'.tr,
                    controller: emailCtrl,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields,
            );
          },
        ),
        const SizedBox(height: 18),
        _SettingsField(
          label: 'bio_description'.tr,
          controller: bioCtrl,
          hint: 'bio_hint'.tr,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminRadii.button),
              ),
              elevation: 0,
            ),
            child: Text(
              'save_profile'.tr,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════ Security tab ══════════════════════════

class _SecurityTab extends StatelessWidget {
  final TextEditingController currentPasswordCtrl;
  final TextEditingController newPasswordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final bool showCurrentPassword;
  final bool showNewPassword;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onUpdate;

  const _SecurityTab({
    required this.currentPasswordCtrl,
    required this.newPasswordCtrl,
    required this.confirmPasswordCtrl,
    required this.showCurrentPassword,
    required this.showNewPassword,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onUpdate,
  });

  Widget _eyeButton(bool visible, VoidCallback onTap) {
    return IconButton(
      splashRadius: 18,
      onPressed: onTap,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 19,
        color: AdminColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'change_password'.tr,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: 24),
        _SettingsField(
          label: 'current_password'.tr,
          controller: currentPasswordCtrl,
          hint: 'enter_current_password'.tr,
          obscure: !showCurrentPassword,
          suffix: _eyeButton(showCurrentPassword, onToggleCurrent),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 640;
            final newField = _SettingsField(
              label: 'new_password'.tr,
              controller: newPasswordCtrl,
              hint: 'min_8_characters'.tr,
              obscure: !showNewPassword,
              suffix: _eyeButton(showNewPassword, onToggleNew),
            );
            final confirmField = _SettingsField(
              label: 'confirm_new_password'.tr,
              controller: confirmPasswordCtrl,
              hint: 'repeat_new_password'.tr,
              obscure: !showNewPassword,
            );
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [newField, const SizedBox(height: 18), confirmField],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: newField),
                const SizedBox(width: 24),
                Expanded(child: confirmField),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(AdminRadii.button),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'password_requirements'.tr,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _Requirement(text: 'req_at_least_8'.tr),
              _Requirement(text: 'req_one_uppercase'.tr),
              _Requirement(text: 'req_one_number'.tr),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: onUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminRadii.button),
              ),
              elevation: 0,
            ),
            child: Text(
              'update_password'.tr,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Requirement extends StatelessWidget {
  final String text;
  const _Requirement({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '•  ',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════ Notifications tab ══════════════════════════

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab();

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _emailNotifications = true;
  bool _approvalAlerts = true;
  bool _systemAnnouncements = false;
  bool _weeklySummary = true;

  void _savePreferences() {
    Get.snackbar(
      'preferences_saved'.tr,
      'preferences_saved_message'.tr,
      backgroundColor: AdminColors.surfaceLight,
      colorText: AdminColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'notification_preferences'.tr,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: 12),
        _NotificationRow(
          title: 'email_notifications'.tr,
          subtitle: 'email_notifications_subtitle'.tr,
          value: _emailNotifications,
          onChanged: (v) => setState(() => _emailNotifications = v),
        ),
        _NotificationRow(
          title: 'approval_alerts'.tr,
          subtitle: 'approval_alerts_subtitle'.tr,
          value: _approvalAlerts,
          onChanged: (v) => setState(() => _approvalAlerts = v),
        ),
        _NotificationRow(
          title: 'system_announcements'.tr,
          subtitle: 'system_announcements_subtitle'.tr,
          value: _systemAnnouncements,
          onChanged: (v) => setState(() => _systemAnnouncements = v),
        ),
        _NotificationRow(
          title: 'weekly_summary'.tr,
          subtitle: 'weekly_summary_subtitle'.tr,
          value: _weeklySummary,
          onChanged: (v) => setState(() => _weeklySummary = v),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminRadii.button),
              ),
              elevation: 0,
            ),
            child: Text(
              'save_preferences'.tr,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotificationRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AdminColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════ Appearance tab ══════════════════════════

class _AppearanceTab extends StatefulWidget {
  const _AppearanceTab();

  @override
  State<_AppearanceTab> createState() => _AppearanceTabState();
}

class _AppearanceTabState extends State<_AppearanceTab> {
  static const _langLabels = {'enUS': 'English', 'kmKH': 'Khmer'};
  static const _langCodes = {'English': 'enUS', 'Khmer': 'kmKH'};

  late String _language = _langLabels[Get.locale?.languageCode] ?? 'English';

  void _saveAppearance() {
    final box = GetStorage();
    box.write('dashboard_language', _language);
    Get.snackbar(
      'appearance_saved'.tr,
      'appearance_saved_message'.tr,
      backgroundColor: AdminColors.surfaceLight,
      colorText: AdminColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _pickLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AdminColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Khmer'].map((lang) {
            return ListTile(
              leading: Icon(Icons.language, color: AdminColors.textSecondary),
              title: Text(
                lang,
                style: GoogleFonts.inter(
                  color: AdminColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.pop(context, lang),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null && selected != _language) {
      setState(() => _language = selected);
      // Same mechanism as the working theme toggle: change the value,
      // persist it, then trigger the real GetX locale change so every
      // screen using .tr picks it up immediately.
      final code = _langCodes[selected] ?? 'enUS';
      LocalizationService().changeLocale(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appearance'.tr,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: AdminColors.border, height: 1),
        const SizedBox(height: 24),
        Text(
          'theme'.tr,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          // Read the observable HERE, synchronously inside Obx's own callback.
          // Obx only tracks .value reads that happen during this call — reading
          // it later inside LayoutBuilder's inner builder (which runs during
          // layout, not build) is invisible to Obx and triggers the
          // "improper use of GetX" error.
          final isDark = themeController.isDarkMode.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 480;
              final lightCard = _ThemeCard(
                label: 'light'.tr,
                icon: Icons.wb_sunny_rounded,
                selected: !isDark,
                previewColor: Colors.white,
                onTap: () {
                  if (isDark) themeController.toggleTheme();
                },
              );
              final darkCard = _ThemeCard(
                label: 'dark'.tr,
                icon: Icons.nightlight_round,
                selected: isDark,
                previewColor: AdminColors.background,
                onTap: () {
                  if (!isDark) themeController.toggleTheme();
                },
              );
              if (isMobile) {
                return Column(
                  children: [lightCard, const SizedBox(height: 14), darkCard],
                );
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
        Text(
          'language'.tr,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AdminRadii.button),
            onTap: _pickLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(AdminRadii.button),
                border: Border.all(color: AdminColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 19,
                    color: AdminColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _language,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AdminColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _saveAppearance,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminRadii.button),
              ),
              elevation: 0,
            ),
            child: Text(
              'save_appearance'.tr,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════ Theme selector card ══════════════════════════

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color previewColor;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.previewColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AdminRadii.card),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(AdminRadii.card),
            border: Border.all(
              color: selected ? AdminColors.primary : AdminColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AdminColors.primary.withOpacity(0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: AdminColors.primary.withOpacity(0.25),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
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
                    color: previewColor == Colors.white
                        ? AdminColors.border
                        : AdminColors.border.withOpacity(0.6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: previewColor == Colors.white
                              ? AdminColors.border
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AdminColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? AdminColors.primary
                        : AdminColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AdminColors.primary
                          : AdminColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Danger zone ══════════════════════════

class _DangerZoneCard extends StatelessWidget {
  final AdminScreenController controller;
  const _DangerZoneCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.redDark.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AdminRadii.card),
        border: Border.all(color: AdminColors.red.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'danger_zone'.tr,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AdminColors.red,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: AdminColors.border, height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sign_out_all_sessions'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'sign_out_all_sessions_subtitle'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => _showSignOutDialog(context, controller),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.red,
                  side: const BorderSide(color: AdminColors.red),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminRadii.button),
                  ),
                ),
                child: Text(
                  'sign_out'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(
    BuildContext context,
    AdminScreenController controller,
  ) {
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
                      color: AdminColors.surfaceLight.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Lottie.asset(
                            'assets/icons/logout.json',
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'sign_out'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'sign_out_confirm_message'.tr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AdminColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: AdminColors.background
                                      .withOpacity(0.6),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'cancel'.tr,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.logout();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AdminColors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'sign_out'.tr,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
}
