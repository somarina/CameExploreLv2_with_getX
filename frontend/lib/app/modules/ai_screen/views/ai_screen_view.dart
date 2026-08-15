// ignore_for_file: unused_element

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

import '../controllers/ai_screen_controller.dart';
import '../models/ai_chat_message.dart';

// Signature accent for the AI assistant: a warm "temple gold" that plays
// against the app's Cambodia-flag green, used only for AI touchpoints
// (avatar, typing indicator, maps chip) so it reads as this screen's own.
const Color _aiGold = Color(0xFFD9A441);

class AiScreenView extends GetView<AiScreenController> {
  const AiScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _AiAppBar(colors: colors),
      ),
      body: Stack(
        children: [
          // Rich AI travel background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF071C14),
                        Color(0xFF102B21),
                        Color(0xFF171B18),
                      ]
                    : const [
                        Color(0xFFE2F7EA),
                        Color(0xFFF4FBF7),
                        Color(0xFFFFF5DF),
                      ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          Positioned(
            top: -120,
            left: -100,
            child: _GlowOrb(
              size: 300,
              color: colors.primary,
              opacity: isDark ? 0.18 : 0.16,
            ),
          ),
          Positioned(
            top: 150,
            right: -120,
            child: _GlowOrb(
              size: 290,
              color: _aiGold,
              opacity: isDark ? 0.12 : 0.14,
            ),
          ),
          Positioned(
            bottom: 90,
            left: -110,
            child: _GlowOrb(
              size: 300,
              color: const Color(0xFF54BFA0),
              opacity: isDark ? 0.10 : 0.11,
            ),
          ),

          const Positioned(
            top: 95,
            right: 30,
            child: _AiDot(size: 13, color: _aiGold),
          ),
          const Positioned(
            top: 145,
            right: 76,
            child: _AiDot(size: 7, color: Colors.white),
          ),
          const Positioned(
            top: 300,
            left: 24,
            child: _AiDot(size: 9, color: _aiGold),
          ),
          const Positioned(
            bottom: 190,
            right: 30,
            child: _AiDot(size: 11, color: Colors.white),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      const _ChatWatermark(),
                      Obx(
                        () => ListView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                          itemCount:
                              controller.messages.length +
                              (controller.isSending.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= controller.messages.length) {
                              return const _TypingRow();
                            }
                            final message = controller.messages[index];
                            return _ChatBubble(
                              message: message,
                              colors: colors,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _MessageInputBar(controller: controller, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiDot extends StatelessWidget {
  const _AiDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.35),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// Faint Angkor-style silhouette that lives behind the message list so an
// early/empty conversation still feels designed rather than just blank grey.
// Purely decorative: IgnorePointer keeps it out of the way of scroll/taps.
class _ChatWatermark extends StatelessWidget {
  const _ChatWatermark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = colors.primary.withValues(alpha: 0.05);

    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, 0.62),
        child: Icon(Icons.account_balance_rounded, size: 220, color: tint),
      ),
    );
  }
}

class _AiAppBar extends StatelessWidget {
  const _AiAppBar({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.82)],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_aiGold, Color(0xFFFFE6A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _aiGold.withValues(alpha: 0.55),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.96),
                    child: Lottie.asset(
                      'assets/icons/camexplore_ai_robot.json',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CamExplore AI',
                      style: AppFonts.fontsSubTitle.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'AI travel companion • Online',
                      style: AppFonts.fontHeaderSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.colors});

  final AiChatMessage message;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == AiSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[const _AiAvatar(), const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.74,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primary,
                              colors.primary.withValues(alpha: 0.85),
                            ],
                          )
                        : null,
                    color: isUser
                        ? null
                        : (message.isError
                              ? colors.tertiary.withValues(alpha: 0.10)
                              : colors.primaryContainer),
                    border: !isUser && !message.isError
                        ? Border.all(
                            color: colors.primary.withValues(alpha: 0.08),
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? colors.primary : Colors.black)
                            .withValues(alpha: isUser ? 0.18 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.localImagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(message.localImagePath!),
                              width: 190,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      MarkdownBody(
                        data: message.text,
                        selectable: true,
                        shrinkWrap: true,
                        styleSheet: MarkdownStyleSheet(
                          p: AppFonts.fontsGeneral.copyWith(
                            fontSize: 15,
                            height: 1.45,
                            color: isUser
                                ? Colors.white
                                : (message.isError
                                      ? colors.tertiary
                                      : colors.onSurface),
                          ),
                          strong: AppFonts.fontsGeneral.copyWith(
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w800,
                            color: isUser
                                ? Colors.white
                                : (message.isError
                                      ? colors.tertiary
                                      : colors.onSurface),
                          ),
                          em: AppFonts.fontsGeneral.copyWith(
                            fontSize: 15,
                            height: 1.45,
                            fontStyle: FontStyle.italic,
                            color: isUser
                                ? Colors.white
                                : (message.isError
                                      ? colors.tertiary
                                      : colors.onSurface),
                          ),
                          h1: AppFonts.fontsSubTitle.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: isUser ? Colors.white : colors.onSurface,
                          ),
                          h2: AppFonts.fontsSubTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isUser ? Colors.white : colors.onSurface,
                          ),
                          h3: AppFonts.fontsSubTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isUser ? Colors.white : colors.onSurface,
                          ),
                          listBullet: AppFonts.fontsGeneral.copyWith(
                            fontSize: 15,
                            color: isUser ? Colors.white : colors.primary,
                          ),
                          blockSpacing: 8,
                          listIndent: 18,
                          blockquoteDecoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border(
                              left: BorderSide(color: colors.primary, width: 3),
                            ),
                          ),
                          blockquotePadding: const EdgeInsets.fromLTRB(
                            12,
                            6,
                            8,
                            6,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (message.googleMapsUrl != null) ...[
                        const SizedBox(height: 10),
                        _MapsChip(url: message.googleMapsUrl!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (message.suggestedPlaces.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 148,
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 40),
                scrollDirection: Axis.horizontal,
                itemCount: message.suggestedPlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _SuggestedPlaceCard(place: message.suggestedPlaces[i]),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_aiGold, Color(0xFFFFE6A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _aiGold.withValues(alpha: 0.35),
            blurRadius: 9,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: Lottie.asset(
            'assets/icons/camexplore_ai_robot.json',
            width: 39,
            height: 39,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    );
  }
}

class _MapsChip extends StatelessWidget {
  const _MapsChip({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                "View on Google Maps",
                style: AppFonts.fontsGeneral.copyWith(
                  fontSize: 13,
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.north_east_rounded, size: 13, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestedPlaceCard extends StatelessWidget {
  const _SuggestedPlaceCard({required this.place});

  final AiSuggestedPlace place;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 84,
                width: double.infinity,
                child: place.imageUrl.isEmpty
                    ? const _ImagePlaceholder()
                    : CachedNetworkImage(
                        imageUrl: place.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _ImagePlaceholder(),
                        errorWidget: (_, __, ___) => const _ImagePlaceholder(),
                      ),
              ),
              if (place.rating > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: _aiGold,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          place.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.fontsGeneral.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 11,
                      color: colors.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        place.province,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fontDescriptionsmall.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A styled "no photo yet" tile instead of a flat grey box, so a missing
// image reads as an intentional design choice rather than a broken load.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.16),
            _aiGold.withValues(alpha: 0.14),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.landscape_rounded,
        color: colors.primary.withValues(alpha: 0.45),
        size: 26,
      ),
    );
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _AiAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 34,
      height: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final t = (_controller.value - (i * 0.2)) % 1.0;
              final scale =
                  0.55 + 0.45 * (1 - (2 * t - 1).abs()).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({required this.controller, required this.colors});

  final AiScreenController controller;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colors.primary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(
                () => Material(
                  color: colors.primary.withValues(alpha: 0.10),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: controller.isSending.value
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            controller.sendMessage();
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                    controller.sendMessage();
                  },
                  maxLines: 5,
                  minLines: 1,
                  cursorColor: colors.primary,
                  style: AppFonts.fontsGeneral.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Ask about places, food, or trip ideas...",
                    hintStyle: AppFonts.fontsGeneral.copyWith(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Obx(
                () => Material(
                  color: controller.isSending.value
                      ? colors.primary.withValues(alpha: 0.4)
                      : colors.primary,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: controller.isSending.value
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            controller.sendMessage();
                          },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primary,
                            colors.primary.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showImageSourceSheet(
  BuildContext context,
  AiScreenController controller,
) {
  final colors = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).brightness == Brightness.dark
              ? colors.primaryContainer
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Identify a place",
                      style: AppFonts.fontsSubTitle.copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Snap or upload a photo and I'll tell you what it is",
                    style: AppFonts.fontDescriptionsmall,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ImageSourceTile(
                icon: Icons.photo_camera_rounded,
                label: 'Take a photo',
                colors: colors,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.pickAndIdentifyImage(ImageSource.camera);
                },
              ),
              _ImageSourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from gallery',
                colors: colors,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.pickAndIdentifyImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
      title: Text(label, style: AppFonts.fontsGeneral.copyWith(fontSize: 15)),
    );
  }
}
