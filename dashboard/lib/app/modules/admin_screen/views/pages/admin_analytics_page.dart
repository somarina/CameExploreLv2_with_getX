import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

class AdminAnalyticsPage extends StatelessWidget {
  final AdminScreenController controller;
  const AdminAnalyticsPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final approvalRate = controller.totalPlaces == 0
          ? 0
          : ((controller.approvedCount / controller.totalPlaces) * 100).round();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminTopBar(
              title: 'analytics'.tr,
              subtitle: 'analytics_subtitle'.tr,
              controller: controller,
            ),
            const SizedBox(height: 24),

            LayoutBuilder(builder: (context, constraints) {
              final cards = [
                AdminStatCard(
                  icon: Icons.place_outlined,
                  iconColor: AdminColors.primary,
                  iconBg: AdminColors.primaryLight,
                  label: 'total_submissions'.tr,
                  value: '32',
                  badgeText: '+18%',
                  badgeColor: AdminColors.primary,
                  badgeBg: AdminColors.primaryLight,
                ),
                AdminStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AdminColors.green,
                  iconBg: AdminColors.greenLight,
                  label: 'approval_rate'.tr,
                  value: '$approvalRate%',
                  badgeText: '+4%',
                  badgeColor: AdminColors.green,
                  badgeBg: AdminColors.greenLight,
                ),
                AdminStatCard(
                  icon: Icons.access_time_rounded,
                  iconColor: AdminColors.amber,
                  iconBg: AdminColors.amberLight,
                  label: 'pending'.tr,
                  value: '${controller.pendingCount}',
                  badgeText: 'active'.tr,
                  badgeColor: AdminColors.amber,
                  badgeBg: AdminColors.amberLight,
                ),
                AdminStatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: AdminColors.purple,
                  iconBg: AdminColors.purpleLight,
                  label: 'avg_per_month'.tr,
                  value: '14',
                  badgeText: '+12%',
                  badgeColor: AdminColors.purple,
                  badgeBg: AdminColors.purpleLight,
                ),
              ];
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: cards
                    .map((c) => SizedBox(width: (constraints.maxWidth - 60) / 4 < 220 ? constraints.maxWidth : (constraints.maxWidth - 60) / 4, child: c))
                    .toList(),
              );
            }),

            const SizedBox(height: 24),

            AdminSectionCard(child: _MonthlyTrendChart(controller: controller)),

            const SizedBox(height: 24),

            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              final topProvinces = AdminSectionCard(child: _TopProvincesBarChart(controller: controller));
              final categoryBreakdown = AdminSectionCard(child: _CategoryBreakdown(controller: controller));
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: topProvinces),
                    const SizedBox(width: 20),
                    Expanded(child: categoryBreakdown),
                  ],
                );
              }
              return Column(children: [topProvinces, const SizedBox(height: 20), categoryBreakdown]);
            }),

            const SizedBox(height: 24),

            AdminSectionCard(child: _ApprovalSummary(controller: controller)),

            const SizedBox(height: 24),

            AdminSectionCard(child: _ProvincePerformanceTable(controller: controller)),
          ],
        ),
      );
    });
  }
}

class _MonthlyTrendChart extends StatelessWidget {
  final AdminScreenController controller;
  const _MonthlyTrendChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: 'monthly_trend'.tr, subtitle: 'monthly_trend_subtitle'.tr),
        const SizedBox(height: 20),
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 24,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 6,
                getDrawingHorizontalLine: (v) => FlLine(color: AdminColors.border, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 6,
                    reservedSize: 32,
                    getTitlesWidget: (v, meta) => Text('${v.toInt()}', style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= months.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(months[i], style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _line(controller.monthlySubmissions, AdminColors.primary, fill: true),
                _line(controller.monthlyApproved, AdminColors.green, fill: false),
                _line(controller.monthlyRejected, AdminColors.red, fill: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _legendDot(AdminColors.primary, 'Submissions'),
          const SizedBox(width: 20),
          _legendDot(AdminColors.green, 'approved'.tr),
          const SizedBox(width: 20),
          _legendDot(AdminColors.red, 'rejected'.tr),
        ]),
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
      belowBarData: fill ? BarAreaData(show: true, color: color.withOpacity(0.08)) : BarAreaData(show: false),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary)),
    ]);
  }
}

