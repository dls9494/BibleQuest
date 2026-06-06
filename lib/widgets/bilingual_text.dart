import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class BilingualText extends StatelessWidget {
  final String englishText;
  final String teluguText;
  final TextStyle? englishStyle;
  final TextStyle? teluguStyle;
  final TextAlign? textAlign;

  const BilingualText({
    super.key,
    required this.englishText,
    this.teluguText = "",
    this.englishStyle,
    this.teluguStyle,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final mode = provider.contentMode;

    // Fallback if Telugu text is empty
    if (teluguText.isEmpty) {
      return Text(
        englishText,
        style: TextStyle(
          fontFamily: provider.englishFontFamily,
          height: provider.englishLineHeight,
        ).merge(englishStyle),
        textAlign: textAlign,
      );
    }

    switch (mode) {
      case ContentLanguageMode.english:
        return Text(
          englishText,
          style: TextStyle(
            fontFamily: provider.englishFontFamily,
            height: provider.englishLineHeight,
          ).merge(englishStyle),
          textAlign: textAlign,
        );
      case ContentLanguageMode.telugu:
        return Text(
          teluguText,
          style: TextStyle(
            fontFamily: provider.teluguFontFamily,
            height: provider.teluguLineHeight,
          ).merge(teluguStyle),
          textAlign: textAlign,
        );
      case ContentLanguageMode.bilingual:
        return Column(
          crossAxisAlignment: textAlign == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teluguText,
              style: TextStyle(
                fontFamily: provider.teluguFontFamily,
                height: provider.teluguLineHeight,
              ).merge(teluguStyle),
              textAlign: textAlign,
            ),
            const SizedBox(height: 4),
            Text(
              englishText,
              style: TextStyle(
                fontFamily: provider.englishFontFamily,
                fontSize: (englishStyle?.fontSize ?? 14) * 0.85,
                color: Colors.grey,
                height: provider.englishLineHeight,
              ).merge(englishStyle),
              textAlign: textAlign,
            ),
          ],
        );
    }
  }
}
