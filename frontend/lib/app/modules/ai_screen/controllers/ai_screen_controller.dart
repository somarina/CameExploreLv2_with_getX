import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/services/ai_services.dart';
import '../models/ai_chat_message.dart';

class AiScreenController extends GetxController {
  final AiServices service = AiServices();

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  RxList<AiChatMessage> messages = <AiChatMessage>[].obs;
  RxBool isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    messages.add(
      AiChatMessage(
        sender: AiSender.assistant,
        text:
            "Sua s'dei! I'm your CamExplore travel assistant. Ask me about places, provinces, or trip ideas around Cambodia.",
      ),
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  List<Map<String, String>> _buildHistory() {
    // Skip the initial greeting and cap history so the payload stays small.
    final chatOnly = messages.where((m) => !m.isError).toList();
    final recent = chatOnly.length > 12
        ? chatOnly.sublist(chatOnly.length - 12)
        : chatOnly;

    return recent
        .map(
          (m) => {
            "role": m.sender == AiSender.user ? "user" : "model",
            "text": m.text,
          },
        )
        .toList();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Best-effort device location so the assistant can answer "near me" /
  // "current location" questions. Returns null on any denial/failure —
  // location is just extra context, never required to send a message.
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint("AI chat location error: $e");
      return null;
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isSending.value) return;

    final history = _buildHistory();

    messages.add(AiChatMessage(sender: AiSender.user, text: text));
    textController.clear();
    isSending(true);
    _scrollToBottom();

    try {
      final position = await _getCurrentLocation();

      final response = await service.chat(
        message: text,
        history: history,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (response == null) {
        messages.add(
          AiChatMessage(
            sender: AiSender.assistant,
            text: "Couldn't reach the AI assistant. Please check your connection and try again.",
            isError: true,
          ),
        );
        return;
      }

      if (response["result"] == true) {
        final data = response["data"];
        final reply = data["reply"]?.toString() ?? "";
        final places = (data["suggested_places"] as List? ?? [])
            .map((e) => AiSuggestedPlace.fromJson(e))
            .toList();

        messages.add(
          AiChatMessage(
            sender: AiSender.assistant,
            text: reply,
            suggestedPlaces: places,
          ),
        );
      } else {
        messages.add(
          AiChatMessage(
            sender: AiSender.assistant,
            text: response["message"]?.toString() ?? "Something went wrong. Please try again.",
            isError: true,
          ),
        );
      }
    } finally {
      isSending(false);
      _scrollToBottom();
    }
  }

  Future<void> pickAndIdentifyImage(ImageSource source) async {
    if (isSending.value) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    final imageFile = File(picked.path);
    final caption = textController.text.trim();
    textController.clear();

    messages.add(
      AiChatMessage(
        sender: AiSender.user,
        text: caption.isEmpty ? "What place is this?" : caption,
        localImagePath: imageFile.path,
      ),
    );
    isSending(true);
    _scrollToBottom();

    try {
      final position = await _getCurrentLocation();

      final response = await service.identifyImage(
        image: imageFile,
        message: caption,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (response == null) {
        messages.add(
          AiChatMessage(
            sender: AiSender.assistant,
            text: "Couldn't reach the AI assistant. Please check your connection and try again.",
            isError: true,
          ),
        );
        return;
      }

      if (response["result"] == true) {
        final data = response["data"];
        final reply = data["reply"]?.toString() ?? "";
        final places = (data["suggested_places"] as List? ?? [])
            .map((e) => AiSuggestedPlace.fromJson(e))
            .toList();

        messages.add(
          AiChatMessage(
            sender: AiSender.assistant,
            text: reply,
            suggestedPlaces: places,
            googleMapsUrl: data["google_maps_url"]?.toString(),
          ),
        );
      } else {
        messages.add(
          AiChatMessage(
            sender: AiSender.assistant,
            text: response["message"]?.toString() ?? "Something went wrong. Please try again.",
            isError: true,
          ),
        );
      }
    } finally {
      isSending(false);
      _scrollToBottom();
    }
  }
}