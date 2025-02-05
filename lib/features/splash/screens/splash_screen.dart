// ignore_for_file: deprecated_member_use

import 'package:coded_gp/core/config/theme/app_colors.dart';
import 'package:coded_gp/features/splash/controllers/splash_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeanimation;
  late Animation<double> _scaleanimation;
  late Animation<double> _slideanimation;
  late Animation<double> _rotateanimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final route = await SplashController.to.determineInitialRoute();
    Get.offAllNamed(route);
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeanimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleanimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _slideanimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _rotateanimation = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF09122C) : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => _buildAnimatedContent(isDark),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(bool isDark) {
    return Transform.translate(
      offset: Offset(0, _slideanimation.value),
      child: Transform.rotate(
        angle: _rotateanimation.value,
        child: Transform.scale(
          scale: _scaleanimation.value,
          child: FadeTransition(
            opacity: _fadeanimation,
            child: _buildSplashContent(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashContent(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogoContainer(),
        const SizedBox(height: 8),
        _buildSubtitle(isDark),
      ],
    );
  }

  Widget _buildLogoContainer() {
    return Image.asset(
      'assets/images/splash/CodedLogo.png',
      width: 200,
      height: 100,
      fit: BoxFit.contain,
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      'Your AI-Powered University Assistant – Smart, Fast, and Ready to Support Your Campus Life!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color:
            (isDark ? Colors.white : AppColors.kTextDarkColor).withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }
}
