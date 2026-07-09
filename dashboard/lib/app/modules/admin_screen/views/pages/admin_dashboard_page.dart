import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../../models/admin_models.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

class AdminDashboardPage extends StatelessWidget {
  final AdminScreenController controller;
  const AdminDashboardPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminTopBar(
              title: 'Dashboard',
              subtitle: 'Welcome back, ${controller.adminName.value} 👋',
              controller: controller,
              trailingAction: AdminPrimaryButton(
                label: 'Review Requests',
                count: controller.pendingCount,
                icon: Icons.check_circle_outline,
                onTap: () => controller.goTo(AdminSection.approvals),
              ),
            ),
            const SizedBox(height: 28),

            // ---------- Stat cards ----------
            LayoutBuilder(builder: (context, constraints) {
              final cards = [
                AdminStatCard(
                  icon: Icons.place_outlined,
                  iconColor: AdminColors.primary,
                  iconBg: AdminColors.primaryLight,
                  label: 'Total Places',
                  value: '${controller.totalPlaces}',
                  badgeText: '+8%',
                  badgeColor: AdminColors.primary,
                  badgeBg: AdminColors.primaryLight,
                ),
                AdminStatCard(
                  icon: Icons.access_time_rounded,
                  iconColor: AdminColors.amber,
                  iconBg: AdminColors.amberLight,
                  label: 'Pending Review',
                  value: '${controller.pendingCount}',
                  badgeText: 'Now',
                  badgeColor: AdminColors.amber,
                  badgeBg: AdminColors.amberLight,
                ),
                AdminStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AdminColors.green,
                  iconBg: AdminColors.greenLight,
                  label: 'Approved',
                  value: '${controller.approvedCount}',
                  badgeText: '+12%',
                  badgeColor: AdminColors.green,
                  badgeBg: AdminColors.greenLight,
                ),
                AdminStatCard(
                  icon: Icons.apartment_rounded,
                  iconColor: AdminColors.purple,
                  iconBg: AdminColors.purpleLight,
                  label: 'Companies',
                  value: '${controller.totalCompanies}',
                  badgeText: '+5%',
                  badgeColor: AdminColors.purple,
                  badgeBg: AdminColors.purpleLight,
                ),
              ];
              return _ResponsiveRow(children: cards, spacing: 20, minItemWidth: 220);
            }),

            const SizedBox(height: 24),

            // ---------- Submissions chart + Top categories ----------
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              final chart = AdminSectionCard(child: _SubmissionsChart(controller: controller));
              final categories = AdminSectionCard(child: _TopCategories(controller: controller));

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: chart),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: categories),
                  ],
                );
              }
              return Column(children: [chart, const SizedBox(height: 20), categories]);
            }),

            const SizedBox(height: 24),

            // ---------- Recent submissions table ----------
            AdminSectionCard(child: _RecentSubmissions(controller: controller)),
          ],
        ),
      );
    });
  }
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double minItemWidth;
  const _ResponsiveRow({required this.children, required this.spacing, required this.minItemWidth});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int columns = (constraints.maxWidth / (minItemWidth + spacing)).floor().clamp(1, children.length);
      final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: children.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
      );
    });
  }
}

class _SubmissionsChart extends StatelessWidget {
  final AdminScreenController controller;
  const _SubmissionsChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(title: 'Submissions Overview', subtitle: 'Weekly place submissions & approvals'),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 12,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 3,
                getDrawingHorizontalLine: (v) => FlLine(color: AdminColors.border, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 3,
                    reservedSize: 30,
                    getTitlesWidget: (v, meta) => Text('${v.toInt()}',
                        style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= days.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(days[i], style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _line(controller.weeklySubmissions, AdminColors.primary, fill: true),
                _line(controller.weeklyApproved, AdminColors.green, fill: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _legendDot(AdminColors.primary, 'Submissions'),
            const SizedBox(width: 20),
            _legendDot(AdminColors.green, 'Approved'),
          ],
        ),
      ],
    );
  }

  LineChartBarData _line(List<double> values, Color color, {required bool fill}) {
    return LineChartBarData(
      spots: [for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: fill
          ? BarAreaData(show: true, color: color.withOpacity(0.08))
          : BarAreaData(show: false),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary)),
      ],
    );
  }
}

class _TopCategories extends StatelessWidget {
  final AdminScreenController controller;
  const _TopCategories({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(title: 'Top Categories', subtitle: 'Place distribution'),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 46,
              sections: controller.categoryStats
                  .map((c) => PieChartSectionData(
                        value: c.percent.toDouble(),
                        color: c.color,
                        radius: 26,
                        showTitle: false,
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...controller.categoryStats.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(c.label,
                        style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text('1', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                ],
              ),
            )),
      ],
    );
  }
}

class _RecentSubmissions extends StatelessWidget {
  final AdminScreenController controller;
  const _RecentSubmissions({required this.controller});

  @override
  Widget build(BuildContext context) {
    final recent = controller.places.reversed.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Recent Submissions',
          subtitle: 'Latest place requests',
          trailing: TextButton.icon(
            onPressed: () => controller.goTo(AdminSection.managePlaces),
            icon: const Icon(Icons.arrow_outward_rounded, size: 16, color: AdminColors.primary),
            label: Text('View All', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.primary)),
          ),
        ),
        const SizedBox(height: 16),
        _TableHeader(),
        const Divider(height: 24, color: AdminColors.border),
        ...recent.map((p) => _PlaceRow(place: p)),
        const SizedBox(height: 20),
        AdminPrimaryButton(
          label: 'Go to Approval Center',
          icon: Icons.check_circle_outline,
          onTap: () => controller.goTo(AdminSection.approvals),
        ),
      ],
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
        Expanded(flex: 1, child: Text('DATE', style: style)),
        Expanded(flex: 1, child: Text('STATUS', style: style)),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final AdminPlace place;
  const _PlaceRow({required this.place});

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: place.imageColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.image_outlined, color: place.imageColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(place.name,
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(place.company, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary))),
          Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _tag(place.category),
              )),
          Expanded(flex: 2, child: Text(place.province, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary))),
          Expanded(flex: 1, child: Text(place.submittedDate, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary))),
          Expanded(flex: 1, child: _statusChip(place.status)),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AdminColors.background, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textPrimary)),
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
}
