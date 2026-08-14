import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/admin_export/admin_export.dart';
import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../../models/admin_models.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

/// Generic "Manage X" page — same list / search / filter / approve / reject
/// / delete workflow as AdminManagePlacesPage, but driven off
/// AdminListingItem so Manage Hotels, Manage Packages, and Manage
/// Restaurants can all share one page instead of tripling the UI code.
class AdminManageListingPage extends StatefulWidget {
  final AdminScreenController controller;
  final String title;
  final String subtitle;
  final String searchHint;
  final String typeColumnLabel;
  final String locationColumnLabel;
  final String priceColumnLabel;
  final String exportSheetName;
  final RxList<AdminListingItem> items;
  final RxBool isLoading;
  final void Function(AdminListingItem) onApprove;
  final void Function(AdminListingItem item, String? reason) onReject;
  final void Function(AdminListingItem) onDelete;

  /// Builds the editable fields (label + starting value) for the "Edit"
  /// dialog. Kept as a callback rather than hard-coded because hotels,
  /// packages, and restaurants each expose a different subset of editable
  /// data even though they share this one page widget.
  final List<AdminEditField> Function(AdminListingItem item) editFieldsBuilder;

  /// Persists the edited values (keyed the same as editFieldsBuilder's
  /// AdminEditField.key) back to the right service/endpoint.
  final Future<void> Function(AdminListingItem item, Map<String, String> values) onEdit;

  const AdminManageListingPage({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.typeColumnLabel,
    required this.locationColumnLabel,
    required this.priceColumnLabel,
    required this.exportSheetName,
    required this.items,
    required this.isLoading,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
    required this.editFieldsBuilder,
    required this.onEdit,
  });

  @override
  State<AdminManageListingPage> createState() => _AdminManageListingPageState();
}

class _AdminManageListingPageState extends State<AdminManageListingPage> {
  PlaceStatus? _filter; // null = All
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = widget.items;
      final total = all.length;
      final pendingCount = all.where((i) => i.status == PlaceStatus.pending).length;
      final approvedCount = all.where((i) => i.status == PlaceStatus.approved).length;
      final rejectedCount = all.where((i) => i.status == PlaceStatus.rejected).length;

      final filtered = all.where((i) {
        final matchesFilter = _filter == null || i.status == _filter;
        final q = _query.toLowerCase();
        final matchesQuery = q.isEmpty ||
            i.name.toLowerCase().contains(q) ||
            i.owner.toLowerCase().contains(q) ||
            i.location.toLowerCase().contains(q);
        return matchesFilter && matchesQuery;
      }).toList();

      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 768;
      final isTablet = screenWidth < 1200;

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminTopBar(title: widget.title, subtitle: widget.subtitle, controller: widget.controller),
                const SizedBox(height: 24),

                _ResponsiveStats(
                  total: total,
                  pending: pendingCount,
                  approved: approvedCount,
                  rejected: rejectedCount,
                  isMobile: isMobile,
                  filter: _filter,
                  onSelect: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 24),

