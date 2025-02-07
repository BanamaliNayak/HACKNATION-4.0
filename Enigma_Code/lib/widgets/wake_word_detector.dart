import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WakeWordDetector {
  final VoidCallback onWakeWordDetected;
  final String wakeWord;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  WakeWordDetector({
    required this.onWakeWordDetected,
    this.wakeWord = "hey vision", // Change this to your desired wake word.
  });

  /// Initializes the speech recognition engine.
  Future<void> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint("WakeWord Speech status: $status"),
      onError: (error) => debugPrint("WakeWord Speech error: $error"),
    );
    if (available) {
      startListening();
    } else {
      debugPrint("Speech recognition for wake word not available.");
    }
  }

  /// Starts listening for speech and checks for the wake word.
  void startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          final recognizedText = result.recognizedWords.toLowerCase();
          debugPrint("WakeWord recognized: $recognizedText");
          // If the wake word is detected anywhere in the recognized words,
          // trigger the callback.
          if (recognizedText.contains(wakeWord.toLowerCase())) {
            onWakeWordDetected();
            // Do NOT stop listening here because we want continuous detection.
            // The HomePage will pause this detector while processing a command.
          }
        },
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
      );
      _isListening = true;
    }
  }

  /// Stops the speech listener.
  void stopListening() {
    _speech.stop();
    _isListening = false;
  }

  /// Disposes of the speech recognition engine.
  void dispose() {
    stopListening();
  }
}
