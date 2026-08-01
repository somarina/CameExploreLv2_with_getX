// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/company_screen_controller.dart';
import '../widgets/company_top_bar.dart';

class CompanyMyPlacesPage extends StatelessWidget {
  final CompanyScreenController controller;
  final bool isDesktop;
  final bool isDark;
  final Color pageBg;
  final Color cardBg;
  final Color cardBorder;
  final Color titleColor;
  final Color subtitleColor;
  final Color mutedColor;
  final Color primaryColor; // green brand color
  final Color accentColor; // blue accent used on this page (matches the UI mock)

  const CompanyMyPlacesPage({
    super.key,
    required this.controller,
    required this.isDesktop,
    required this.isDark,
    required this.pageBg,
    required this.cardBg,
    required this.cardBorder,
    required this.titleColor,
    required this.subtitleColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyTopBar(
            title: "My Places",
            subtitle: "Manage your submitted tourism locations",
            controller: controller,
            isDesktop: isDesktop,
            isDark: isDark,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            mutedColor: mutedColor,
            cardBg: cardBg,
            cardBorder: cardBorder,
            primaryColor: primaryColor,
            showSearch: false,
            trailing: _addPlaceButton(),
          ),
          const SizedBox(height: 20),
          _searchAndToggleRow(),
          const SizedBox(height: 20),
          Obx(() {
            final places = controller.filteredMyPlaces;
            if (places.isEmpty) return _emptyState();
            return controller.isGridView.value ? _gridView(context, places) : _listView(context, places);
          }),
        ],
      ),
    );
  }

  Widget _addPlaceButton() {
    return ElevatedButton.icon(
      onPressed: controller.goToAddPlace,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      icon: const Icon(Icons.add, color: Colors.white, size: 18),
      label: Text("Add Place", style: companyFont("Add Place", color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _searchAndToggleRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: mutedColor),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.placesSearchController,
                    onChanged: (v) => controller.placesSearchQuery.value = v,
                    style: companyFont("x", color: titleColor, fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "Search places, provinces, categories...",
                      hintStyle: companyFont("x", color: mutedColor, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Obx(() => Row(
                children: [
                  _viewToggleButton(icon: Icons.grid_view_rounded, selected: controller.isGridView.value, onTap: () => controller.isGridView.value = true),
                  _viewToggleButton(icon: Icons.view_list_rounded, selected: !controller.isGridView.value, onTap: () => controller.isGridView.value = false),
                ],
              )),
        ),
      ],
    );
  }

  Widget _viewToggleButton({required IconData icon, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? (isDark ? Colors.white.withOpacity(.10) : Colors.black.withOpacity(.06)) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 19, color: selected ? titleColor : mutedColor),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.location_on_outlined, size: 38, color: mutedColor),
          ),
          const SizedBox(height: 22),
          Text("No Places Yet", style: companyFont("No Places Yet", color: titleColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Start by adding your first tourism location", style: companyFont("x", color: subtitleColor, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.goToAddPlace,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 19),
            label: Text("Add Your First Place", style: companyFont("Add Your First Place", color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return primaryColor;
      case "Rejected":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Widget _statusChip(String status) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: companyFont(status, color: c, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _placeImage(String source, {required double width, required double height, BoxFit fit = BoxFit.cover}) {
    // Uploaded places carry a real image URL (image_url from the backend);
    // only the untouched demo data still points at a bundled asset. Using
    // Image.asset on a URL throws and silently breaks that place's card, so
    // uploaded photos render via Image.network instead.
    final isNetwork = source.startsWith('http://') || source.startsWith('https://');
    final errorFallback = Container(
      width: width,
      height: height,
      color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined, size: 22, color: mutedColor),
    );
    if (isNetwork) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => errorFallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
            alignment: Alignment.center,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
            ),
          );
        },
      );
    }
    return Image.asset(source, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => errorFallback);
  }

  void _showPlaceDetail(BuildContext context, MyPlace p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _placeImage(p.imageAsset, width: double.infinity, height: 180),
                      Positioned(top: 12, right: 12, child: _statusChip(p.status)),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Material(
                          color: Colors.black.withOpacity(0.35),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.close_rounded, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: companyFont(p.name, color: titleColor, fontSize: 19, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.place_outlined, size: 15, color: mutedColor),
                            const SizedBox(width: 5),
                            Text(p.province.isEmpty ? "—" : p.province, style: companyFont("x", color: subtitleColor, fontSize: 13.5)),
                          ],
                        ),
                        if (p.category.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(p.category, style: companyFont(p.category, color: subtitleColor, fontSize: 12)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          p.entryFee > 0 ? "\$${p.entryFee.toStringAsFixed(p.entryFee % 1 == 0 ? 0 : 2)} entry fee" : "Free entry",
                          style: companyFont("x", color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        if (p.description.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(p.description, style: companyFont("x", color: subtitleColor, fontSize: 13.5)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gridView(BuildContext context, List<MyPlace> places) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        // A fixed height (instead of childAspectRatio) so the card hugs its
        // actual content (130px image + name/location/category block) no
        // matter how wide the column is — childAspectRatio was leaving a
        // large empty gap under the tag on narrow/mobile layouts.
        mainAxisExtent: 236,
      ),
      itemBuilder: (context, i) {
        final p = places[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showPlaceDetail(context, p),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _placeImage(p.imageAsset, width: double.infinity, height: 130),
                      Positioned(top: 10, right: 10, child: _statusChip(p.status)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: companyFont(p.name, color: titleColor, fontSize: 14.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.place_outlined, size: 13, color: mutedColor),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(p.province.isEmpty ? "—" : p.province, maxLines: 1, overflow: TextOverflow.ellipsis, style: companyFont("x", color: subtitleColor, fontSize: 12)),
                            ),
                          ],
                        ),
                        if (p.category.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(p.category, style: companyFont(p.category, color: subtitleColor, fontSize: 10.5)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _listView(BuildContext context, List<MyPlace> places) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: List.generate(places.length, (i) {
          final p = places[i];
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showPlaceDetail(context, p),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _placeImage(p.imageAsset, width: 56, height: 56),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: companyFont(p.name, color: titleColor, fontSize: 14.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                [if (p.category.isNotEmpty) p.category, if (p.province.isNotEmpty) p.province].join(" · "),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: companyFont("x", color: subtitleColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(p.status),
                      ],
                    ),
                  ),
                ),
              ),
              if (i != places.length - 1) Divider(height: 1, color: cardBorder),
            ],
          );
        }),
      ),
    );
  }
}
