import 'package:flutter/foundation.dart';

class SpeechHelper {
  static final SpeechHelper _instance = SpeechHelper._internal();
  factory SpeechHelper() => _instance;
  SpeechHelper._internal();

  bool isSpeaking = false;
  VoidCallback? onSpeechStateChanged;

  void speak(String text, {double rate = 1.0, VoidCallback? onComplete}) {
    stop();

    // Clean markdown characters from text for natural speech
    final cleanText = text
        .replaceAll(RegExp(r'[*#_`~>•]'), '')
        .replaceAll(RegExp(r'\n+'), '. ')
        .trim();

    if (cleanText.isEmpty) return;

    isSpeaking = true;
    onSpeechStateChanged?.call();

    final durationMs = (cleanText.length * 55).clamp(1800, 12000);
    Future.delayed(Duration(milliseconds: durationMs), () {
      if (isSpeaking) {
        isSpeaking = false;
        onSpeechStateChanged?.call();
        onComplete?.call();
      }
    });
  }

  void stop() {
    isSpeaking = false;
    onSpeechStateChanged?.call();
  }
}
