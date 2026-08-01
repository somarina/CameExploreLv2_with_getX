import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A full-screen "please wait" overlay: blurred backdrop + rounded card +
/// an animated door loader + a status message. No buttons — it is meant
/// to be shown while an async action (login / register / guest / google /
/// telegram) is running, and dismissed automatically when it finishes.
///
/// Usage:
///   ProcessingOverlay.show();           // at the start of an async action
///   ...
///   ProcessingOverlay.hide();           // in the `finally` block
class ProcessingOverlay {
  ProcessingOverlay._();

  static bool _isShowing = false;

  static void show({String message = 'សូមរង់ចាំបន្តិច...'}) {
    if (_isShowing) return;
    _isShowing = true;
    Get.dialog(
      _ProcessingOverlayView(message: message),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      useSafeArea: false,
    );
  }

  static void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    if (Get.isDialogOpen == true) Get.back();
  }
}

class _ProcessingOverlayView extends StatefulWidget {
  final String message;
  const _ProcessingOverlayView({required this.message});

  @override
  State<_ProcessingOverlayView> createState() => _ProcessingOverlayViewState();
}

class _ProcessingOverlayViewState extends State<_ProcessingOverlayView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;
  late final Animation<double> _swing;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.9, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _swing = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black.withOpacity(0.35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(
                vertical: 34,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A).withOpacity(0.55),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedIcon(),
                  const SizedBox(height: 22),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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

  Widget _buildAnimatedIcon() {
    return SizedBox(
      width: 96,
      height: 96,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft orange glow, pulsing.
              Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF009A3F).withOpacity(0.55),
                        Color(0xFF009A3F).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Rotating loading ring.
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF5A3C),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.15),
                ),
              ),
              // Door icon, gently swinging open/closed like a door.
              Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_swing.value),
                child: const Icon(
                  Icons.sensor_door_outlined,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
