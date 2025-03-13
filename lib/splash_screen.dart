import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/authentication/login_screen.dart';
import 'package:lottie/lottie.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset('assets/animation.json'),
      ),
      nextScreen: LoginScreen(),
      splashIconSize: 300,
      backgroundColor: Colors.white,
      duration: 4000,
    );
  }
}
