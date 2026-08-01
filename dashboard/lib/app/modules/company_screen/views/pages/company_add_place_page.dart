// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/company_screen_controller.dart';
import '../widgets/company_top_bar.dart';
import '../../../auth/register_screen/views/location_picker_screen.dart';

class CompanyAddPlacePage extends StatefulWidget {
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
  final Color accentColor; // blue accent used on this page

  const CompanyAddPlacePage({
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
  State<CompanyAddPlacePage> createState() => _CompanyAddPlacePageState();
}

class _CompanyAddPlacePageState extends State<CompanyAddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameKmCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _descriptionKmCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _openingHoursCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  String? _category;
  final List<XFile> _images = [];
  final List<String> _tags = [];

  // Set once the company picks a spot on the map via LocationPickerScreen.
  double? _latitude;
  double? _longitude;
  String? _pickedAddress;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameKmCtrl.dispose();
    _provinceCtrl.dispose();
    _descriptionCtrl.dispose();
    _descriptionKmCtrl.dispose();
    _addressCtrl.dispose();
    _openingHoursCtrl.dispose();
    _phoneCtrl.dispose();
    _feeCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      Get.snackbar("Limit reached", "You can upload up to 5 images", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage();
      if (picked.isEmpty) return;
      setState(() {
        for (final f in picked) {
          if (_images.length >= 5) break;
          _images.add(f);
        }
      });
    } catch (_) {
      Get.snackbar("Couldn't open picker", "Image selection isn't available on this platform", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _removeImage(int i) => setState(() => _images.removeAt(i));

  void _addTag(String raw) {
    final tag = raw.trim();
    _tagInputCtrl.clear();
    if (tag.isEmpty || _tags.contains(tag)) return;
    if (_tags.length >= 10) {
      Get.snackbar("Limit reached", "You can add up to 10 tags", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _tags.add(tag));
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  Future<void> _pickLocation() async {
    final result = await Get.to<Map<String, dynamic>>(
      () => LocationPickerScreen(initialLat: _latitude, initialLng: _longitude),
    );
    if (result == null) return;
    setState(() {
      _latitude = (result["lat"] as num?)?.toDouble();
      _longitude = (result["lng"] as num?)?.toDouble();
      _pickedAddress = result["address"]?.toString();
      // Pre-fill the address field if the company hasn't typed one yet.
      if (_addressCtrl.text.trim().isEmpty && _pickedAddress != null) {
        _addressCtrl.text = _pickedAddress!;
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _nameKmCtrl.clear();
    _provinceCtrl.clear();
    _descriptionCtrl.clear();
    _descriptionKmCtrl.clear();
    _addressCtrl.clear();
    _openingHoursCtrl.clear();
    _phoneCtrl.clear();
    _feeCtrl.clear();
    _tagInputCtrl.clear();
    setState(() {
      _category = null;
      _images.clear();
      _tags.clear();
      _latitude = null;
      _longitude = null;
      _pickedAddress = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      Get.snackbar("Category required", "Please select a category", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final fee = double.tryParse(_feeCtrl.text.trim()) ?? 0;
    await widget.controller.submitNewPlace(
      name: _nameCtrl.text.trim(),
      nameKm: _nameKmCtrl.text.trim(),
      category: _category!,
      province: _provinceCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      descriptionKm: _descriptionKmCtrl.text.trim(),
      addressEn: _addressCtrl.text.trim(),
      openingHours: _openingHoursCtrl.text.trim(),
      phoneNum: _phoneCtrl.text.trim(),
      tags: _tags,
      latitude: _latitude,
      longitude: _longitude,
      entryFee: fee,
      images: _images,
    );
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final submitted = widget.controller.addPlaceSubmitted.value;
      return SingleChildScrollView(
        padding: EdgeInsets.all(widget.isDesktop ? 28 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyTopBar(
              title: "Add New Place",
              subtitle: "Submit a new tourism location for review",
              controller: widget.controller,
              isDesktop: widget.isDesktop,
              isDark: widget.isDark,
              titleColor: widget.titleColor,
              subtitleColor: widget.subtitleColor,
              mutedColor: widget.mutedColor,
              cardBg: widget.cardBg,
              cardBorder: widget.cardBorder,
              primaryColor: widget.primaryColor,
            ),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: submitted ? _successCard() : _formCard(),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Form ─────────────────────────────────────────────────────────
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.cardBorder),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: widget.primaryColor, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Place Information", style: companyFont("Place Information", color: widget.titleColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Fields marked * are required", style: companyFont("x", color: widget.subtitleColor, fontSize: 12.5)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.controller.goToMyPlaces,
                  child: Text("Cancel", style: companyFont("Cancel", color: widget.subtitleColor, fontSize: 13.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Divider(height: 40),

            _label("Place Name *"),
            _textField(controller: _nameCtrl, hint: "e.g., Angkor Wat Temple", validator: _requiredValidator),
            const SizedBox(height: 20),

            _label("Place Name (Khmer)"),
            _textField(controller: _nameKmCtrl, hint: "e.g., អង្គរវត្ត"),
            const SizedBox(height: 20),

            widget.isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _categoryField()),
                      const SizedBox(width: 16),
                      Expanded(child: _provinceField()),
                    ],
                  )
                : Column(
                    children: [
                      _categoryField(),
                      const SizedBox(height: 20),
                      _provinceField(),
                    ],
                  ),
            const SizedBox(height: 20),

            _label("Address"),
            _textField(controller: _addressCtrl, hint: "e.g., Krong Siem Reap, Angkor"),
            const SizedBox(height: 20),

            _label("Description *"),
            _textField(
              controller: _descriptionCtrl,
              hint: "Describe the place, its history, and what makes it special for visitors...",
              maxLines: 5,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 20),

            _label("Description (Khmer)"),
            _textField(
              controller: _descriptionKmCtrl,
              hint: "ការពិពណ៌នាអំពីទីកន្លែងជាភាសាខ្មែរ...",
              maxLines: 5,
            ),
            const SizedBox(height: 20),

            widget.isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Opening Hours"),
                            _textField(controller: _openingHoursCtrl, hint: "e.g., 5:00 AM – 6:00 PM"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Contact Phone"),
                            _textField(
                              controller: _phoneCtrl,
                              hint: "Defaults to your account phone",
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _label("Opening Hours"),
                      _textField(controller: _openingHoursCtrl, hint: "e.g., 5:00 AM – 6:00 PM"),
                      const SizedBox(height: 20),
                      _label("Contact Phone"),
                      _textField(
                        controller: _phoneCtrl,
                        hint: "Defaults to your account phone",
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
            const SizedBox(height: 20),

            _label("Tags"),
            _tagsField(),
            const SizedBox(height: 20),

            _label("Entry Fee (USD)"),
            _textField(
              controller: _feeCtrl,
              hint: "0 for free",
              prefixText: "\$ ",
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("Leave empty or enter 0 if entry is free", style: companyFont("x", color: widget.mutedColor, fontSize: 11.5)),
            ),
            const SizedBox(height: 22),

            _label("Images (${_images.length}/5)"),
            _imageUploadArea(),
            const SizedBox(height: 22),

            _label("Map Location"),
            InkWell(
              onTap: _pickLocation,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _latitude != null ? Icons.location_on : Icons.map_outlined,
                        color: widget.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _latitude != null ? "Location pinned" : "Pin this place on the map",
                            style: companyFont("x", color: widget.titleColor, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _latitude != null
                                ? (_pickedAddress ?? "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}")
                                : "Search or drop a pin so visitors can find it (optional)",
                            style: companyFont("x", color: widget.subtitleColor, fontSize: 12.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: widget.mutedColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.accentColor.withOpacity(.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: widget.accentColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Review Process", style: companyFont("Review Process", color: widget.accentColor, fontSize: 13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                          "Your submission will be reviewed within 1-2 business days. You'll be notified when it's approved or if changes are needed.",
                          style: companyFont("x", color: widget.subtitleColor, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              final submitting = widget.controller.isSubmittingPlace.value;
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accentColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: submitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline, color: Colors.white, size: 19),
                      label: Text("Submit for Review", style: companyFont("Submit for Review", color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.controller.goToMyPlaces,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: widget.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(Icons.arrow_back, size: 17, color: widget.subtitleColor),
                      label: Text("Cancel", style: companyFont("Cancel", color: widget.subtitleColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  static const _categoryIcons = <String, IconData>{
    "Temple": Icons.account_balance_rounded,
    "Beach": Icons.beach_access_rounded,
    "Museum": Icons.museum_rounded,
    "Nature & Park": Icons.park_rounded,
    "Historical Site": Icons.history_edu_rounded,
    "Waterfall": Icons.water_drop_rounded,
    "Mountain": Icons.terrain_rounded,
    "Cultural Site": Icons.theater_comedy_rounded,
    "Adventure": Icons.hiking_rounded,
    "Other": Icons.category_rounded,
  };

  Widget _categoryRow(String c, {bool selected = false}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(selected ? .22 : .12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _categoryIcons[c] ?? Icons.category_rounded,
            size: 16,
            color: widget.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            c,
            style: companyFont(
              c,
              color: widget.titleColor,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        if (selected)
          Icon(Icons.check_circle_rounded, size: 18, color: widget.primaryColor),
      ],
    );
  }

  Widget _categoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Category *"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _category,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.mutedColor),
              iconSize: 22,
              borderRadius: BorderRadius.circular(16),
              elevation: 3,
              menuMaxHeight: 360,
              itemHeight: 56,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              dropdownColor: widget.cardBg,
              hint: Text("Select category", style: companyFont("x", color: widget.mutedColor, fontSize: 14)),
              style: companyFont("x", color: widget.titleColor, fontSize: 14),
              selectedItemBuilder: (context) => CompanyScreenController.categoryOptions
                  .map((c) => Align(alignment: Alignment.centerLeft, child: _categoryRow(c)))
                  .toList(),
              items: CompanyScreenController.categoryOptions
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: _categoryRow(c, selected: c == _category),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _provinceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Province / City *"),
        _textField(controller: _provinceCtrl, hint: "e.g., Siem Reap", validator: _requiredValidator),
      ],
    );
  }

  Widget _tagsField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags
                  .map(
                    (t) => Chip(
                      label: Text(t, style: companyFont(t, color: widget.titleColor, fontSize: 12.5)),
                      backgroundColor: widget.primaryColor.withOpacity(.12),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeTag(t),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _tagInputCtrl,
            style: companyFont("x", color: widget.titleColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Type a tag and press Enter (e.g., family-friendly, waterfall)",
              hintStyle: companyFont("x", color: widget.mutedColor, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: _addTag,
          ),
        ],
      ),
    );
  }

  Widget _imageUploadArea() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(16),
      child: DottedBorderBox(
        color: widget.cardBorder,
        radius: 16,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: _images.isEmpty
              ? Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.upload_outlined, color: widget.mutedColor, size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text("Click to upload or drag & drop", style: companyFont("x", color: widget.titleColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text("PNG, JPG up to 10MB · Max 5 images", style: companyFont("x", color: widget.mutedColor, fontSize: 12)),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (int i = 0; i < _images.length; i++) _imageThumb(i),
                      if (_images.length < 5) _addMoreTile(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _imageThumb(int i) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FutureBuilder<Uint8List>(
            future: _images[i].readAsBytes(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Container(width: 72, height: 72, color: widget.isDark ? Colors.white12 : Colors.black12);
              }
              return Image.memory(snap.data!, width: 72, height: 72, fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: () => _removeImage(i),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addMoreTile() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.cardBorder),
        ),
        child: Icon(Icons.add, color: widget.mutedColor),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: companyFont(text, color: widget.titleColor, fontSize: 13.5, fontWeight: FontWeight.w600)),
      );

  String? _requiredValidator(String? v) => (v == null || v.trim().isEmpty) ? "This field is required" : null;

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: companyFont("x", color: widget.titleColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: companyFont("x", color: widget.mutedColor, fontSize: 13.5),
        prefixText: prefixText,
        prefixStyle: companyFont("x", color: widget.titleColor, fontSize: 14),
        filled: true,
        fillColor: widget.isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.accentColor, width: 1.4)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444))),
      ),
    );
  }

  // ── Success screen ───────────────────────────────────────────────
  Widget _successCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(.4), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 24),
          Text("Submitted Successfully!", style: companyFont("Submitted Successfully!", color: widget.titleColor, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Your place has been submitted for admin review.", textAlign: TextAlign.center, style: companyFont("x", color: widget.subtitleColor, fontSize: 14)),
          Text("You'll be notified once it's approved or if changes are needed.", textAlign: TextAlign.center, style: companyFont("x", color: widget.subtitleColor, fontSize: 14)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Review typically takes 1-2 business days. Check "My Places" for status updates.',
                    style: companyFont("x", color: const Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.controller.resetAddPlaceForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: Text("Add Another", style: companyFont("Add Another", color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.goToMyPlaces,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(Icons.place_outlined, size: 17, color: widget.subtitleColor),
                  label: Text("My Places", style: companyFont("My Places", color: widget.subtitleColor, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lightweight dashed-border container (avoids pulling in an extra package).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const DottedBorderBox({super.key, required this.child, required this.color, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color: color, radius: radius),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) => oldDelegate.color != color;
}