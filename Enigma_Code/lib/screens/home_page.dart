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
import 'camera_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMicActive = false;

  // Holds any assistant response text.
  String _assistantResponse = "";

  // TTS engine instance.
  final FlutterTts _flutterTts = FlutterTts();

  // Speech recognition instance.
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _command = "";

  // Wake word detector instance.
  WakeWordDetector? _wakeWordDetector;

  @override
  void initState() {
    super.initState();
    // Configure TTS.
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    // Initialize the speech recognizer.
    _speechToText = stt.SpeechToText();
    // Initialize wake word detector.
    _initializeWakeWordDetector();
  }

  Future<void> _initializeWakeWordDetector() async {
    _wakeWordDetector =
        WakeWordDetector(onWakeWordDetected: _onWakeWordDetected);
    await _wakeWordDetector!.initialize();
    _wakeWordDetector?.startListening();
  }

  @override
  void dispose() {
    _wakeWordDetector?.dispose();
    _speechToText.stop();
    super.dispose();
  }

  /// Called when the wake word is detected.
  void _onWakeWordDetected() {
    debugPrint("Wake word detected!");
    _wakeWordDetector?.stopListening();
    setState(() {
      _assistantResponse = "How can I assist you?";
    });
    _flutterTts.speak("How can I assist you?");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _assistantResponse = "";
        _isMicActive = true;
      });
      _startListeningForCommand();
    });
  }

  /// Starts continuous listening for the user's command.
  Future<void> _startListeningForCommand() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint("Speech status: $status"),
      onError: (error) => debugPrint("Speech error: $error"),
    );
    if (available) {
      setState(() {
        _isListening = true;
        _isMicActive = true;
        _command = "";
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _command = result.recognizedWords;
          });
          debugPrint("Command recognized: $_command");
          if (result.finalResult) {
            _speechToText.stop();
            setState(() {
              _isListening = false;
              _isMicActive = false;
            });
            _callVoiceCommand(_command);
            Future.delayed(const Duration(seconds: 1), () {
              _wakeWordDetector?.startListening();
            });
          }
        },
      );
    } else {
      debugPrint("Speech recognition unavailable or permission denied.");
      _wakeWordDetector?.startListening();
    }
  }

  /// Stops the current listening session and resets the mic UI.
  void _cancelCommandCapture() {
    if (_isListening) {
      _speechToText.stop();
    }
    setState(() {
      _isListening = false;
      _isMicActive = false;
    });
    _wakeWordDetector?.startListening();
  }

  /// Processes the recognized command by matching keywords and calling the corresponding API or local function.
  void _callVoiceCommand(String command) async {
    debugPrint("Processing command: $command");
    String lowerCommand = command.toLowerCase();
    String response = "";
    try {
      if (lowerCommand.contains("coin")) {
        // Instead of sending a text command, open the camera to capture an image.
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CameraScreen()));
        return;
      } else if (lowerCommand.contains("object")) {
        response = await HttpService.callObjectDetectionAPI(command);
      } else if (lowerCommand.contains("currency")) {
        response = await HttpService.callCurrencyDetectionAPI(command);
      } else if (lowerCommand.contains("weather")) {
        response = await HttpService.callWeatherAPI(command);
      } else if (lowerCommand.contains("date")) {
        DateTime now = DateTime.now();
        String month = now.month.toString();
        String day = now.day.toString();
        String year = now.year.toString().substring(2); // two-digit year
        response = "Today's date is $month/$day/$year.";
      } else if (lowerCommand.contains("time")) {
        DateTime now = DateTime.now();
        String minute = now.minute < 10 ? "0${now.minute}" : "${now.minute}";
        response = "The current time is ${now.hour}:$minute.";
      } else {
        response =
            "Command not recognized. Please say coin, object, currency, weather, date, or time.";
      }
      debugPrint("Response: $response");
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
          const ParticleAnimationWidget(),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isMicActive
                        ? Lottie.asset(
                            wave,
                            width: 350,
                            height: 350,
                            fit: BoxFit.cover,
                            repeat: true,
                          )
                        : SizedBox(
                            height: 100,
                            width: 100,
                            child: FloatingActionButton(
                              onPressed: () {
                                _onWakeWordDetected();
                              },
                              shape: const CircleBorder(),
                              child: Image.asset(mic),
                            ),
                          ),
                    const SizedBox(height: 20),
                    _isListening
                        ? ElevatedButton(
                            onPressed: _cancelCommandCapture,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              "Stop Listening",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 40,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'Courier',
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            FadeAnimatedText('SAY THE WAKE WORD TO ACTIVATE'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
