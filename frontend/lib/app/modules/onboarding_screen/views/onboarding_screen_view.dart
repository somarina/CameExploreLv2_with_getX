import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/onboarding_screen_controller.dart';

class OnboardingScreenView extends GetView<OnboardingScreenController> {
  const OnboardingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildPageView(),
            _buildSkipButton(),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      children: [_buildPageOne(), _buildPageTwo(), _buildPageThree()],
    );
  }

  Widget _buildPageOne() {
    return _buildPageLayout(
      topWidget: _buildPageOneImages(),
      title: _buildTitleOne(),
      description: _buildDescriptionOne(),
    );
  }

  Widget _buildPageTwo() {
    return _buildPageLayout(
      topWidget: _buildRelaxDesign(),
      title: _buildTitleTwo(),
      description: _buildDescriptionTwo(),
    );
  }

  Widget _buildPageThree() {
    return _buildPageLayout(
      topWidget: _buildTravelCards(),
      title: _buildTitleThree(),
      description: _buildDescriptionThree(),
    );
  }

  Widget _buildPageLayout({
    required Widget topWidget,
    required Widget title,
    required Widget description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70), // ← space below skip button
        topWidget,
        const SizedBox(height: 8),
        title,
        const SizedBox(height: 12),
        description,
        const SizedBox(height: 34),
        _buildIndicators(),
        const SizedBox(height: 40), // ← space above bottom button
      ],
    );
  }

  Widget _buildPageOneImages() {
    return SizedBox(
      height: 375,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 28,
            top: 50,
            child: Transform.rotate(
              angle: -0.14,
              child: _buildImageCard(
                "assets/images/onboard1_3.png",
                width: 175,
                height: 245,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 70,
            child: Transform.rotate(
              angle: 0.14,
              child: _buildImageCard(
                "assets/images/onboard1_2.png",
                width: 175,
                height: 245,
              ),
            ),
          ),
          Positioned(
            top: 105,
            child: Transform.rotate(
              angle: 0.04,
              child: _buildImageCard(
                "assets/images/onboard1_1.png",
                width: 215,
                height: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelaxDesign() {
    return SizedBox(
      height: 375,
      child: Stack(
        children: [
          _buildChip(
            "Y2K",
            top: 50,
            left: 100,
            color: Colors.black,
            white: true,
          ),
          _buildChip(
            "Modern",
            top: 42,
            right: 90,
            color: const Color(0xffffdda6),
          ),
          _buildChip("Premium", top: 145, left: 38, color: Colors.white),
          _buildChip(
            "Relax",
            top: 112,
            left: 130,
            color: Colors.orange,
            white: true,
          ),
          _buildChip("Vintage", top: 108, right: 48, color: Colors.white),
          _buildChip(
            "Local",
            top: 205,
            left: 70,
            color: const Color(0xffffdda6),
          ),
          _buildChip(
            "Chill",
            top: 240,
            left: 165,
            color: Colors.orange,
            white: true,
          ),
          Positioned(
            right: 40,
            top: 155,
            child: Image.asset(
              "assets/icons/happy_emoji.png",
              width: 145,
              height: 145,
            ),
            // child: Text(
            //   "☺",
            //   style: TextStyle(
            //     fontSize: 120,
            //     color: Color(0xffF2B705),
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height:
            375, // ← matches page 1 & 2 so title/description sit at the same height
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed hero image
              Image.asset("assets/images/sunset04.png", fit: BoxFit.cover),

              // Dark gradient so the glow + chips stay readable over the photo
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),

              // Blurred color glow bleeding off the top edge
              Positioned(
                top: -30,
                left: -20,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF5722).withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                right: -10,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7FD956).withOpacity(0.7),
                    ),
                  ),
                ),
              ),

              // Naihuoy card
              Positioned(
                left: 24,
                top: 70,
                child: _TapScale(
                  child: _buildReviewCard(
                    name: "Naihuoy",
                    rating: "4/5",
                    imageUrl:
                        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80",
                  ),
                ),
              ),

              // Monxaa card
              Positioned(
                left: 20,
                bottom: 38,
                child: _TapScale(
                  child: _buildReviewCard(
                    name: "Monxaa",
                    rating: "3.6/5",
                    imageUrl:
                        "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared title layout: two-line headline + slanted highlighted word ──
  Widget _buildTitleWithHighlight({
    required String beforeHighlight,
    required String highlight,
    required String afterHighlight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          children: [
            TextSpan(text: beforeHighlight),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ClipPath(
                clipper: SlantedLabelClipper(),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 24, // extra left padding to avoid clip cutting text
                    right: 28, // extra right padding for the slant
                    top: 6,
                    bottom: 6,
                  ),
                  color: Color(0xFF28C98B),
                  child: Text(
                    highlight,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            TextSpan(text: afterHighlight),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
      ),
    );
  }

  // ── Page 1: explore/history ──
  Widget _buildTitleOne() {
    return _buildTitleWithHighlight(
      beforeHighlight: "ស្វែងរកទី\nកន្លែង ",
      highlight: "ប្រវត្តិសាស្រ្ត",
      afterHighlight: "\nដ៏អស្ចារ្យ !",
    );
  }

  Widget _buildDescriptionOne() {
    return _buildDescriptionText(
      "We believe that traveling around the\nworld shouldn't be hard.",
    );
  }

  // ── Page 2: style/vibe ──
  Widget _buildTitleTwo() {
    return _buildTitleWithHighlight(
      beforeHighlight: "ជ្រើសរើសទី\nកន្លែង ",
      highlight: "ដែល Relax",
      afterHighlight: "\nនិងគួអោយចង់ទៅ !",
    );
  }

  Widget _buildDescriptionTwo() {
    return _buildDescriptionText(
      "Choose the style you love and we'll\nfind the perfect spot for you.",
    );
  }

  // ── Page 3: reviews ──
  Widget _buildTitleThree() {
    return _buildTitleWithHighlight(
      beforeHighlight: "ស្វែងរក\nទីកន្លែង",
      highlight: "ដែលមានទេសភាព",
      afterHighlight: "\nដ៏ស្រស់ស្អាត !",
    );
  }

  Widget _buildDescriptionThree() {
    return _buildDescriptionText(
      "Real travelers, real reviews —\nplan with confidence.",
    );
  }

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        return Row(
          children: List.generate(3, (index) {
            final active = controller.currentPage.value == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              width: active ? 30 : 18,
              height: 5,
              decoration: BoxDecoration(
                color: active ? const Color(0xff009B45) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: controller.skip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xff009B45),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Text(
            "រំលង",
            style: GoogleFonts.kantumruyPro(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      left: 34,
      right: 34,
      bottom: 24,
      child: Obx(() {
        final isLast = controller.currentPage.value == 2;

        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (isLast) {
                controller.finishOnboarding();
              } else {
                controller.nextPage();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff009B45),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              isLast ? "ចាប់ផ្ដើម" : "បន្ត",
              style: GoogleFonts.kantumruyPro(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageCard(
    String imageUrl, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl) as ImageProvider
              : AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildChip(
    String text, {
    double? top,
    double? left,
    double? right,
    required Color color,
    bool white = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: white ? Colors.white : Colors.orange.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String rating,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class SlantedLabelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(16, 0); // top-left — slant starts here
    path.lineTo(size.width, 0); // top-right
    path.lineTo(size.width - 16, size.height); // bottom-right slant
    path.lineTo(0, size.height); // bottom-left straight
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TapScale extends StatefulWidget {
  final Widget child;

  const _TapScale({required this.child});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  double _scale = 1.0;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