                AdminSectionCard(
                  padding: EdgeInsets.all(isMobile ? 12 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AdminSearchField(
                              hint: widget.searchHint,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ExportButton(
                            onTap: () => exportListingToExcel(filtered, widget.exportSheetName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: isMobile ? 6 : 8,
                        runSpacing: isMobile ? 6 : 8,
                        children: [
                          _FilterChip(label: 'All ($total)', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                          _FilterChip(label: 'Pending ($pendingCount)', selected: _filter == PlaceStatus.pending, onTap: () => setState(() => _filter = PlaceStatus.pending)),
                          _FilterChip(label: 'Approved ($approvedCount)', selected: _filter == PlaceStatus.approved, onTap: () => setState(() => _filter = PlaceStatus.approved)),
                          _FilterChip(label: 'Rejected ($rejectedCount)', selected: _filter == PlaceStatus.rejected, onTap: () => setState(() => _filter = PlaceStatus.rejected)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!isMobile) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _TableHeader(
                            typeLabel: widget.typeColumnLabel,
                            locationLabel: widget.locationColumnLabel,
                            priceLabel: widget.priceColumnLabel,
                          ),
                        ),
                        Divider(height: 24, color: AdminColors.border),
                      ],
                      if (widget.isLoading.value && filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: AdminColors.primary),
                            ),
                          ),
                        )
                      else if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 36, color: AdminColors.textSecondary),
                                const SizedBox(height: 10),
                                Text('no_places_match_filter'.tr, style: GoogleFonts.inter(color: AdminColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else if (isMobile)
                        Column(
                          children: filtered
                              .map((i) => _ListingCard(
                                    item: i,
                                    typeLabel: widget.typeColumnLabel,
                                    locationLabel: widget.locationColumnLabel,
                                    priceLabel: widget.priceColumnLabel,
                                    onView: () => _viewDetails(context, i),
                                    onEdit: () => _editItem(context, i),
                                    onApprove: () => _confirmApprove(context, i),
                                    onReject: () => _confirmReject(context, i),
                                    onDelete: () => _confirmDelete(context, i),
                                  ))
                              .toList(),
                        )
                      else
                        ...filtered.map((i) => _ListingRow(
                              item: i,
                              onView: () => _viewDetails(context, i),
                              onEdit: () => _editItem(context, i),
                              onApprove: () => _confirmApprove(context, i),
                              onReject: () => _confirmReject(context, i),
                              onDelete: () => _confirmDelete(context, i),
                            )),
                      const SizedBox(height: 8),
                      Text(
                        'Showing ${filtered.length} of $total',
                        style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── View: dimmed-background dialog showing every field we have ──
  void _viewDetails(BuildContext context, AdminListingItem item) {
    showAdminDetailDialog(
      context,
      title: item.name,
      subtitle: item.subtitle,
      icon: Icons.storefront_outlined,
      iconColor: item.imageColor,
      imageUrl: item.imageUrl,
      statusChip: _statusChip(item.status),
      fields: [
        MapEntry('col_company'.tr, item.owner),
        MapEntry(widget.typeColumnLabel, item.typeLabel),
        MapEntry(widget.locationColumnLabel, item.location),
        MapEntry(widget.priceColumnLabel, item.price),
        MapEntry('col_submitted'.tr, item.submittedDate),
      ],
      onEdit: () => _editItem(context, item),
    );
  }

  // ── Edit: pre-filled, editable form; Save persists via widget.onEdit ──
  void _editItem(BuildContext context, AdminListingItem item) {
    showAdminEditDialog(
      context,
      title: 'edit_details'.tr,
      subtitle: item.name,
      fields: widget.editFieldsBuilder(item),
      onSave: (values) async {
        await widget.onEdit(item, values);
        Get.snackbar('changes_saved'.tr, item.name);
      },
    );
  }

  // ── Approve: confirm before flipping status ──
  void _confirmApprove(BuildContext context, AdminListingItem item) {
    showAdminConfirmDialog(
      context,
      title: 'approve_question'.tr,
      message: '${'approve_confirm_message'.tr}\n\n"${item.name}"',
      confirmLabel: 'approve'.tr,
      confirmColor: AdminColors.green,
      icon: Icons.check_circle_outline_rounded,
      onConfirm: (_) => widget.onApprove(item),
    );
  }

  // ── Reject: confirm + optional reason, so the owner knows why ──
  void _confirmReject(BuildContext context, AdminListingItem item) {
    showAdminConfirmDialog(
      context,
      title: 'reject_question'.tr,
      message: '${'reject_confirm_message'.tr}\n\n"${item.name}"',
      confirmLabel: 'reject'.tr,
      confirmColor: AdminColors.red,
      icon: Icons.cancel_outlined,
      withReason: true,
      reasonLabel: 'reason_optional'.tr,
      reasonHint: 'reject_reason_hint'.tr,
      onConfirm: (reason) => widget.onReject(item, reason),
    );
  }

  // ── Delete: destructive, always confirm first ──
  void _confirmDelete(BuildContext context, AdminListingItem item) {
    showAdminConfirmDialog(
      context,
      title: '${'delete_question'.tr} "${item.name}"?',
      message: 'action_cannot_be_undone'.tr,
      confirmLabel: 'delete'.tr,
      confirmColor: AdminColors.red,
      icon: Icons.delete_outline_rounded,
      onConfirm: (_) => widget.onDelete(item),
    );
  }
}

// ══════════════════════════ Export button ══════════════════════════

class _ExportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ExportButton({required this.onTap});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _hovering ? AdminColors.surfaceLight : Colors.transparent,
            border: Border.all(color: _hovering ? AdminColors.primary.withOpacity(0.5) : AdminColors.border),
            borderRadius: BorderRadius.circular(AdminRadii.chip),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 18, color: _hovering ? AdminColors.primary : AdminColors.textPrimary),
              const SizedBox(width: 8),
              Text('export'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _hovering ? AdminColors.primary : AdminColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Stat row ══════════════════════════

class _ResponsiveStats extends StatelessWidget {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final bool isMobile;
  final PlaceStatus? filter;
  final ValueChanged<PlaceStatus?> onSelect;
  const _ResponsiveStats({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.isMobile,
    required this.filter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatBox(label: 'All', value: '$total', color: AdminColors.textPrimary, icon: Icons.grid_view_rounded, selected: filter == null, onTap: () => onSelect(null)),
      _StatBox(label: 'pending'.tr, value: '$pending', color: AdminColors.amber, icon: Icons.schedule_rounded, selected: filter == PlaceStatus.pending, onTap: () => onSelect(PlaceStatus.pending)),
      _StatBox(label: 'approved'.tr, value: '$approved', color: AdminColors.green, icon: Icons.check_circle_outline_rounded, selected: filter == PlaceStatus.approved, onTap: () => onSelect(PlaceStatus.approved)),
      _StatBox(label: 'rejected'.tr, value: '$rejected', color: AdminColors.red, icon: Icons.cancel_outlined, selected: filter == PlaceStatus.rejected, onTap: () => onSelect(PlaceStatus.rejected)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 110,
      ),
      itemBuilder: (_, index) => cards[index],
    );
  }
}

class _StatBox extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _StatBox({required this.label, required this.value, required this.color, required this.icon, required this.selected, required this.onTap});

  @override
  State<_StatBox> createState() => _StatBoxState();
}

class _StatBoxState extends State<_StatBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _hovering ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected ? AdminColors.surfaceLight : AdminColors.surface,
            borderRadius: BorderRadius.circular(AdminRadii.card),
            border: Border.all(
              color: widget.selected ? widget.color.withOpacity(0.7) : (_hovering ? widget.color.withOpacity(0.4) : AdminColors.border),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: (_hovering || widget.selected) ? [BoxShadow(color: widget.color.withOpacity(0.16), blurRadius: 16, offset: const Offset(0, 8))] : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: widget.color.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: int.tryParse(widget.value) ?? 0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text('$value', style: GoogleFonts.spaceGrotesk(fontSize: 19, fontWeight: FontWeight.w700, color: widget.color)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Filter chip ══════════════════════════

class _FilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? LinearGradient(colors: [AdminColors.primary, AdminColors.primary.withOpacity(0.8)]) : null,
            color: selected ? null : (_hovering ? AdminColors.surfaceLight : AdminColors.background),
            borderRadius: BorderRadius.circular(AdminRadii.chip),
            boxShadow: selected ? [BoxShadow(color: AdminColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Text(widget.label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : AdminColors.textPrimary)),
        ),
      ),
    );
  }
}

// ══════════════════════════ Table header ══════════════════════════

class _TableHeader extends StatelessWidget {
  final String typeLabel;
  final String locationLabel;
  final String priceLabel;
  const _TableHeader({required this.typeLabel, required this.locationLabel, required this.priceLabel});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textSecondary, letterSpacing: 0.4);
    Widget cell(int flex, String label) => Expanded(
          flex: flex,
          child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
        );
    return Row(
      children: [
        cell(3, 'col_place'.tr),
        cell(2, 'col_company'.tr),
        cell(2, typeLabel),
        cell(1, locationLabel),
        cell(1, priceLabel),
        cell(1, 'col_submitted'.tr),
        cell(2, 'col_status'.tr),
        Expanded(flex: 3, child: Text('col_actions'.tr, style: style)),
      ],
    );
  }
}

