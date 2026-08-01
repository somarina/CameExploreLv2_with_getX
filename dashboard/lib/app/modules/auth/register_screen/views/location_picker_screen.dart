import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;

import '../controllers/register_screen_controller.dart';

/// Full-screen "pick your location on the map" flow.
/// Returns a Map<String, dynamic> with keys `address`, `lat`, `lng`
/// via Navigator/Get.back when the user confirms, or null if they cancel.
class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Accent red used for the confirm button / pin, matching the reference app.
  static const Color accentRed = Color(0xFFE9243A);
  static const Color pinBlack = Color(0xFF2B2B2B);

  // Default to Phnom Penh when nothing was picked yet.
  static const LatLng _phnomPenh = LatLng(11.5564, 104.9282);

  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _center;
  LatLng? _pendingCenter;
  String? _resolvedAddress;
  bool _resolvingAddress = false;

  // Decorative city label shown as a chip next to the search bar, matching
  // the reference design. The Places search itself is already scoped to
  // Cambodia, so this is a display affordance for now rather than a real
  // city filter.
  String _cityLabel = 'ភ្នំពេញ';

  @override
  void initState() {
    super.initState();
    _center = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _phnomPenh;
    _resolveAddress(_center);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng position) async {
    setState(() => _resolvingAddress = true);
    final address = await reverseGeocode(
      position.latitude,
      position.longitude,
    );
    if (!mounted) return;
    setState(() {
      _resolvedAddress = address ??
          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      _resolvingAddress = false;
    });
  }

  /// Calls the Google Geocoding API directly to turn lat/lng into a
  /// human-readable address.
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng'
        '&key=${RegisterScreenController.googleMapsApiKey}',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;
      final results = data['results'] as List;
      if (results.isEmpty) return null;
      return results.first['formatted_address'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _animateTo(LatLng target, {double zoom = 16}) async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
    setState(() => _center = target);
    _resolveAddress(target);
  }

  void _pickCity() {
    // Simple picker for the handful of cities the business supports.
    // Selecting one just re-centers the map for now; wire this up to a
    // real city -> lat/lng lookup if/when you have one.
    const cities = <String, LatLng>{
      'ភ្នំពេញ': _phnomPenh,
      'សៀមរាប': LatLng(13.3671, 103.8448),
      'បាត់ដំបង': LatLng(13.0957, 103.2022),
      'ព្រះសីហនុ': LatLng(10.6104, 103.5300),
    };
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: cities.entries
              .map(
                (e) => ListTile(
                  title: Text(e.key, style: _font(Colors.black87, fontSize: 15)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _cityLabel = e.key);
                    _animateTo(e.value, zoom: 13);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  TextStyle _font(
    Color color, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.notoSansKhmer(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header: back + title ─────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      'ស្វែងរកទីតាំង',
                      textAlign: TextAlign.center,
                      style: _font(
                        Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // balances the back button
                ],
              ),
            ),
          ),

          // ── City chip + search bar ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Material(
                  color: const Color(0xFFF0F1F3),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _pickCity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_cityLabel, style: _font(Colors.black87, fontSize: 14)),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: const Color(0xFFF0F1F3),
                    borderRadius: BorderRadius.circular(24),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _searchController,
                      googleAPIKey: RegisterScreenController.googleMapsApiKey,
                      countries: const ['kh'],
                      debounceTime: 400,
                      textStyle: _font(Colors.black87, fontSize: 14),
                      inputDecoration: InputDecoration(
                        hintText: 'ស្វែងរកទីតាំង',
                        hintStyle: _font(Colors.black38, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF0F1F3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black45,
                          size: 20,
                        ),
                      ),
                      itemClick: (Prediction prediction) {
                        _searchController.text = prediction.description ?? '';
                        final lat = double.tryParse(prediction.lat ?? '');
                        final lng = double.tryParse(prediction.lng ?? '');
                        if (lat != null && lng != null) {
                          _animateTo(LatLng(lat, lng));
                        }
                      },
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        final lat = double.tryParse(prediction.lat ?? '');
                        final lng = double.tryParse(prediction.lng ?? '');
                        if (lat != null && lng != null) {
                          _animateTo(LatLng(lat, lng));
                        }
                      },
                      isLatLngRequired: true,
                      isCrossBtnShown: true,
                      containerHorizontalPadding: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Map with fixed center pin ─────────────────────────
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _center, zoom: 15),
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                  },
                  onCameraMove: (position) =>
                      _pendingCenter = position.target,
                  onCameraIdle: () {
                    if (_pendingCenter != null) {
                      _center = _pendingCenter!;
                      _resolveAddress(_center);
                    }
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                ),

                // Fixed pin, dead-center, with a soft shadow "ellipse" under
                // it like the reference screenshot.
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: pinBlack,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: accentRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 18,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Address preview pill floating above the confirm button.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place, color: accentRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _resolvingAddress
                                ? Text(
                                    'កំពុងស្វែងរកអាសយដ្ឋាន...',
                                    style: _font(Colors.black54, fontSize: 13),
                                  )
                                : Text(
                                    _resolvedAddress ??
                                        'រំកិលផែនទីដើម្បីជ្រើសរើសទីតាំង',
                                    style: _font(
                                      Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom confirm button (full width, red) ───────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: _resolvingAddress
                      ? null
                      : () {
                          Get.back(result: {
                            'address': _resolvedAddress ?? '',
                            'lat': _center.latitude,
                            'lng': _center.longitude,
                          });
                        },
                  child: Text(
                    'ជ្រើសរើសទីតាំងនេះ',
                    style: _font(
                      Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}