class _TopProvincesBarChart extends StatelessWidget {
  final AdminScreenController controller;
  const _TopProvincesBarChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.provinceStats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: 'top_provinces'.tr, subtitle: 'top_provinces_subtitle'.tr),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: 40,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (v) => FlLine(color: AdminColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 30,
                    getTitlesWidget: (v, meta) => Text('${v.toInt()}', style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(data[i].province, style: GoogleFonts.inter(fontSize: 10, color: AdminColors.textSecondary)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < data.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: data[i].places.toDouble(),
                      color: [AdminColors.primary, AdminColors.green, AdminColors.amber, AdminColors.purple, Color(0xFFEC4899), AdminColors.teal][i % 6],
                      width: 26,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final AdminScreenController controller;
  const _CategoryBreakdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: 'category_breakdown'.tr, subtitle: 'category_breakdown_subtitle'.tr),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 52,
              sections: controller.categoryStats
                  .map((c) => PieChartSectionData(value: c.percent.toDouble(), color: c.color, radius: 30, showTitle: false))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: controller.categoryStats
              .map((c) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('${c.label}  ${c.percent}%', style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textPrimary)),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ApprovalSummary extends StatelessWidget {
  final AdminScreenController controller;
  const _ApprovalSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    Widget box(String label, IconData icon, int value, int percent, Color color, Color bg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdminRadii.card)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(label, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                  ]),
                  Text('$value', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 6,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 8),
              Text('$percent% of total', style: GoogleFonts.inter(fontSize: 12.5, color: color)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('approval_summary'.tr, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
        const SizedBox(height: 20),
        Row(
          children: [
            box('approved'.tr, Icons.check_circle_outline, 18, 72, AdminColors.green, AdminColors.greenLight),
            const SizedBox(width: 16),
            box('pending'.tr, Icons.access_time_rounded, 6, 18, AdminColors.amber, AdminColors.amberLight),
            const SizedBox(width: 16),
            box('rejected'.tr, Icons.cancel_outlined, 4, 10, AdminColors.red, AdminColors.redLight),
          ],
        ),
      ],
    );
  }
}

class _ProvincePerformanceTable extends StatelessWidget {
  final AdminScreenController controller;
  const _ProvincePerformanceTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.provinceStats;
    final headerStyle = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textSecondary, letterSpacing: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: 'province_performance'.tr, subtitle: 'province_performance_subtitle'.tr),
        const SizedBox(height: 20),
        Row(children: [
          SizedBox(width: 36, child: Text('#', style: headerStyle)),
          Expanded(flex: 3, child: Text('col_province'.tr, style: headerStyle)),
          Expanded(flex: 2, child: Text('col_places'.tr, style: headerStyle)),
          Expanded(flex: 3, child: Text('col_share'.tr, style: headerStyle)),
          Expanded(flex: 2, child: Text('col_growth'.tr, style: headerStyle)),
        ]),
        Divider(height: 24, color: AdminColors.border),
        for (int i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 36, child: Text('${i + 1}', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary))),
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    Icon(Icons.location_on_outlined, size: 15, color: AdminColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(data[i].province, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textPrimary)),
                  ]),
                ),
                Expanded(flex: 2, child: Text('${data[i].places}', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary))),
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: data[i].share / 100,
                          minHeight: 6,
                          backgroundColor: AdminColors.background,
                          valueColor: const AlwaysStoppedAnimation(AdminColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${data[i].share}%', style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary)),
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AdminStatusChip(text: '+${data[i].growth}%', color: AdminColors.green, bg: AdminColors.greenLight),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
