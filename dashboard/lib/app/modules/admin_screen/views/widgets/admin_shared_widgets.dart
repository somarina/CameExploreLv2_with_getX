// ignore_for_file: dead_code, unused_element_parameter

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_colors.dart';

// ══════════════════════════════════════════════════════════════════════════
// Shared action dialogs — view details / confirm (approve/reject/delete/
// suspend) / edit. Used by every "Manage X" page (Places, Hotels, Packages,
// Restaurants, Users) so the interaction pattern is identical everywhere:
//   • eye icon        -> showAdminDetailDialog   (read-only, dimmed backdrop)
//   • pencil icon      -> showAdminEditDialog     (editable form, Save/Cancel)
//   • approve/reject/  -> showAdminConfirmDialog  ("are you sure?" + optional
//     delete/suspend                               reason box for reject)
// ══════════════════════════════════════════════════════════════════════════

/// A modal "wrapper" shell shared by the dialogs below: rounded card,
/// max width, colored icon badge + title/subtitle header — or, when
/// `imageUrl` is provided, a real photo banner across the top instead of
/// the icon (used by the "view details" dialog so the person sees the
/// actual place instead of a generic icon). `showDialog` already dims the
/// rest of the screen (barrierColor) behind it.
class _AdminDialogShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;
  final double maxWidth;
  final String? imageUrl;

  const _AdminDialogShell({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
    this.maxWidth = 440,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AdminColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AdminColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AdminColors.surfaceLight,
                        alignment: Alignment.center,
                        child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: iconColor.withOpacity(0.12),
                      alignment: Alignment.center,
                      child: Icon(Icons.image_not_supported_outlined, color: iconColor, size: 28),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                child: hasImage
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(subtitle!, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary)),
                          ],
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(icon, color: iconColor, size: 21),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 3),
                                  Text(subtitle!, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════ 1. VIEW DETAILS — read-only info dialog ═══════════════
/// Shows every field passed in as a clean label/value list. Background is
/// dimmed automatically by showDialog's default barrier. Pass `imageUrl`
/// (the place's first photo) to show a real photo banner instead of the
/// generic icon badge.
Future<void> showAdminDetailDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData icon = Icons.info_outline_rounded,
  Color iconColor = AdminColors.primary,
  String? imageUrl,
  Widget? statusChip,
  required List<MapEntry<String, String>> fields,
  VoidCallback? onEdit,
}) {
  return showDialog(
    context: context,
    builder: (_) => _AdminDialogShell(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (statusChip != null) ...[statusChip, const SizedBox(height: 14)],
            // Wrapped in Flexible so this section shrinks to whatever space is
            // actually left after the image/header/buttons, instead of always
            // claiming up to 360px — on shorter screens that fixed cap was
            // pushing the dialog past the available height and overflowing.
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final f in fields) _DetailRow(label: f.key, value: f.value.isEmpty ? '—' : f.value),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (onEdit != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.primary,
                        side: BorderSide(color: AdminColors.primary.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text('edit'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.surfaceLight,
                      foregroundColor: AdminColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('close'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════ 2. CONFIRM — "are you sure?" for any dangerous / ═══════
/// ═══════════════    state-changing action (approve/reject/delete/suspend) ═
/// Every destructive or state-changing button in the admin dashboard should
/// route through this so nothing fires on a single accidental click.
Future<void> showAdminConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Color confirmColor,
  IconData icon = Icons.help_outline_rounded,
  bool withReason = false,
  String reasonLabel = '',
  String reasonHint = '',
  bool reasonRequired = false,
  required FutureOr<void> Function(String? reason) onConfirm,
}) {
  final reasonController = TextEditingController();
  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setInnerState) {
        bool submitting = false;
        String? error;
        return _AdminDialogShell(
            icon: icon,
            iconColor: confirmColor,
            title: title,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: GoogleFonts.inter(fontSize: 14, color: AdminColors.textPrimary, height: 1.4)),
                  if (withReason) ...[
                    const SizedBox(height: 16),
                    Text(reasonLabel, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AdminColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: reasonHint,
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary),
                        filled: true,
                        fillColor: AdminColors.background,
                        errorText: error,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.textPrimary,
                            side: BorderSide(color: AdminColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('cancel'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submitting
                              ? null
                              : () async {
                                  final reason = reasonController.text.trim();
                                  if (withReason && reasonRequired && reason.isEmpty) {
                                    setInnerState(() => error = 'this_field_is_required'.tr);
                                    return;
                                  }
                                  setInnerState(() => submitting = true);
                                  await onConfirm(reason.isEmpty ? null : reason);
                                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: submitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                              : Text(confirmLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        );
      },
    ),
  );
}

/// ═══════════════ 3. EDIT — generic editable-form dialog ═══════════════
class AdminEditField {
  final String key;
  final String label;
  final String initialValue;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  const AdminEditField({
    required this.key,
    required this.label,
    required this.initialValue,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });
}

Future<void> showAdminEditDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData icon = Icons.edit_outlined,
  required List<AdminEditField> fields,
  required FutureOr<void> Function(Map<String, String> values) onSave,
}) {
  final controllers = {for (final f in fields) f.key: TextEditingController(text: f.initialValue)};
  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        bool submitting = false;
        return _AdminDialogShell(
          icon: icon,
          iconColor: AdminColors.primary,
          title: title,
          subtitle: subtitle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final f in fields)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.label, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AdminColors.textSecondary)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: controllers[f.key],
                                  maxLines: f.maxLines,
                                  enabled: f.enabled,
                                  keyboardType: f.keyboardType,
                                  style: GoogleFonts.inter(fontSize: 13.5),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: f.enabled ? AdminColors.background : AdminColors.background.withOpacity(0.5),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.textPrimary,
                          side: BorderSide(color: AdminColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('cancel'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () async {
                                setState(() => submitting = true);
                                final values = {for (final f in fields) f.key: controllers[f.key]!.text.trim()};
                                await onSave(values);
                                if (dialogContext.mounted) Navigator.pop(dialogContext);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: submitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                            : Text('save_changes'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Top summary card, e.g. "Total Places / 4 / +8%"
class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminRadii.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              _Badge(text: badgeText, color: badgeColor, bg: badgeBg),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Badge({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdminRadii.chip)),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// A white rounded card container used to wrap charts/tables/sections.
class AdminSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminRadii.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: child,
    );
  }
}

/// Section header with title + subtitle, optionally a trailing widget.
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small colored status pill, e.g. "Pending" / "Approved" / "Rejected"
class AdminStatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const AdminStatusChip({super.key, required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdminRadii.chip)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(text, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// Reusable search field used across pages.
class AdminSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const AdminSearchField({super.key, this.hint = 'Search anything...', this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(AdminRadii.chip),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: AdminColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hint,
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AdminColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}