import 'package:flutter/material.dart';
import 'package:vision/screens/home_page.dart';
import 'package:vision/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/' : (context) => const SplashScreen(),
        '/home' : (context) => const HomePage(),
      },
    );
  }
}
