import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        final matchesQuery = _query.isEmpty ||
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.company.toLowerCase().contains(_query.toLowerCase()) ||
            p.province.toLowerCase().contains(_query.toLowerCase());
        return matchesFilter && matchesQuery;
      }).toList();

      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 768;
      final isTablet = screenWidth < 1200;

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminTopBar(
              title: 'Manage Places',
              subtitle: 'Review, approve and manage all submitted locations',
              controller: controller,
            ),
            const SizedBox(height: 24),

            _ResponsiveStats(controller: controller),
            const SizedBox(height: 24),

            AdminSectionCard(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSearchField(
                    hint: 'Search by name, company, province...',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: isMobile ? 6 : 8,
                    runSpacing: isMobile ? 6 : 8,
                    children: [
                      _FilterChip(label: 'All (${controller.totalPlaces})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                      _FilterChip(label: 'Pending (${controller.pendingCount})', selected: _filter == PlaceStatus.pending, onTap: () => setState(() => _filter = PlaceStatus.pending)),
                      _FilterChip(label: 'Approved (${controller.approvedCount})', selected: _filter == PlaceStatus.approved, onTap: () => setState(() => _filter = PlaceStatus.approved)),
                      _FilterChip(label: 'Rejected (${controller.rejectedCount})', selected: _filter == PlaceStatus.rejected, onTap: () => setState(() => _filter = PlaceStatus.rejected)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isMobile) ...[
                    _TableHeader(),
                    const Divider(height: 24, color: AdminColors.border),
                  ],
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('No places match this filter.',
                            style: GoogleFonts.inter(color: AdminColors.textSecondary)),
                      ),
                    )
                  else if (isMobile)
                    Column(children: filtered.map((p) => _PlaceCard(place: p, controller: controller)).toList())
                  else
                    ...filtered.map((p) => _PlaceRow(place: p, controller: controller)),
                  const SizedBox(height: 8),
                  Text('Showing ${filtered.length} of ${controller.totalPlaces} places',
                      style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ResponsiveStats extends StatelessWidget {
  final AdminScreenController controller;
  const _ResponsiveStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    Widget statBox(String label, String value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(AdminRadii.card),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 14.5, color: AdminColors.textSecondary)),
              Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        statBox('All', '${controller.totalPlaces}', AdminColors.textPrimary),
        const SizedBox(width: 16),
        statBox('Pending', '${controller.pendingCount}', AdminColors.amber),
        const SizedBox(width: 16),
        statBox('Approved', '${controller.approvedCount}', AdminColors.green),
        const SizedBox(width: 16),
        statBox('Rejected', '${controller.rejectedCount}', AdminColors.red),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AdminRadii.chip),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AdminColors.primary : AdminColors.background,
          borderRadius: BorderRadius.circular(AdminRadii.chip),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : AdminColors.textPrimary),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textSecondary, letterSpacing: 0.4);
    return Row(
      children: [
        Expanded(flex: 3, child: Text('PLACE', style: style)),
        Expanded(flex: 2, child: Text('COMPANY', style: style)),
        Expanded(flex: 2, child: Text('CATEGORY', style: style)),
        Expanded(flex: 2, child: Text('PROVINCE', style: style)),
        Expanded(flex: 1, child: Text('FEE', style: style)),
        Expanded(flex: 2, child: Text('SUBMITTED', style: style)),
        Expanded(flex: 1, child: Text('STATUS', style: style)),
        Expanded(flex: 2, child: Text('ACTIONS', style: style)),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final AdminPlace place;
  final AdminScreenController controller;
  const _PlaceRow({required this.place, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: place.imageColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.image_outlined, color: place.imageColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name,
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                      Text(place.subtitle,
                          style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(place.company, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AdminColors.background, borderRadius: BorderRadius.circular(8)),
                child: Text(place.category, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textPrimary)),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(place.province, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary))),
          Expanded(
            flex: 1,
            child: Text(place.fee,
                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.primary)),
          ),
          Expanded(flex: 2, child: Text(place.submittedDate, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary))),
          Expanded(flex: 1, child: _statusChip(place.status)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionIcon(Icons.visibility_outlined, AdminColors.textSecondary, () {}),
                _actionIcon(Icons.check_circle_outline, AdminColors.green, () => controller.approvePlace(place)),
                _actionIcon(Icons.cancel_outlined, AdminColors.red, () => controller.rejectPlace(place)),
                _actionIcon(Icons.delete_outline, AdminColors.textSecondary, () => _confirmDelete(context, place, controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18, color: color),
      splashRadius: 18,
      onPressed: onTap,
    );
  }

  Widget _statusChip(PlaceStatus status) {
    switch (status) {
      case PlaceStatus.approved:
        return const AdminStatusChip(text: 'Approved', color: AdminColors.green, bg: AdminColors.greenLight);
      case PlaceStatus.rejected:
        return const AdminStatusChip(text: 'Rejected', color: AdminColors.red, bg: AdminColors.redLight);
      case PlaceStatus.pending:
        return const AdminStatusChip(text: 'Pending', color: AdminColors.amber, bg: AdminColors.amberLight);
    }
  }

  void _confirmDelete(BuildContext context, AdminPlace place, AdminScreenController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${place.name}"?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('This action cannot be undone.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deletePlace(place);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AdminColors.red)),
          ),
        ],
      ),
    );
  }
}

/// Mobile card view for places
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
                  decoration: BoxDecoration(color: place.imageColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.image_outlined, color: place.imageColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                      Text(place.subtitle, style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                    onPressed: () => _showDeleteDialog(context, place, controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.red,
                      side: BorderSide(color: AdminColors.red.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: Text('Delete', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _placeStatusChip(PlaceStatus status) {
    switch (status) {
      case PlaceStatus.approved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AdminColors.greenDark, borderRadius: BorderRadius.circular(6)),
          child: Text('Approved', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AdminColors.green)),
        );
      case PlaceStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AdminColors.redDark, borderRadius: BorderRadius.circular(6)),
          child: Text('Rejected', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AdminColors.red)),
        );
      case PlaceStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AdminColors.amberDark, borderRadius: BorderRadius.circular(6)),
          child: Text('Pending', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AdminColors.amber)),
        );
    }
  }

  void _showDeleteDialog(BuildContext context, AdminPlace place, AdminScreenController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.cardBackground,
        title: Text('Delete ${place.name}?', style: GoogleFonts.inter(color: AdminColors.textPrimary)),
        content: Text('This action cannot be undone.', style: GoogleFonts.inter(color: AdminColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deletePlace(place);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AdminColors.red)),
          ),
        ],
      ),
    );
  }
}
