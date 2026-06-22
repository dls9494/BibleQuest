import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/bible/providers/bible_providers.dart';
import '../services/bible_service.dart';
import '../constants/theme.dart';
import 'package:share_plus/share_plus.dart';

class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyVerseAsync = ref.watch(dailyVerseProvider);

    return dailyVerseAsync.when(
      data: (dailyVerse) {
        if (dailyVerse == null) return const SizedBox.shrink();

        final bookMeta = BibleService.findBookByName(dailyVerse.bookName);
        final displayBookNameEn = bookMeta?.nameEn ?? dailyVerse.bookName;
        final displayBookNameTe = bookMeta?.nameTe ?? '';


        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.05), // Background: Gold 5%
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.4), // Border: Gold 40%
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.push(
                        '/bible/${dailyVerse.version}/${dailyVerse.bookName}/${dailyVerse.chapter}?verse=${dailyVerse.verse}',
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 32,
                                  height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.gold.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: AppTheme.gold.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.gold,
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: AppTheme.gold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "VERSE OF THE DAY • ",
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                          const TextSpan(
                                            text: "నేటి వాక్యము",
                                            style: TextStyle(
                                              fontFamily: 'Mandali',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                     RichText(
                                       text: TextSpan(
                                         style: const TextStyle(
                                           color: Colors.white,
                                           fontSize: 14,
                                           fontWeight: FontWeight.w600,
                                         ),
                                         children: [
                                           TextSpan(
                                             text: displayBookNameEn,
                                             style: const TextStyle(fontFamily: 'Outfit'),
                                           ),
                                           if (displayBookNameTe.isNotEmpty) ...[
                                             const TextSpan(
                                               text: ' (',
                                               style: TextStyle(fontFamily: 'Outfit'),
                                             ),
                                             TextSpan(
                                               text: displayBookNameTe,
                                               style: const TextStyle(fontFamily: 'Mandali'),
                                             ),
                                             const TextSpan(
                                               text: ')',
                                               style: TextStyle(fontFamily: 'Outfit'),
                                             ),
                                           ],
                                           TextSpan(
                                             text: ' ${dailyVerse.chapter}:${dailyVerse.verse}',
                                             style: const TextStyle(fontFamily: 'Outfit'),
                                           ),
                                         ],
                                       ),
                                     ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: AppTheme.gold, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  final bookMeta = BibleService.findBookByName(dailyVerse.bookName);
                                  final bookId = bookMeta?.id ?? dailyVerse.bookName.toLowerCase();
                                  
                                  final teluguMap = await BibleService.getChapter(bookId, dailyVerse.chapter, 'telugu_ov');
                                  final englishMap = await BibleService.getChapter(bookId, dailyVerse.chapter, 'kjv');
                                  
                                  final teluguText = teluguMap[dailyVerse.verse] ?? dailyVerse.text;
                                  final englishText = englishMap[dailyVerse.verse] ?? '';
                                  
                                  final displayBookNameEn = bookMeta?.nameEn ?? dailyVerse.bookName;
                                  final displayBookNameTe = bookMeta?.nameTe ?? '';
                                  final refString = displayBookNameTe.isNotEmpty
                                      ? '$displayBookNameEn ($displayBookNameTe) ${dailyVerse.chapter}:${dailyVerse.verse}'
                                      : '$displayBookNameEn ${dailyVerse.chapter}:${dailyVerse.verse}';
                                  
                                  final shareText = '$refString\n\n$teluguText\n\n$englishText\n\n— BibleQuest';
                                  await SharePlus.instance.share(ShareParams(text: shareText));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dailyVerse.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85), // Verse: White, 85% opacity
                              fontSize: 14,
                              height: 1.6,
                              fontFamily: 'Mandali',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
