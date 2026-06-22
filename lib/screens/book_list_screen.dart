import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:go_router/go_router.dart';
import '../providers/locale_provider.dart';
import '../widgets/gradient_background.dart';
import '../services/bible_service.dart';
import '../theme/text_styles.dart';

// ── Book group definitions ────────────────────────────────────────────────────
class _BookGroup {
  final String label;
  final List<String> bookIds;
  const _BookGroup(this.label, this.bookIds);
}

const _otGroups = [
  _BookGroup('LAW',             ['genesis','exodus','leviticus','numbers','deuteronomy']),
  _BookGroup('HISTORY',         ['joshua','judges','ruth','1samuel','2samuel','1kings','2kings','1chronicles','2chronicles','ezra','nehemiah','esther']),
  _BookGroup('POETRY',          ['job','psalms','proverbs','ecclesiastes','songofsolomon']),
  _BookGroup('MAJOR PROPHETS',  ['isaiah','jeremiah','lamentations','ezekiel','daniel']),
  _BookGroup('MINOR PROPHETS',  ['hosea','joel','amos','obadiah','jonah','micah','nahum','habakkuk','zephaniah','haggai','zechariah','malachi']),
];

const _ntGroups = [
  _BookGroup('GOSPELS',     ['matthew','mark','luke','john']),
  _BookGroup('ACTS',        ['acts']),
  _BookGroup('EPISTLES',    ['romans','1corinthians','2corinthians','galatians','ephesians','philippians','colossians','1thessalonians','2thessalonians','1timothy','2timothy','titus','philemon','hebrews','james','1peter','2peter','1john','2john','3john','jude']),
  _BookGroup('REVELATION',  ['revelation']),
];

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = p.Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    const appBarTextColor = Colors.white;

    // P5 FIX: Use BibleService static metadata — always 39 OT, 27 NT. No async needed.
    final otBooks = BibleService.getOTBooks();
    final ntBooks = BibleService.getNTBooks();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Bible Books • గ్రంథములు',
            style: TextStyle(
              color: appBarTextColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: appBarTextColor),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            _buildVersionSelector(context, localeProvider, isDark, textColor, appBarTextColor),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Builder(
                builder: (context) {
                  return TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    indicator: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: const [
                      Tab(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('OLD TESTAMENT'),
                            SizedBox(height: 2),
                            Opacity(
                              opacity: 0.7,
                              child: Text('పాత నిబంధన', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('NEW TESTAMENT'),
                            SizedBox(height: 2),
                            Opacity(
                              opacity: 0.7,
                              child: Text('కొత్త నిబంధన', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        body: GradientBackground(
          child: SafeArea(
            child: TabBarView(
              children: [
                _buildGroupedList(context, otBooks, _otGroups, localeProvider, isDark, textColor),
                _buildGroupedList(context, ntBooks, _ntGroups, localeProvider, isDark, textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── P1 FIX: Two separate dropdowns, each always has a valid value ─────────
  Widget _buildVersionSelector(BuildContext context, LocaleProvider lp, bool isDark, Color textColor, Color appBarTextColor) {
    final canvasColor = isDark ? const Color(0xFF1E1E30) : Colors.white;

    final teDropdown = Theme(
      data: Theme.of(context).copyWith(canvasColor: canvasColor),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: lp.activeTeluguVersion,
          icon: Icon(Icons.arrow_drop_down, color: appBarTextColor, size: 16),
          style: TextStyle(color: appBarTextColor, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Outfit'),
          onChanged: (v) { if (v != null) lp.setTeluguVersion(v); },
          items: [
            DropdownMenuItem(value: 'telugu_ov',   child: Text('OV',   style: TextStyle(color: textColor))),
            DropdownMenuItem(value: 'telugu_irv',  child: Text('IRV',  style: TextStyle(color: textColor))),
            DropdownMenuItem(value: 'telugu_wbtc', child: Text('WBTC', style: TextStyle(color: textColor))),
          ],
        ),
      ),
    );

    final enDropdown = Theme(
      data: Theme.of(context).copyWith(canvasColor: canvasColor),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: lp.activeEnglishVersion,
          icon: Icon(Icons.arrow_drop_down, color: appBarTextColor, size: 16),
          style: TextStyle(color: appBarTextColor, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Outfit'),
          onChanged: (v) { if (v != null) lp.setEnglishVersion(v); },
          items: [
            DropdownMenuItem(value: 'kjv',   child: Text('KJV',   style: TextStyle(color: textColor))),
            DropdownMenuItem(value: 'asv',   child: Text('ASV',   style: TextStyle(color: textColor))),
            DropdownMenuItem(value: 'web',   child: Text('WEB',   style: TextStyle(color: textColor))),
            DropdownMenuItem(value: 'darby', child: Text('Darby', style: TextStyle(color: textColor))),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          teDropdown,
          Text(' / ', style: TextStyle(color: appBarTextColor.withValues(alpha: 0.4), fontSize: 11)),
          enDropdown,
        ],
      ),
    );
  }

  // ── P6: 2-column grid with group section headers ──────────────────────────
  Widget _buildGroupedList(
    BuildContext context,
    List<BibleBook> books,
    List<_BookGroup> groups,
    LocaleProvider lp,
    bool isDark,
    Color textColor,
  ) {
    final rows = <Widget>[const SizedBox(height: 4)];

    bool isFirst = true;
    for (final group in groups) {
      rows.add(_buildGroupHeader(group.label, isDark, isFirst: isFirst));
      isFirst = false;

      // Gather books for this group in display order
      final groupBooks = group.bookIds
          .map((id) => books.firstWhere((b) => b.id == id, orElse: () => BibleBook(id: id, nameEn: id, nameTe: '', chapters: 1, testament: 'OT')))
          .toList();

      // 2-column pairs
      for (int i = 0; i < groupBooks.length; i += 2) {
        final left = groupBooks[i];
        final right = i + 1 < groupBooks.length ? groupBooks[i + 1] : null;
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              children: [
                Expanded(child: _buildBookCard(context, left, lp, isDark, textColor)),
                const SizedBox(width: 6),
                Expanded(
                  child: right != null
                      ? _buildBookCard(context, right, lp, isDark, textColor)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      }
      rows.add(const SizedBox(height: 6));
    }

    rows.add(const SizedBox(height: 4));
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(vertical: 8), children: rows);
  }

  Widget _buildGroupHeader(String label, bool isDark, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, isFirst ? 4 : 8, 14, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              color: isDark ? const Color(0xFFD4A574) : const Color(0xFF8B6914),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Divider(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, BibleBook book, LocaleProvider lp, bool isDark, Color textColor) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFD4A574).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
          highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.05),
          onTap: () => context.push('/bible/${lp.activeTeluguVersion}/${book.nameEn}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.nameEn,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Outfit',
                    letterSpacing: 0.3,
                  ),
                ),
                if (book.nameTe.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.nameTe,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      fontFamily: 'NotoSansTelugu',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
