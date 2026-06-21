import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VerseShareCard extends StatelessWidget {
  final String bookNameEn;
  final String bookNameTe;
  final int chapter;
  final int verse;
  final String textTe;
  final String textEn;
  final String mode; // 'te' | 'kjv' | 'nhv' | 'bilingual'

  const VerseShareCard({
    super.key,
    required this.bookNameEn,
    required this.bookNameTe,
    required this.chapter,
    required this.verse,
    required this.textTe,
    required this.textEn,
    required this.mode,
  });

  static Future<void> shareVerse({
    required BuildContext context,
    required String bookNameEn,
    required String bookNameTe,
    required int chapter,
    required int verse,
    required String textTe,
    required String textEn,
    required String mode,
  }) async {
    final GlobalKey boundaryKey = GlobalKey();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(milliseconds: 600), () async {
          try {
            RenderRepaintBoundary? boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
            if (boundary != null) {
              ui.Image image = await boundary.toImage(pixelRatio: 3.0);
              ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              if (byteData != null) {
                final Uint8List pngBytes = byteData.buffer.asUint8List();
                final tempDir = await getTemporaryDirectory();
                final file = await File('${tempDir.path}/verse_${bookNameEn}_${chapter}_$verse.png').create();
                await file.writeAsBytes(pngBytes);
                
                if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }

                String shareText = 'Check out this verse from the Telugu Bible Quiz app! ✝\n\n';
                if (mode == 'te') {
                  shareText += '$bookNameTe $chapter:$verse - $textTe';
                } else if (mode == 'kjv' || mode == 'nhv') {
                  shareText += '$bookNameEn $chapter:$verse - $textEn';
                } else {
                  shareText += '$bookNameTe / $bookNameEn $chapter:$verse\n\n$textTe\n\n$textEn';
                }

                await SharePlus.instance.share(
                  ShareParams(
                    text: shareText,
                    files: [XFile(file.path)],
                  ),
                );
              }
            } else {
              if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error sharing verse: $e");
            }
            if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: boundaryKey,
                child: VerseShareCard(
                  bookNameEn: bookNameEn,
                  bookNameTe: bookNameTe,
                  chapter: chapter,
                  verse: verse,
                  textTe: textTe,
                  textEn: textEn,
                  mode: mode,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Creating share card...",
                style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTe = mode == 'te' || mode == 'bilingual';
    final showEn = mode == 'kjv' || mode == 'nhv' || mode == 'bilingual';
    final displayTitleTe = '$bookNameTe $chapter:$verse';
    final displayTitleEn = '$bookNameEn $chapter:$verse';

    return Container(
      width: 320,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2F),
            Color(0xFF2D2A4A),
            Color(0xFF1B1B3A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Header Icon
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "✝",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title/Reference
          Text(
            mode == 'te'
                ? displayTitleTe
                : mode == 'bilingual'
                    ? '$displayTitleTe • $displayTitleEn'
                    : displayTitleEn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 16),
          // Separator
          Container(
            height: 1,
            width: 80,
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          // Verse Text
          if (showTe)
            Padding(
              padding: EdgeInsets.only(bottom: showEn ? 12.0 : 0),
              child: Text(
                textTe,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'NotoSansTelugu',
                ),
              ),
            ),
          if (showTe && showEn)
            Container(
              height: 1,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white.withValues(alpha: 0.1),
            ),
          if (showEn)
            Text(
              textEn,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: showTe ? Colors.white70 : Colors.white,
                fontSize: 15,
                height: 1.5,
                fontStyle: FontStyle.italic,
                fontFamily: 'Outfit',
              ),
            ),
          const SizedBox(height: 24),
          // Footer
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz,
                size: 14,
                color: Color(0xFF38BDF8),
              ),
              const SizedBox(width: 6),
              Text(
                "Telugu Bible Quiz App",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