Widget _statusChip(PlaceStatus status) {
  switch (status) {
    case PlaceStatus.approved:
      return AdminStatusChip(text: 'approved'.tr, color: AdminColors.green, bg: AdminColors.greenLight);
    case PlaceStatus.rejected:
      return AdminStatusChip(text: 'rejected'.tr, color: AdminColors.red, bg: AdminColors.redLight);
    case PlaceStatus.pending:
      return AdminStatusChip(text: 'pending'.tr, color: AdminColors.amber, bg: AdminColors.amberLight);
  }
}

// ══════════════════════════ Row (hover-highlighted) ══════════════════════════

class _ListingRow extends StatefulWidget {
  final AdminListingItem item;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  const _ListingRow({required this.item, required this.onView, required this.onEdit, required this.onApprove, required this.onReject, required this.onDelete});

  @override
  State<_ListingRow> createState() => _ListingRowState();
}

class _ListingRowState extends State<_ListingRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovering ? AdminColors.surfaceLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: item.imageColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.image_outlined, color: item.imageColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(item.subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AdminColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(item.owner, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis))),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AdminColors.background, borderRadius: BorderRadius.circular(20)),
                    child: Text(item.typeLabel, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ),
            Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(item.location, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis))),
            Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(item.price, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.primary), overflow: TextOverflow.ellipsis))),
            Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(item.submittedDate, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis))),
            Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(right: 12), child: Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: _statusChip(item.status))))),
            Expanded(
              flex: 3,
              child: Wrap(
                spacing: 0,
                runSpacing: 4,
                children: [
                  _ActionIconButton(icon: Icons.visibility_outlined, tooltip: 'view_details'.tr, color: AdminColors.textSecondary, onTap: widget.onView),
                  _ActionIconButton(icon: Icons.edit_outlined, tooltip: 'edit'.tr, color: AdminColors.primary, onTap: widget.onEdit),
                  _ActionIconButton(icon: Icons.check_circle_outline, tooltip: 'approve'.tr, color: AdminColors.green, onTap: widget.onApprove),
                  _ActionIconButton(icon: Icons.cancel_outlined, tooltip: 'reject'.tr, color: AdminColors.red, onTap: widget.onReject),
                  _ActionIconButton(icon: Icons.delete_outline, tooltip: 'delete'.tr, color: AdminColors.textSecondary, onTap: widget.onDelete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════ Action icon button (hover + tooltip) ══════════════════════════

class _ActionIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _ActionIconButton({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  State<_ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<_ActionIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            width: 28,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(color: _hovering ? widget.color.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
            child: Icon(widget.icon, size: 15, color: widget.color),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Mobile card ══════════════════════════

class _ListingCard extends StatelessWidget {
  final AdminListingItem item;
  final String typeLabel;
  final String locationLabel;
  final String priceLabel;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  const _ListingCard({
    required this.item,
    required this.typeLabel,
    required this.locationLabel,
    required this.priceLabel,
    required this.onView,
    required this.onEdit,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: AdminColors.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withOpacity(0.3))),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: item.imageColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.image_outlined, color: item.imageColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                      Text(item.subtitle, style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                _statusChip(item.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _infoChip('col_company'.tr, item.owner),
                _infoChip(typeLabel, item.typeLabel),
                _infoChip(locationLabel, item.location),
                _infoChip(priceLabel, item.price),
                _infoChip('col_submitted'.tr, item.submittedDate),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(foregroundColor: AdminColors.textSecondary, side: BorderSide(color: AdminColors.border), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: Text('view_details'.tr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(foregroundColor: AdminColors.primary, side: BorderSide(color: AdminColors.primary.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: Text('edit'.tr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(foregroundColor: AdminColors.red, side: BorderSide(color: AdminColors.red.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: Text('reject'.tr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(backgroundColor: AdminColors.green, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.check_rounded, size: 14),
                    label: Text('approve'.tr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(foregroundColor: AdminColors.textSecondary, side: BorderSide(color: AdminColors.border), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: Text('delete'.tr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AdminColors.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AdminColors.textPrimary)),
      ],
    );
  }
}
