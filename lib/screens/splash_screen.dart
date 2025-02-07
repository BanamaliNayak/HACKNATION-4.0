import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Simulate initialization delay (e.g., for back-end connection or loading assets)
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Animated Text
            SizedBox(
              height: 100,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'Courier',
                ),
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    FadeAnimatedText('W.E.L.C.O.M.E'),
                    FadeAnimatedText('Initializing...'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Lottie Animation (replace with your Lottie URL or local asset)
            Lottie.asset(
              vision,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ],
        ),
      ),
    );
  }
}
