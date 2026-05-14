import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return _buildPageLayout(topWidget: _buildPageOneImages());
  }

  Widget _buildPageTwo() {
    return _buildPageLayout(topWidget: _buildRelaxDesign());
  }

  Widget _buildPageThree() {
    return _buildPageLayout(topWidget: _buildTravelCards());
  }

  Widget _buildPageLayout({required Widget topWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70), // ← space below skip button
        topWidget,
        const SizedBox(height: 8),
        _buildTitle(),
        const SizedBox(height: 12),
        _buildDescription(),
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
                "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
                width: 175,
                height: 245,
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 70,
            child: Transform.rotate(
              angle: 0.14,
              child: _buildImageCard(
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
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
                "https://images.unsplash.com/photo-1524492412937-b28074a5d7da",
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
            top: 70,
            left: 130,
            color: Colors.black,
            white: true,
          ),
          _buildChip(
            "Modern",
            top: 42,
            right: 70,
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
          const Positioned(
            right: 55,
            top: 145,
            child: Text(
              "☺",
              style: TextStyle(
                fontSize: 120,
                color: Color(0xffF2B705),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 360,
        child: Stack(
          children: [
            // Background card
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECEF),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),

            // Decorative dots
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 20,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7FD956),
                ),
              ),
            ),
            Positioned(
              bottom: 34,
              left: 24,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF5722),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ),

            // Blue accent bar in the middle
            Positioned(
              left: 100,
              top: 155,
              width: 200,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7FD9).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Left tall image (night sky)
            Positioned(
              left: 14,
              top: 18,
              bottom: 18,
              child: _buildImageCard(
                "https://images.unsplash.com/photo-1419242902214-272b3f66ee7a",
                width: 140,
                height: 324,
              ),
            ),

            // Top right image (ocean/beach)
            Positioned(
              right: 14,
              top: 18,
              child: _buildImageCard(
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
                width: 160,
                height: 161,
              ),
            ),

            // Bottom right image (ruins)
            Positioned(
              right: 14,
              bottom: 18,
              child: _buildImageCard(
                "https://images.unsplash.com/photo-1524492412937-b28074a5d7da",
                width: 160,
                height: 161,
              ),
            ),

            // Naihuoy card - centered between left and right
            Positioned(
              left: 108,
              top: 68,
              child: _buildReviewCard(
                name: "Naihuoy",
                rating: "4/5",
                imageUrl:
                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80",
              ),
            ),

            // Monxaa card - bottom left
            Positioned(
              left: 20,
              bottom: 38,
              child: _buildReviewCard(
                name: "Monxaa",
                rating: "3.6/5",
                imageUrl:
                    "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          children: [
            TextSpan(text: "ស្វែងរកទី\nកន្លែង "),
            TextSpan(
              text: "ប្រវត្តិសាស្រ្ត",
              style: TextStyle(backgroundColor: Color(0xff28C98B)),
            ),
            TextSpan(text: "\nដ៏អស្ចារ្យ !"),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        "We believe that traveling around the\nworld shouldn’t be hard.",
        style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
      ),
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
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "skip",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
          image: NetworkImage(imageUrl),
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
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
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
