import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';

class AnimatedSplash extends StatefulWidget {
  final Future<void> Function() onComplete;
  final Widget next;

  const AnimatedSplash({super.key, required this.onComplete, required this.next});

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scaleIn;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
    );

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _runAuthCheck();
  }

  Future<void> _runAuthCheck() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 2000));
    final authCheck = widget.onComplete();
    await Future.wait([minDelay, authCheck]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: widget.next),
      ),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scaleIn,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Transform.scale(scale: _pulse.value, child: child),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text('Sarah', style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text('Find home, together', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
