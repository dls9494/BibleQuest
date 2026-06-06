import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String> onChanged;

  const OtpInputWidget({
    super.key,
    this.length = 6,
    required this.onCompleted,
    required this.onChanged,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _code;

  @override
  void initState() {
    super.initState();
    _code = List.filled(widget.length, "");
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isEmpty) {
      _code[index] = "";
      widget.onChanged(_code.join());
      return;
    }

    if (value.length > 1) {
      final numbersOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (numbersOnly.isNotEmpty) {
        _handlePaste(numbersOnly);
      }
      return;
    }

    _code[index] = value;
    final codeStr = _code.join();
    widget.onChanged(codeStr);

    if (codeStr.length == widget.length) {
      widget.onCompleted(codeStr);
    }

    // Move to next focus
    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _handlePaste(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;
    
    final lengthToPaste = min(cleanText.length, widget.length);
    for (int i = 0; i < widget.length; i++) {
      if (i < lengthToPaste) {
        _code[i] = cleanText[i];
        _controllers[i].text = cleanText[i];
      } else {
        _code[i] = "";
        _controllers[i].text = "";
      }
    }
    
    final codeStr = _code.join();
    widget.onChanged(codeStr);
    
    if (codeStr.length == widget.length) {
      widget.onCompleted(codeStr);
      _focusNodes[widget.length - 1].requestFocus();
    } else {
      _focusNodes[codeStr.length].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
          for (int i = 0; i < widget.length; i++) {
            if (_focusNodes[i].hasFocus) {
              if (_controllers[i].text.isEmpty && i > 0) {
                _focusNodes[i - 1].requestFocus();
                _controllers[i - 1].text = "";
                _code[i - 1] = "";
                widget.onChanged(_code.join());
              }
              break;
            }
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (index) {
          return SizedBox(
            width: 48,
            height: 48,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focusNodes[index].hasFocus
                      ? const Color(0xFFF7BC64) // Gold border when active
                      : Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: "",
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _onChanged(val, index),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
