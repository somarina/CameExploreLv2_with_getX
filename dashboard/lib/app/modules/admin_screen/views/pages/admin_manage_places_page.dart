import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/admin_export/admin_export.dart';
import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../../models/admin_models.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

class AdminManagePlacesPage extends StatefulWidget {
  final AdminScreenController controller;
  const AdminManagePlacesPage({super.key, required this.controller});

  @override
  State<AdminManagePlacesPage> createState() => _AdminManagePlacesPageState();
}

class _AdminManagePlacesPageState extends State<AdminManagePlacesPage> {
  PlaceStatus? _filter; // null = All
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Obx(() {
      final filtered = controller.places.where((p) {
        final matchesFilter = _filter == null || p.status == _filter;
        final matchesQuery =
            _query.isEmpty ||
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.company.toLowerCase().contains(_query.toLowerCase()) ||
            p.province.toLowerCase().contains(_query.toLowerCase());
        return matchesFilter && matchesQuery;
      }).toList();

      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 768;
      final isTablet = screenWidth < 1200;

      return SingleChildScrollView(
        padding: EdgeInsets.all(
          isMobile
              ? 16
              : isTablet
              ? 20
              : 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminTopBar(
                  title: 'manage_places'.tr,
                  subtitle:
                      'manage_places_subtitle'.tr,
                  controller: controller,
                ),
                const SizedBox(height: 24),

                _ResponsiveStats(
                  controller: controller,
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
                              hint: 'search_name_company_province'.tr,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ExportButton(onTap: () => exportPlacesToExcel(filtered)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: isMobile ? 6 : 8,
                        runSpacing: isMobile ? 6 : 8,
                        children: [
                          _FilterChip(
                            label: 'All (${controller.totalPlaces})',
                            selected: _filter == null,
                            onTap: () => setState(() => _filter = null),
                          ),
                          _FilterChip(
                            label: 'Pending (${controller.pendingCount})',
                            selected: _filter == PlaceStatus.pending,
                            onTap: () =>
                                setState(() => _filter = PlaceStatus.pending),
                          ),
                          _FilterChip(
                            label: 'Approved (${controller.approvedCount})',
                            selected: _filter == PlaceStatus.approved,
                            onTap: () =>
                                setState(() => _filter = PlaceStatus.approved),
                          ),
                          _FilterChip(
                            label: 'Rejected (${controller.rejectedCount})',
                            selected: _filter == PlaceStatus.rejected,
                            onTap: () =>
                                setState(() => _filter = PlaceStatus.rejected),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!isMobile) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _TableHeader(),
                        ),
                        Divider(height: 24, color: AdminColors.border),
                      ],
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 36,
                                  color: AdminColors.textSecondary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'no_places_match_filter'.tr,
                                  style: GoogleFonts.inter(
                                    color: AdminColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (isMobile)
                        Column(
                          children: filtered
                              .map(
                                (p) => _PlaceCard(
                                  place: p,
                                  controller: controller,
                                ),
                              )
                              .toList(),
                        )
                      else
                        ...filtered.map(
                          (p) => _PlaceRow(place: p, controller: controller),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Showing ${filtered.length} of ${controller.totalPlaces} places',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: AdminColors.textSecondary,
                        ),
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

// ══════════════════════════ Animated tappable stat row ══════════════════════════

class _ResponsiveStats extends StatelessWidget {
  final AdminScreenController controller;
  final bool isMobile;
  final PlaceStatus? filter;
  final ValueChanged<PlaceStatus?> onSelect;
  const _ResponsiveStats({
    required this.controller,
    required this.isMobile,
    required this.filter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatBox(
        label: 'All',
        value: '${controller.totalPlaces}',
        color: AdminColors.textPrimary,
        icon: Icons.grid_view_rounded,
        selected: filter == null,
        onTap: () => onSelect(null),
      ),
      _StatBox(
        label: 'pending'.tr,
        value: '${controller.pendingCount}',
        color: AdminColors.amber,
        icon: Icons.schedule_rounded,
        selected: filter == PlaceStatus.pending,
        onTap: () => onSelect(PlaceStatus.pending),
      ),
      _StatBox(
        label: 'approved'.tr,
        value: '${controller.approvedCount}',
        color: AdminColors.green,
        icon: Icons.check_circle_outline_rounded,
        selected: filter == PlaceStatus.approved,
        onTap: () => onSelect(PlaceStatus.approved),
      ),
      _StatBox(
        label: 'rejected'.tr,
        value: '${controller.rejectedCount}',
        color: AdminColors.red,
        icon: Icons.cancel_outlined,
        selected: filter == PlaceStatus.rejected,
        onTap: () => onSelect(PlaceStatus.rejected),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 110, // fixed height
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
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

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
          // padding: const EdgeInsets.all(18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? AdminColors.surfaceLight
                : AdminColors.surface,
            borderRadius: BorderRadius.circular(AdminRadii.card),
            border: Border.all(
              color: widget.selected
                  ? widget.color.withOpacity(0.7)
                  : (_hovering
                        ? widget.color.withOpacity(0.4)
                        : AdminColors.border),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: (_hovering || widget.selected)
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AdminColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(
                        begin: 0,
                        end: int.tryParse(widget.value) ?? 0,
                      ),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        '$value',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: widget.color,
                        ),
                      ),
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

// ══════════════════════════ Filter chip (animated) ══════════════════════════

class _FilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AdminColors.primary,
                      AdminColors.primary.withOpacity(0.8),
                    ],
                  )
                : null,
            color: selected
                ? null
                : (_hovering
                      ? AdminColors.surfaceLight
                      : AdminColors.background),
            borderRadius: BorderRadius.circular(AdminRadii.chip),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AdminColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AdminColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Table header ══════════════════════════

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AdminColors.textSecondary,
      letterSpacing: 0.4,
    );
    Widget cell(int flex, String label) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(label, style: style, overflow: TextOverflow.ellipsis),
      ),
    );
    return Row(
      children: [
        cell(3, 'col_place'.tr),
        cell(2, 'col_company'.tr),
        cell(2, 'col_category'.tr),
        cell(1, 'col_province'.tr),
        cell(1, 'col_fee'.tr),
        cell(1, 'col_submitted'.tr),
        cell(2, 'col_status'.tr),
        Expanded(flex: 3, child: Text('col_actions'.tr, style: style)),
      ],
    );
  }
}

// ══════════════════════════ Place row (hover-highlighted) ══════════════════════════

class _PlaceRow extends StatefulWidget {
  final AdminPlace place;
  final AdminScreenController controller;
  const _PlaceRow({required this.place, required this.controller});

  @override
  State<_PlaceRow> createState() => _PlaceRowState();
}

class _PlaceRowState extends State<_PlaceRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final controller = widget.controller;

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
                      decoration: BoxDecoration(
                        color: place.imageColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: place.imageColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            place.subtitle,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AdminColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  place.company,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AdminColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      place.category,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AdminColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  place.province,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AdminColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  place.fee,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  place.submittedDate,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AdminColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _statusChip(place.status),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Wrap(
                spacing: 0,
                runSpacing: 4,
                children: [
                  _ActionIconButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'view_details'.tr,
                    color: AdminColors.textSecondary,
                    onTap: () {},
                  ),
                  _ActionIconButton(
                    icon: Icons.check_circle_outline,
                    tooltip: 'approve'.tr,
                    color: AdminColors.green,
                    onTap: () => controller.approvePlace(place),
                  ),
                  _ActionIconButton(
                    icon: Icons.cancel_outlined,
                    tooltip: 'reject'.tr,
                    color: AdminColors.red,
                    onTap: () => controller.rejectPlace(place),
                  ),
                  _ActionIconButton(
                    icon: Icons.delete_outline,
                    tooltip: 'delete'.tr,
                    color: AdminColors.textSecondary,
                    onTap: () => _confirmDelete(context, place, controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(PlaceStatus status) {
    switch (status) {
      case PlaceStatus.approved:
        return AdminStatusChip(
          text: 'approved'.tr,
          color: AdminColors.green,
          bg: AdminColors.greenLight,
        );
      case PlaceStatus.rejected:
        return AdminStatusChip(
          text: 'rejected'.tr,
          color: AdminColors.red,
          bg: AdminColors.redLight,
        );
      case PlaceStatus.pending:
        return AdminStatusChip(
          text: 'pending'.tr,
          color: AdminColors.amber,
          bg: AdminColors.amberLight,
        );
    }
  }

  void _confirmDelete(
    BuildContext context,
    AdminPlace place,
    AdminScreenController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${'delete_question'.tr} "${place.name}"?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'action_cannot_be_undone'.tr,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              controller.deletePlace(place);
              Navigator.pop(context);
            },
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: AdminColors.red),
            ),
          ),
        ],
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
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

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
            decoration: BoxDecoration(
              color: _hovering
                  ? widget.color.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(widget.icon, size: 15, color: widget.color),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Mobile card view ══════════════════════════

class _PlaceCard extends StatelessWidget {
  final AdminPlace place;
  final AdminScreenController controller;
  const _PlaceCard({required this.place, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: place.imageColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: place.imageColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Text(
                        place.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AdminColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _placeStatusChip(place.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _infoChip('Company', place.company),
                _infoChip('Category', place.category),
                _infoChip('Location', place.province),
                _infoChip('Fee', place.fee),
                _infoChip('Date', place.submittedDate),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showDeleteDialog(context, place, controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.red,
                      side: BorderSide(color: AdminColors.red.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: Text(
                      'delete'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AdminColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AdminColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _placeStatusChip(PlaceStatus status) {
    switch (status) {
      case PlaceStatus.approved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AdminColors.greenDark,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'approved'.tr,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AdminColors.green,
            ),
          ),
        );
      case PlaceStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AdminColors.redDark,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'rejected'.tr,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AdminColors.red,
            ),
          ),
        );
      case PlaceStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AdminColors.amberDark,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'pending'.tr,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AdminColors.amber,
            ),
          ),
        );
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    AdminPlace place,
    AdminScreenController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.cardBackground,
        title: Text(
          '${'delete_question'.tr} ${place.name}?',
          style: GoogleFonts.inter(color: AdminColors.textPrimary),
        ),
        content: Text(
          'action_cannot_be_undone'.tr,
          style: GoogleFonts.inter(color: AdminColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              controller.deletePlace(place);
              Navigator.pop(context);
            },
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: AdminColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
