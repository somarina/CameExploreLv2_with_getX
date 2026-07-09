import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../../models/admin_models.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

class AdminApprovalsPage extends StatelessWidget {
  final AdminScreenController controller;
  const AdminApprovalsPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Obx(() {
      final pending = controller.places.where((p) => p.status == PlaceStatus.pending).toList();
      final approved = controller.places.where((p) => p.status == PlaceStatus.approved).toList();
      final rejected = controller.places.where((p) => p.status == PlaceStatus.rejected).toList();
      final total = controller.places.length;

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminTopBar(
              title: 'Approvals',
              subtitle: 'Review and manage place submission requests',
              controller: controller,
            ),
            const SizedBox(height: 28),
            _buildStatsRow(total, pending.length, approved.length, rejected.length, isMobile),
            const SizedBox(height: 28),
            if (pending.isEmpty)
              AdminSectionCard(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.task_alt_rounded, size: 40, color: AdminColors.green),
                        const SizedBox(height: 12),
                        Text('All caught up — nothing pending review.',
                            style: GoogleFonts.inter(fontSize: 14, color: AdminColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              )
            else
              isDesktop
                  ? _buildDesktopTable(pending)
                  : _buildMobileCards(pending, isMobile),
          ],
        ),
      );
    });
  }

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
          childAspectRatio: isMobile ? 2.2 : 2.5,
          children: [
            _statCard('Total', total.toString(), AdminColors.primary),
            _statCard('Pending', pending.toString(), AdminColors.amber, isHighlight: true),
            _statCard('Approved', approved.toString(), AdminColors.green),
            _statCard('Rejected', rejected.toString(), AdminColors.red),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color, {bool isHighlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlight ? AdminColors.surfaceLight : AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight ? Border.all(color: color.withOpacity(0.5)) : Border.all(color: AdminColors.border.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              )),
        ],
      ),
    );
  }

  // Desktop Table View
  Widget _buildDesktopTable(List<AdminPlace> items) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Pending Submissions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
          ),
          const Divider(color: AdminColors.border, height: 0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowColor: WidgetStateProperty.all(Colors.transparent),
              dataRowHeight: 70,
              columnSpacing: 20,
              headingRowHeight: 60,
              columns: [
                DataColumn(label: Text('PLACE', style: _tableHeaderStyle())),
                DataColumn(label: Text('COMPANY', style: _tableHeaderStyle())),
                DataColumn(label: Text('CATEGORY', style: _tableHeaderStyle())),
                DataColumn(label: Text('PROVINCE', style: _tableHeaderStyle())),
                DataColumn(label: Text('FEE', style: _tableHeaderStyle())),
                DataColumn(label: Text('DATE', style: _tableHeaderStyle())),
                DataColumn(label: Text('ACTIONS', style: _tableHeaderStyle())),
              ],
              rows: items
                  .map((place) => DataRow(
                        cells: [
                          DataCell(_placeCell(place)),
                          DataCell(Text(place.company, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary))),
                          DataCell(_categoryBadge(place.category)),
                          DataCell(Text(place.province, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textPrimary))),
                          DataCell(Text(place.fee, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.primary))),
                          DataCell(Text(place.submittedDate, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary))),
                          DataCell(_actionButtonsDesktop(place)),
                        ],
                      ))
                  .toList(),
            ),
          ),
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

  // Mobile Card View
  Widget _buildMobileCards(List<AdminPlace> items, bool isMobile) {
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AdminColors.amberDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Pending', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.amber)),
                          ),
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
                              label: Text('Reject', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
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
                              label: Text('Approve', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
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

  Widget _placeCell(AdminPlace place) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: place.imageColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.image_outlined, color: place.imageColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
            Text(place.subtitle, style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ],
    );
  }

  Widget _categoryBadge(String category) {
    final colorMap = {
      'Temple': AdminColors.purple,
      'Beach': AdminColors.teal,
      'Historical Monument': AdminColors.primary,
      'Natural Park': AdminColors.green,
    };
    final color = colorMap[category] ?? AdminColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(category, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    );
  }

  Widget _actionButtonsDesktop(AdminPlace place) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View Details',
          child: IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            onPressed: () {},
            color: AdminColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        Tooltip(
          message: 'Approve',
          child: IconButton(
            icon: const Icon(Icons.check_circle_outline, size: 18),
            onPressed: () => controller.approvePlace(place),
            color: AdminColors.green,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        Tooltip(
          message: 'Reject',
          child: IconButton(
            icon: const Icon(Icons.cancel_outlined, size: 18),
            onPressed: () => controller.rejectPlace(place),
            color: AdminColors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
    );
  }

  TextStyle _tableHeaderStyle() {
    return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary, letterSpacing: 0.5);
  }
}
