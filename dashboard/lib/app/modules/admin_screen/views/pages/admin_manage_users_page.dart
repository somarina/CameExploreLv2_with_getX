// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/admin_export/admin_export.dart';
import '../../controllers/admin_screen_controller.dart';
import '../../models/admin_colors.dart';
import '../../models/admin_models.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/admin_top_bar.dart';

class AdminManageUsersPage extends StatefulWidget {
  final AdminScreenController controller;
  const AdminManageUsersPage({super.key, required this.controller});

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Obx(() {
      final filtered = controller.companies.where((c) {
        if (_query.isEmpty) return true;
        final q = _query.toLowerCase();
        return c.name.toLowerCase().contains(q) || c.email.toLowerCase().contains(q) || c.location.toLowerCase().contains(q);
      }).toList();

      final totalPlaces = controller.companies.fold<int>(0, (sum, c) => sum + c.places);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminTopBar(
                  title: 'manage_users'.tr,
                  subtitle: 'manage_users_subtitle'.tr,
                  controller: controller,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;
                  final cards = [
                    _StatBox(label: 'Total Companies', value: '${controller.totalCompanies}', color: AdminColors.primary, icon: Icons.apartment_rounded),
                    _StatBox(label: 'Active', value: '${controller.totalCompanies}', color: AdminColors.green, icon: Icons.check_circle_outline_rounded),
                    _StatBox(label: 'Total Places', value: '$totalPlaces', color: AdminColors.purple, icon: Icons.place_outlined),
                    _StatBox(label: 'This Month', value: '3', color: AdminColors.amber, icon: Icons.trending_up_rounded),
                  ];
                  return GridView.count(
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isMobile ? 1.5 : 2.0,
                    children: cards,
                  );
                }),
                const SizedBox(height: 24),
                AdminSectionCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AdminSearchField(
                              hint: 'search_company_email_location'.tr,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ExportButton(onTap: () => exportCompaniesToExcel(filtered)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _TableHeader(),
                      ),
                      Divider(height: 24, color: AdminColors.border),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 36, color: AdminColors.textSecondary),
                                const SizedBox(height: 10),
                                Text('no_companies_match_search'.tr,
                                    style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filtered.map((c) => _CompanyRow(company: c, controller: controller)),
                      const SizedBox(height: 8),
                      Text('Showing ${filtered.length} of ${controller.totalCompanies} companies',
                          style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary)),
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

// ══════════════════════════ Animated stat box ══════════════════════════

class _StatBox extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBox({required this.label, required this.value, required this.color, required this.icon});

  @override
  State<_StatBox> createState() => _StatBoxState();
}

class _StatBoxState extends State<_StatBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hovering ? -2.0 : 0.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(AdminRadii.card),
          border: Border.all(color: _hovering ? widget.color.withOpacity(0.5) : AdminColors.border),
          boxShadow: _hovering
              ? [BoxShadow(color: widget.color.withOpacity(0.16), blurRadius: 16, offset: const Offset(0, 8))]
              : [],
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label,
                        style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(widget.value, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: widget.color)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

// ══════════════════════════ Table header ══════════════════════════
// Flex ratios below MUST match the Expanded flex values in _CompanyRow
// so header labels line up with their data columns.
// COMPANY=3, CONTACT=2, BUSINESS TYPE=3, LOCATION=2, PLACES=1, JOINED=2, ACTIONS=2

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textSecondary, letterSpacing: 0.4);

    Widget cell(String label, int flex) => Expanded(
          flex: flex,
          child: Text(
            label,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        );

    return Row(
      children: [
        cell('col_company'.tr, 3),
        cell('col_contact'.tr, 2),
        cell('col_business_type'.tr, 3),
        cell('col_location'.tr, 2),
        cell('col_places'.tr, 1),
        cell('col_joined'.tr, 2),
        cell('col_actions'.tr, 2),
      ],
    );
  }
}

// ══════════════════════════ Company row (hover-highlighted) ══════════════════════════

class _CompanyRow extends StatefulWidget {
  final AdminCompany company;
  final AdminScreenController controller;
  const _CompanyRow({required this.company, required this.controller});

  @override
  State<_CompanyRow> createState() => _CompanyRowState();
}

class _CompanyRowState extends State<_CompanyRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final controller = widget.controller;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovering ? AdminColors.surfaceLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: company.color,
                    child: Text(company.initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(company.name,
                            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('ID: ${company.id}', style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.mail_outline, size: 13, color: AdminColors.textSecondary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(company.email, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.call_outlined, size: 13, color: AdminColors.textSecondary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(company.phone, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
            Expanded(flex: 3, child: _BusinessTypeBadge(label: company.businessType, color: company.businessTypeColor)),
            Expanded(
              flex: 2,
              child: Row(children: [
                Icon(Icons.location_on_outlined, size: 14, color: AdminColors.textSecondary),
                const SizedBox(width: 4),
                Flexible(child: Text(company.location, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis)),
              ]),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AdminColors.background, borderRadius: BorderRadius.circular(8)),
                  child: Text('${company.places}', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                company.joined,
                style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIconButton(icon: Icons.visibility_outlined, tooltip: 'view_details'.tr, color: AdminColors.textSecondary, onTap: () {}),
                    _ActionIconButton(icon: Icons.person_off_outlined, tooltip: 'suspend'.tr, color: AdminColors.amber, onTap: () {}),
                    _ActionIconButton(icon: Icons.delete_outline, tooltip: 'remove'.tr, color: AdminColors.red, onTap: () => _confirmDelete(context, company, controller)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminCompany company, AdminScreenController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${'remove_question'.tr} "${company.name}"?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('remove_company_message'.tr, style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              controller.companies.remove(company);
              Navigator.pop(context);
            },
            child: Text('remove'.tr, style: const TextStyle(color: AdminColors.red)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════ Business type badge ══════════════════════════

class _BusinessTypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _BusinessTypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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