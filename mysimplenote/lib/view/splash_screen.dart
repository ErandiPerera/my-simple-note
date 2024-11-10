import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset(
          'assets/animation/Animation - 1730772266151.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
      nextScreen: HomeScreen(),
      duration: 5500,
      backgroundColor: Color(0xFFFFF9AC),
      splashIconSize: 600,
    );
  }
}

