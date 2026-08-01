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
              title: 'dashboard'.tr,
              subtitle: '${'welcome_back_admin'.tr}, ${controller.adminName.value}👋',
              controller: controller,
              trailingAction: AdminPrimaryButton(
                label: 'review_requests'.tr,
                count: controller.pendingCount,
                icon: Icons.check_circle_outline,
                onTap: () => controller.goTo(AdminSection.approvals),
              ),
            ),
            SizedBox(height: 28),

            // ---------- Stat cards ----------
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  AdminStatCard(
                    icon: Icons.place_outlined,
                    iconColor: AdminColors.primary,
                    iconBg: AdminColors.primaryLight,
                    label: 'total_places'.tr,
                    value: '${controller.totalPlaces}',
                    badgeText: '+8%',
                    badgeColor: AdminColors.primary,
                    badgeBg: AdminColors.primaryLight,
                  ),
                  AdminStatCard(
                    icon: Icons.access_time_rounded,
                    iconColor: AdminColors.amber,
                    iconBg: AdminColors.amberLight,
                    label: 'pending_review'.tr,
                    value: '${controller.pendingCount}',
                    badgeText: 'now'.tr,
                    badgeColor: AdminColors.amber,
                    badgeBg: AdminColors.amberLight,
                  ),
                  AdminStatCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AdminColors.green,
                    iconBg: AdminColors.greenLight,
                    label: 'approved'.tr,
                    value: '${controller.approvedCount}',
                    badgeText: '+12%',
                    badgeColor: AdminColors.green,
                    badgeBg: AdminColors.greenLight,
                  ),
                  AdminStatCard(
                    icon: Icons.apartment_rounded,
                    iconColor: AdminColors.purple,
                    iconBg: AdminColors.purpleLight,
                    label: 'companies'.tr,
                    value: '${controller.totalCompanies}',
                    badgeText: '+5%',
                    badgeColor: AdminColors.purple,
                    badgeBg: AdminColors.purpleLight,
                  ),
                ];
                return _ResponsiveRow(
                  spacing: 20,
                  minItemWidth: 220,
                  children: cards,
                );
              },
            ),

            const SizedBox(height: 24),

            // ---------- Submissions chart + Top categories ----------
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                final chart = AdminSectionCard(
                  child: _SubmissionsChart(controller: controller),
                );
                final categories = AdminSectionCard(
                  child: _TopCategories(controller: controller),
                );

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
                return Column(
                  children: [chart, const SizedBox(height: 20), categories],
                );
              },
            ),

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
  const _ResponsiveRow({
    required this.children,
    required this.spacing,
    required this.minItemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = (constraints.maxWidth / (minItemWidth + spacing))
            .floor()
            .clamp(1, children.length);
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
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
        AdminSectionHeader(
          title: 'submissions_overview'.tr,
          subtitle: 'submissions_overview_subtitle'.tr,
        ),
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
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: AdminColors.border, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 3,
                    reservedSize: 30,
                    getTitlesWidget: (v, meta) => Text(
                      '${v.toInt()}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= days.length)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          days[i],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _line(
                  controller.weeklySubmissions,
                  AdminColors.primary,
                  fill: true,
                ),
                _line(
                  controller.weeklyApproved,
                  AdminColors.green,
                  fill: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _legendDot(AdminColors.primary, 'submissions'.tr),
            const SizedBox(width: 20),
            _legendDot(AdminColors.green, 'approved'.tr),
          ],
        ),
      ],
    );
  }

  LineChartBarData _line(
    List<double> values,
    Color color, {
    required bool fill,
  }) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
      ],
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AdminColors.textSecondary,
          ),
        ),
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
        AdminSectionHeader(
          title: 'top_categories'.tr,
          subtitle: 'place_distribution'.tr,
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 46,
              sections: controller.categoryStats
                  .map(
                    (c) => PieChartSectionData(
                      value: c.percent.toDouble(),
                      color: c.color,
                      radius: 26,
                      showTitle: false,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...controller.categoryStats.map(
          (c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c.label,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AdminColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '1',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed widths for every column except PLACE.
        const companyW = 160.0;
        const categoryW = 160.0;
        const provinceW = 140.0;
        const dateW = 120.0;
        const statusW = 110.0;
        const fixedTotal = companyW + categoryW + provinceW + dateW + statusW;
        const placeMinW = 220.0;

        final availableForPlace = constraints.maxWidth - fixedTotal;
        final placeW = availableForPlace > placeMinW
            ? availableForPlace
            : placeMinW;
        final needsScroll = availableForPlace < placeMinW;

        final colWidths = [
          placeW,
          companyW,
          categoryW,
          provinceW,
          dateW,
          statusW,
        ];

        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'recent_submissions'.tr,
              subtitle: 'latest_place_requests'.tr,
              trailing: TextButton.icon(
                onPressed: () => controller.goTo(AdminSection.managePlaces),
                icon: const Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: AdminColors.primary,
                ),
                label: Text(
                  'view_all'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _TableHeader(colWidths: colWidths),
            Divider(height: 24, color: AdminColors.border),
            ...recent.map((p) => _PlaceRow(place: p, colWidths: colWidths)),
            const SizedBox(height: 20),
            AdminPrimaryButton(
              label: 'go_to_approval_center'.tr,
              icon: Icons.check_circle_outline,
              onTap: () => controller.goTo(AdminSection.approvals),
            ),
          ],
        );

        if (!needsScroll) return table;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: placeMinW + fixedTotal, child: table),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  final List<double> colWidths;
  const _TableHeader({required this.colWidths});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AdminColors.textSecondary,
      letterSpacing: 0.4,
    );
    return Row(
      children: [
        SizedBox(
          width: colWidths[0],
          child: Text('col_place'.tr, style: style),
        ),
        SizedBox(
          width: colWidths[1],
          child: Text('col_company'.tr, style: style),
        ),
        SizedBox(
          width: colWidths[2],
          child: Text('col_category'.tr, style: style),
        ),
        SizedBox(
          width: colWidths[3],
          child: Text('col_province'.tr, style: style),
        ),
        SizedBox(
          width: colWidths[4],
          child: Text('col_date'.tr, style: style),
        ),
        SizedBox(
          width: colWidths[5],
          child: Text('col_status'.tr, style: style),
        ),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final AdminPlace place;
  final List<double> colWidths;
  const _PlaceRow({required this.place, required this.colWidths});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: colWidths[0],
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: place.imageColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: place.imageColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    place.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: colWidths[1],
            child: Text(
              place.company,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: colWidths[2], child: _tag(place.category)),
          SizedBox(
            width: colWidths[3],
            child: Text(
              place.province,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: colWidths[4],
            child: Text(
              place.submittedDate,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: colWidths[5], child: _statusChip(place.status)),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textPrimary),
        overflow: TextOverflow.ellipsis,
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
}
