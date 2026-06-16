import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';

class MiracleBoxDialog extends StatefulWidget {
  const MiracleBoxDialog({super.key});

  @override
  State<MiracleBoxDialog> createState() => _MiracleBoxDialogState();
}

class _MiracleBoxDialogState extends State<MiracleBoxDialog> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late int _xpReward;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    // Random reward pool: +50 XP or +100 XP
    final rewards = [50, 100];
    _xpReward = rewards[Random().nextInt(rewards.length)];

    _animController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final userProvider = context.read<UserDataProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Content Card
          ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1035), const Color(0xFF311060)]
                        : [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.amber,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    // Treasure Chest Icon/Widget
                    GestureDetector(
                      onTap: () {
                        if (!_isOpen) {
                          setState(() {
                            _isOpen = true;
                          });
                          _confettiController.play();
                        }
                      },
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isOpen
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const Icon(
                          Icons.card_giftcard_rounded,
                          size: 100,
                          color: Colors.amber,
                        ),
                        secondChild: const Icon(
                          Icons.card_membership_rounded, // Looks like open box
                          size: 100,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isOpen ? "Miracle Box Opened! 🎉" : "Streak Miracle Box! 🎁",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isOpen
                          ? "You found +$_xpReward XP! 🎁\nGlory to God!"
                          : "You hit a 7-day streak milestone! Open the box to claim your miracle reward.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (!_isOpen) {
                          setState(() {
                            _isOpen = true;
                          });
                          _confettiController.play();
                        } else {
                          // Claim XP
                          userProvider.claimMiracleBox(_xpReward);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        _isOpen ? "Claim Reward" : "Open Box",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Confetti overlay
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.yellow,
                Colors.orange,
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.blue,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
