import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../../models/admin_models.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

class AdminApprovalsPage extends StatefulWidget {
  final AdminScreenController controller;
  const AdminApprovalsPage({super.key, required this.controller});

  @override
  State<AdminApprovalsPage> createState() => _AdminApprovalsPageState();
}

class _AdminApprovalsPageState extends State<AdminApprovalsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Defaults to 'Pending' to preserve the original page behavior
  // (this page only showed pending submissions). Other chips are additive.
  String _selectedFilter = 'Pending';

  AdminScreenController get controller => widget.controller;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Obx(() {
      final allPlaces = controller.places;
      final pendingCount = allPlaces.where((p) => p.status == PlaceStatus.pending).length;
      final approvedCount = allPlaces.where((p) => p.status == PlaceStatus.approved).length;
      final rejectedCount = allPlaces.where((p) => p.status == PlaceStatus.rejected).length;
      final total = allPlaces.length;

      final filtered = allPlaces.where((p) {
        final matchesFilter = switch (_selectedFilter) {
          'Pending' => p.status == PlaceStatus.pending,
          'Approved' => p.status == PlaceStatus.approved,
          'Rejected' => p.status == PlaceStatus.rejected,
          _ => true, // 'All'
        };
        final q = _searchQuery.trim().toLowerCase();
        final matchesSearch = q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.company.toLowerCase().contains(q);
        return matchesFilter && matchesSearch;
      }).toList();

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminTopBar(
                  title: 'approvals'.tr,
                  subtitle: 'approvals_subtitle'.tr,
                  controller: controller,
                ),
                const SizedBox(height: 28),
                _buildStatsRow(total, pendingCount, approvedCount, rejectedCount, isMobile),
                const SizedBox(height: 24),
                _buildSearchAndFilters(isMobile),
                const SizedBox(height: 24),
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  isDesktop ? _buildDesktopTable(filtered) : _buildMobileCards(filtered),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ────────────────────────── Empty state ──────────────────────────

  Widget _buildEmptyState() {
    final isPending = _selectedFilter == 'Pending';
    return AdminSectionCard(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPending ? Icons.task_alt_rounded : Icons.search_off_rounded,
                size: 40,
                color: isPending ? AdminColors.green : AdminColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                isPending ? 'All caught up — nothing pending review.' : 'no_submissions_match_filters'.tr,
                style: GoogleFonts.inter(fontSize: 14, color: AdminColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────── Stat cards ──────────────────────────

  Widget _buildStatsRow(int total, int pending, int approved, int rejected, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colCount = isMobile ? 2 : 4;
        return GridView.count(
          crossAxisCount: colCount,
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1.6 : 2.1,
          children: [
            _StatCard(
              label: 'total'.tr,
              value: total,
              color: AdminColors.primary,
              icon: Icons.grid_view_rounded,
              selected: _selectedFilter == 'All',
              onTap: () => setState(() => _selectedFilter = 'All'),
            ),
            _StatCard(
              label: 'pending'.tr,
              value: pending,
              color: AdminColors.amber,
              icon: Icons.schedule_rounded,
              selected: _selectedFilter == 'Pending',
              onTap: () => setState(() => _selectedFilter = 'Pending'),
            ),
            _StatCard(
              label: 'approved'.tr,
              value: approved,
              color: AdminColors.green,
              icon: Icons.check_circle_outline_rounded,
              selected: _selectedFilter == 'Approved',
              onTap: () => setState(() => _selectedFilter = 'Approved'),
            ),
            _StatCard(
              label: 'rejected'.tr,
              value: rejected,
              color: AdminColors.red,
              icon: Icons.cancel_outlined,
              selected: _selectedFilter == 'Rejected',
              onTap: () => setState(() => _selectedFilter = 'Rejected'),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────── Search + filter bar ──────────────────────────

  Widget _buildSearchAndFilters(bool isMobile) {
    final chips = ['All', 'Pending', 'Approved', 'Rejected'];

    final searchField = Container(
      height: 46,
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'search_place_company'.tr,
          hintStyle: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textSecondary),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: AdminColors.textSecondary),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: AdminColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );

    final filterChips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) => _FilterChip(
            label: c,
            selected: _selectedFilter == c,
            onTap: () => setState(() => _selectedFilter = c),
          )).toList(),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [searchField, const SizedBox(height: 12), filterChips],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: searchField),
        const SizedBox(width: 16),
        filterChips,
      ],
    );
  }

  // ────────────────────────── Desktop table (custom, no DataTable) ──────────────────────────

  Widget _buildDesktopTable(List<AdminPlace> items) {
    return AdminSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text('submissions'.tr, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
          ),
          Divider(color: AdminColors.border, height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: _tableHeaderRow(),
          ),
          Divider(color: AdminColors.border, height: 0),
          ...items.map((place) => _ApprovalTableRow(
                place: place,
                onApprove: () => controller.approvePlace(place),
                onReject: () => controller.rejectPlace(place),
              )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Showing ${items.length} of ${items.length} requests',
              style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderRow() {
    final style = _tableHeaderStyle();
    return Row(
      children: [
        Expanded(flex: 3, child: Text('col_place'.tr, style: style)),
        Expanded(flex: 2, child: Text('col_company'.tr, style: style)),
        Expanded(flex: 2, child: Text('col_category'.tr, style: style)),
        Expanded(flex: 1, child: Text('col_province'.tr, style: style)),
        Expanded(flex: 1, child: Text('col_fee'.tr, style: style)),
        Expanded(flex: 1, child: Text('col_date'.tr, style: style)),
        Expanded(flex: 1, child: Text('col_status'.tr, style: style)),
        SizedBox(width: 130, child: Text('col_actions'.tr, style: style)),
      ],
    );
  }

  static TextStyle _tableHeaderStyle() {
    return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary, letterSpacing: 0.5);
  }

  // ────────────────────────── Mobile card view ──────────────────────────

  Widget _buildMobileCards(List<AdminPlace> items) {
    return Column(
      children: items
          .map((place) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AdminSectionCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: place.imageColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.image_outlined, color: place.imageColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(place.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(place.subtitle, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          _StatusBadge(status: place.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Company', place.company),
                      _buildInfoRow('Category', place.category),
                      _buildInfoRow('Location', place.province),
                      _buildInfoRow('Fee', place.fee),
                      _buildInfoRow('Submitted', place.submittedDate),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.rejectPlace(place),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AdminColors.red,
                                side: BorderSide(color: AdminColors.red.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: Text('reject'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => controller.approvePlace(place),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: Text('approve'.tr, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AdminColors.textPrimary)),
        ],
      ),
    );
  }
}

// ══════════════════════════ Animated stat card ══════════════════════════

class _StatCard extends StatefulWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _hovering ? -2.0 : 0.0),
          decoration: BoxDecoration(
            color: widget.selected ? AdminColors.surfaceLight : AdminColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.selected
                  ? widget.color.withOpacity(0.7)
                  : (_hovering ? widget.color.withOpacity(0.4) : AdminColors.border.withOpacity(0.3)),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: (_hovering || widget.selected)
                ? [BoxShadow(color: widget.color.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))]
                : [],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.value),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Text(
                          '$value',
                          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: widget.color),
                        ),
                      ),
                    ],
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(colors: [AdminColors.primary, AdminColors.primary.withOpacity(0.8)])
                : null,
            color: selected ? null : (_hovering ? AdminColors.surfaceLight : AdminColors.cardBackground),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Colors.transparent : AdminColors.border.withOpacity(0.5)),
            boxShadow: selected
                ? [BoxShadow(color: AdminColors.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AdminColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════ Custom table row (replaces DataRow) ══════════════════════════

class _ApprovalTableRow extends StatefulWidget {
  final AdminPlace place;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ApprovalTableRow({required this.place, required this.onApprove, required this.onReject});

  @override
  State<_ApprovalTableRow> createState() => _ApprovalTableRowState();
}

class _ApprovalTableRowState extends State<_ApprovalTableRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovering ? AdminColors.surfaceLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: _placeCell(place)),
            Expanded(
              flex: 2,
              child: Text(place.company, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AdminColors.textSecondary)),
            ),
            Expanded(flex: 2, child: _CategoryBadge(category: place.category)),
            Expanded(
              flex: 1,
              child: Text(place.province, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AdminColors.textPrimary)),
            ),
            Expanded(
              flex: 1,
              child: Text(place.fee, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.primary)),
            ),
            Expanded(
              flex: 1,
              child: Text(place.submittedDate, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AdminColors.textSecondary)),
            ),
            Expanded(flex: 1, child: _StatusBadge(status: place.status)),
            SizedBox(
              width: 130,
              child: _ActionButtons(onApprove: widget.onApprove, onReject: widget.onReject),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeCell(AdminPlace place) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: place.imageColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.image_outlined, color: place.imageColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.name,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(place.subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════ Category badge ══════════════════════════

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      'Temple': AdminColors.purple,
      'Beach': AdminColors.teal,
      'Historical Monument': AdminColors.primary,
      'Natural Park': AdminColors.green,
    };
    final color = colorMap[category] ?? AdminColors.primary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ══════════════════════════ Status badge (pill + dot) ══════════════════════════

class _StatusBadge extends StatelessWidget {
  final PlaceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    switch (status) {
      case PlaceStatus.approved:
        color = AdminColors.green;
        label = 'approved'.tr;
        break;
      case PlaceStatus.rejected:
        color = AdminColors.red;
        label = 'rejected'.tr;
        break;
      case PlaceStatus.pending:
        color = AdminColors.amber;
        label = 'pending'.tr;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════ Action buttons (View / Approve / Reject) ══════════════════════════

class _ActionButtons extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ActionButtons({required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIconButton(icon: Icons.visibility_outlined, tooltip: 'view_details'.tr, color: AdminColors.textSecondary, onTap: () {}),
        _ActionIconButton(icon: Icons.check_circle_outline, tooltip: 'approve'.tr, color: AdminColors.green, onTap: onApprove),
        _ActionIconButton(icon: Icons.cancel_outlined, tooltip: 'reject'.tr, color: AdminColors.red, onTap: onReject),
      ],
    );
  }
}

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
            width: 34,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _hovering ? widget.color.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 18, color: widget.color),
          ),
        ),
      ),
    );
  }
}