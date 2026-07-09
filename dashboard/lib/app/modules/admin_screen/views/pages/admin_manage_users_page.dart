import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminTopBar(
              title: 'Manage Users',
              subtitle: 'All registered companies and partners',
              controller: controller,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _statBox('Total Companies', '${controller.totalCompanies}', AdminColors.primary),
                const SizedBox(width: 16),
                _statBox('Active', '${controller.totalCompanies}', AdminColors.green),
                const SizedBox(width: 16),
                _statBox('Total Places', '$totalPlaces', AdminColors.purple),
                const SizedBox(width: 16),
                _statBox('This Month', '3', AdminColors.amber),
              ],
            ),
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
                          hint: 'Search by company, email, location...',
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AdminColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminRadii.chip)),
                        ),
                        icon: const Icon(Icons.download_outlined, size: 18, color: AdminColors.textPrimary),
                        label: Text('Export', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _TableHeader(),
                  const Divider(height: 24, color: AdminColors.border),
                  ...filtered.map((c) => _CompanyRow(company: c, controller: controller)),
                  const SizedBox(height: 8),
                  Text('Showing ${filtered.length} of ${controller.totalCompanies} companies',
                      style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statBox(String label, String value, Color color) {
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
            Flexible(child: Text(label, style: GoogleFonts.inter(fontSize: 13.5, color: AdminColors.textSecondary), overflow: TextOverflow.ellipsis)),
            Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          ],
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
        Expanded(flex: 3, child: Text('COMPANY', style: style)),
        Expanded(flex: 3, child: Text('CONTACT', style: style)),
        Expanded(flex: 2, child: Text('BUSINESS TYPE', style: style)),
        Expanded(flex: 2, child: Text('LOCATION', style: style)),
        Expanded(flex: 1, child: Text('PLACES', style: style)),
        Expanded(flex: 2, child: Text('JOINED', style: style)),
        Expanded(flex: 2, child: Text('ACTIONS', style: style)),
      ],
    );
  }
}

class _CompanyRow extends StatelessWidget {
  final AdminCompany company;
  final AdminScreenController controller;
  const _CompanyRow({required this.company, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                          overflow: TextOverflow.ellipsis),
                      Text('ID: ${company.id}', style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.mail_outline, size: 13, color: AdminColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(child: Text(company.email, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.call_outlined, size: 13, color: AdminColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(company.phone, style: GoogleFonts.inter(fontSize: 12.5, color: AdminColors.textPrimary)),
                ]),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: company.businessTypeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(company.businessType, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: company.businessTypeColor)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AdminColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(child: Text(company.location, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textPrimary), overflow: TextOverflow.ellipsis)),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AdminColors.background, borderRadius: BorderRadius.circular(8)),
              child: Text('${company.places}', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
            ),
          ),
          Expanded(flex: 2, child: Text(company.joined, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textPrimary))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionIcon(Icons.visibility_outlined, AdminColors.textSecondary, () {}),
                _actionIcon(Icons.person_off_outlined, AdminColors.amber, () {}),
                _actionIcon(Icons.delete_outline, AdminColors.red, () => _confirmDelete(context, company, controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, size: 18, color: color), splashRadius: 18, onPressed: onTap);
  }

  void _confirmDelete(BuildContext context, AdminCompany company, AdminScreenController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove "${company.name}"?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('This will remove the company account. This action cannot be undone.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.companies.remove(company);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: AdminColors.red)),
          ),
        ],
      ),
    );
  }
}
