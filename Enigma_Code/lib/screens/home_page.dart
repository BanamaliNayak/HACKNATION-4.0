import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../constants/animation.dart';
import '../constants/icons.dart';
import '../services/http_service.dart';
import '../widgets/particle_animation.dart';
import '../widgets/wake_word_detector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Whether the mic button animation (command capture) is active.
  bool _isMicActive = false;
  // Holds the assistant's response to display.
  String _assistantResponse = "";
  // TTS engine instance.
  final FlutterTts _flutterTts = FlutterTts();
  // Wake word detector instance.
  WakeWordDetector? _wakeWordDetector;

  // Speech recognition instance to capture the user's command.
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _command = "";

  @override
  void initState() {
    super.initState();
    // Configure TTS.
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);

    // Initialize the wake word detector.
    _initializeWakeWordDetector();

    // Initialize the speech recognizer for command capture.
    _speechToText = stt.SpeechToText();
  }

  Future<void> _initializeWakeWordDetector() async {
    _wakeWordDetector = WakeWordDetector(onWakeWordDetected: _onWakeWordDetected);
    await _wakeWordDetector!.initialize();
  }

  @override
  void dispose() {
    _wakeWordDetector?.dispose();
    _speechToText.stop();
    super.dispose();
  }

  /// Called when the wake word is detected or the mic button is tapped.
  void _onWakeWordDetected() {
    debugPrint("Wake word detected or mic button pressed: vision");

    // Pause the continuous wake word detection so that the microphone
    // can be used to capture the user's command.
    _wakeWordDetector?.stopListening();

    setState(() {
      _assistantResponse = "How can I assist you?";
    });
    // Speak the assistant response.
    _flutterTts.speak("How can I assist you?");

    // After a brief delay, clear the message, show the wave animation,
    // and start listening for the user's command.
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _assistantResponse = "";
        _isMicActive = true;
      });
      _startListeningForCommand();
    });
  }

  /// Starts listening to capture the user's spoken command.
  Future<void> _startListeningForCommand() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("Command Speech status: $status"),
      onError: (error) => debugPrint("Command Speech error: $error"),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _command = "";
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _command = result.recognizedWords;
          });
          debugPrint("Command recognized: $_command");
          if (result.finalResult) {
            // Stop listening and deactivate the wave animation.
            _speechToText.stop();
            setState(() {
              _isListening = false;
              _isMicActive = false;
            });
            // Process the command.
            _callVoiceCommand(_command);
            // Restart wake word detection.
            _wakeWordDetector?.startListening();
          }
        },
      );
    } else {
      debugPrint("Speech recognition for command unavailable or permission denied.");
      // If command capture is not available, resume wake word detection.
      _wakeWordDetector?.startListening();
    }
  }

  /// Cancels command capture and resumes wake word detection.
  void _cancelCommandCapture() {
    if (_isListening) {
      _speechToText.stop();
    }
    setState(() {
      _isListening = false;
      _isMicActive = false;
    });
    // Resume wake word detection.
    _wakeWordDetector?.startListening();
  }

  /// Calls the HTTP service with the recognized command and speaks the result.
  void _callVoiceCommand(String command) async {
    try {
      String response = await HttpService.callVoiceCommandAPI(command);
      debugPrint("API result: $response");
      _flutterTts.speak(response);
    } catch (e) {
      debugPrint("Error calling API: $e");
      _flutterTts.speak("Sorry, there was an error processing your request.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Your animated particle background.
          const ParticleAnimationWidget(),
          // Positioned widget to display the assistant's response at the top.
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: _assistantResponse.isNotEmpty
                  ? Text(
                _assistantResponse,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : Container(),
            ),
          ),
          // Custom mic icon or wave animation at the bottom center.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                // Tapping: if wave (command capture active) then cancel capture;
                // otherwise, start command capture.
                child: GestureDetector(
                  onTap: _isMicActive ? _cancelCommandCapture : _onWakeWordDetected,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isMicActive
                          ? Center(
                        child: Lottie.asset(
                          wave, // Wave animation asset for active command capture.
                          width: 350,
                          height: 350,
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.only(bottom: 45.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: FloatingActionButton(
                                onPressed: _onWakeWordDetected,
                                shape: const CircleBorder(),
                                child: Image.asset(mic),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontFamily: 'Courier',
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      FadeAnimatedText(
                                        'PRESS TO SPEAK WITH THE VOICE ASSISTANT',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
