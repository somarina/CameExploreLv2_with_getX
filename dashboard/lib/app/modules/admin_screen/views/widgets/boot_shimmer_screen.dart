import 'package:flutter/material.dart';

import 'shimmer_box.dart';

/// Shown for a brief moment at startup, before GetStorage/theme/
/// translations are ready — so the very first frame is a clean shimmer
/// skeleton instead of a flash of untranslated glyph boxes (tofu) while
/// the Khmer font is still loading.
///
/// Shaped to loosely match the login card so the swap to the real
/// screen feels like a continuation, not a jump cut.
class BootShimmerScreen extends StatelessWidget {
  const BootShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF031024),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // logo + top-right circular buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 70, height: 70, borderRadius: 16),
                        Row(
                          children: [
                            ShimmerBox(width: 32, height: 32, borderRadius: 16),
                            SizedBox(width: 8),
                            ShimmerBox(width: 32, height: 32, borderRadius: 16),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // title + subtitle line
                    const ShimmerBox(width: 220, height: 22, borderRadius: 6),
                    const SizedBox(height: 12),
                    const ShimmerBox(width: 260, height: 14, borderRadius: 6),
                    const SizedBox(height: 24),
                    // email + password fields
                    const ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
                    const SizedBox(height: 12),
                    const ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
                    const SizedBox(height: 16),
                    // remember-me + forgot-password row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 160, height: 14, borderRadius: 6),
                        ShimmerBox(width: 90, height: 14, borderRadius: 6),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // sign-in button
                    const ShimmerBox(width: double.infinity, height: 50, borderRadius: 12),
                    const SizedBox(height: 20),
                    const Center(child: ShimmerBox(width: 180, height: 14, borderRadius: 6)),
                    const SizedBox(height: 16),
                    // social login circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        ShimmerBox(width: 48, height: 48, borderRadius: 24),
                        SizedBox(width: 16),
                        ShimmerBox(width: 48, height: 48, borderRadius: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
