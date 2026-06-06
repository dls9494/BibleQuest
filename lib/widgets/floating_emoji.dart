import 'package:flutter/material.dart';

class FloatingEmoji extends StatefulWidget {
  final String emoji;
  final Color color;
  const FloatingEmoji({super.key, required this.emoji, required this.color});
  
  @override
  State<FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<FloatingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    
    // In Flutter, SlideTransition translates the widget by a fraction of its size.
    // Since the emoji is rendered with a fontSize of 28, a translation of -2.5 translates it 
    // by approximately 80 logical pixels, creating the intended smooth float up effect.
    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _position,
      child: FadeTransition(
        opacity: _opacity,
        child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
