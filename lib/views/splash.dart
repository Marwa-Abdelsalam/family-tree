import 'package:family_app_tree/feature/home_age/presentation/pages/landing_page.dart';
import 'package:family_app_tree/views/sign_in_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';

// Ensure this path is correct

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    final box = GetStorage();
    bool isLoggedIn = box.read("signedIn") ?? false;
    print("From splash login: $isLoggedIn");
    Timer(Duration(seconds: 15), () => isLoggedIn ?Get.offAll(LandingPage()): Get.offAll(SignInScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE8D0B4),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
