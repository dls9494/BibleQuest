import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui';
import '../models/bible.dart';
import '../services/bible_service.dart';
import '../providers/user_data_provider.dart';
import '../widgets/verse_share_card.dart';
import '../widgets/gradient_background.dart';
import 'package:audio_service/audio_service.dart' as as_pkg;
import "../providers/theme_provider.dart";
import "../constants/theme.dart";
import '../services/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/verse_labels.dart';

class BibleScreen extends StatefulWidget {
  final String? initialBook;
  final int? initialChapter;
  final int? initialVerse;

  const BibleScreen({
    super.key,
    this.initialBook,
    this.initialChapter,
    this.initialVerse,
  });

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  String _selectedBookId = 'genesis';
  int _selectedChapter = 1;
  String _selectedLanguage = 'telugu';
  String _activeEnglishVersion = 'english_kjv';
  String _activeTeluguVersion = 'telugu_ov';
  bool _isBilingual = true;
  bool _barsVisible = true;
  double _dragStartX = 0.0;
  bool _isSwipeTriggered = false;
  List<BibleBook>? _allBooks;
  final ValueNotifier<bool> _showSelectorNotifier = ValueNotifier<bool>(false);
  String _tempSelectedBookId = 'genesis';
  String _testamentFilter = 'ALL';
  List<Map<String, dynamic>> _chapterNotes = [];
  Map<int, String> _labelledVerses = {};
  Set<int> _favoritedVerses = {};
  StreamSubscription? _notesSubscription;
  bool _showLabels = false;

  // Font size & style (persisted)
  double _fontSize = 18.0;
  static const double _fontSizeMin = 14.0;
  static const double _fontSizeMax = 28.0;
  String _fontStyle = 'normal'; // 'normal' | 'bold' | 'italic'

  List<BibleVerse> _verses = [];
  bool _isLoading = false;

  // Search, highlighting, and scroll target states
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _searchQuery = '';
  bool _searchAllBooks = false;
  List<SearchVerse> _searchResults = [];
  List<SearchVerse> _searchIndex = [];
  bool _isIndexing = false;
  Timer? _debounceTimer;

  int? _targetVerse;
  int? _selectedVerse;
  int? _activeLabelingVerse;
  StreamSubscription<as_pkg.MediaItem?>? _mediaItemSubscription;

  @override
  void initState() {
    super.initState();
    _tempSelectedBookId = _selectedBookId;
    if (widget.initialBook != null) {
      _selectedBookId = widget.initialBook!;
      _tempSelectedBookId = widget.initialBook!;
    }
    if (widget.initialChapter != null) {
      _selectedChapter = widget.initialChapter!;
    }
    if (widget.initialVerse != null) {
      _targetVerse = widget.initialVerse;
      _selectedVerse = widget.initialVerse;
    }

    // Listen for mediaItem changes to track playing verse for highlight only (no auto-scroll)
    _mediaItemSubscription = AudioService.instance.mediaItem.listen((mediaItem) {
      if (mounted) setState(() {});
    });

    _scrollController.addListener(_scrollListener);

    // Progressive asynchronous loading after the first frame mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _allBooks = BibleService.getBooks();
        _loadPreferences().then((_) {
          if (mounted) {
            _checkAndShowAudioBookmark();
            _loadVerses();
            _initSearchIndex();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _showSelectorNotifier.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_barsVisible) {
        setState(() {
          _barsVisible = false;
        });
      }
    } else if (direction == ScrollDirection.forward) {
      if (!_barsVisible) {
        setState(() {
          _barsVisible = true;
        });
      }
    }
  }

  void _startAudioPlayback({int startVerse = 1}) async {
    if (_verses.isEmpty) return;

    final playTelugu = _isBilingual || _selectedLanguage == 'telugu';
    final versesTexts = _verses.map((v) => playTelugu ? v.textTe : v.textKjv).toList();
    final lang = playTelugu ? 'te-IN' : 'en-US';
    final startIndex = _verses.indexWhere((v) => v.verse == startVerse);

    await AudioService.instance.playChapter(
      _selectedBookId,
      _selectedChapter,
      versesTexts,
      lang,
      startVerseIndex: startIndex >= 0 ? startIndex : 0,
    );
  }

  Future<void> _checkAndShowAudioBookmark() async {
    final playbackState = AudioService.instance.playbackState.value;
    if (playbackState.playing) return;

    final bookmark = await AudioService.instance.getSavedPosition();
    if (bookmark == null) return;

    final bookId = bookmark['bookId'] as String;
    final chapter = bookmark['chapter'] as int;
    final verseIndex = bookmark['verse'] as int;

    final book = BibleService.getBookById(bookId);
    if (book == null) return;

    final verseNum = verseIndex + 1;
    final bookName = _selectedLanguage == 'telugu' ? book.nameTe : book.nameEn;

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedLanguage == 'telugu'
              ? '$bookName $chapter:$verseNum నుండి తిరిగి వినడం ప్రారంభించాలా?'
              : 'Resume listening from $bookName $chapter:$verseNum?',
          style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: _selectedLanguage == 'telugu' ? 'ప్రారంభించు' : 'Resume',
          textColor: const Color(0xFFF7BC64),
          onPressed: () async {
            if (_selectedBookId != bookId || _selectedChapter != chapter) {
              setState(() {
                _selectedBookId = bookId;
                _selectedChapter = chapter;
              });
              await _loadVerses();
            }
            final isTelugu = _selectedLanguage == 'telugu';
            final versesTexts = _verses.map((v) => isTelugu ? v.textTe : v.textKjv).toList();
            final lang = isTelugu ? 'te-IN' : 'en-US';

            await AudioService.instance.playChapter(
              bookId,
              chapter,
              versesTexts,
              lang,
              startVerseIndex: verseIndex,
            );
            await AudioService.instance.clearSavedPosition();
          },
        ),
      ),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('bible_language') ?? 'telugu';
        _activeEnglishVersion = prefs.getString('bible_english_version') ?? 'english_kjv';
        _activeTeluguVersion = prefs.getString('bible_telugu_version') ?? 'telugu_ov';
        _isBilingual = prefs.getBool('bible_is_bilingual') ?? true;
        _showLabels = prefs.getBool('bible_show_labels') ?? false;
        _fontStyle = prefs.getString('bible_font_style') ?? 'normal';

        final savedFontSize = prefs.get('bible_font_size');
        if (savedFontSize is int) {
          _fontSize = savedFontSize.toDouble().clamp(_fontSizeMin, _fontSizeMax);
        } else if (savedFontSize is double) {
          _fontSize = savedFontSize.clamp(_fontSizeMin, _fontSizeMax);
        } else {
          _fontSize = 18.0; // Default font size = 18pt
        }
      });
    }
  }

  Future<void> _saveVersionPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bible_language', _selectedLanguage);
    await prefs.setString('bible_english_version', _activeEnglishVersion);
    await prefs.setString('bible_telugu_version', _activeTeluguVersion);
    await prefs.setBool('bible_is_bilingual', _isBilingual);
  }

  Future<void> _addRecentChapter(String bookId, int chapter) async {
    final ref = '$bookId:$chapter';
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList('bible_recent_chapters') ?? [];
    current.remove(ref);
    current.insert(0, ref);
    if (current.length > 10) {
      current.removeRange(10, current.length);
    }
    await prefs.setStringList('bible_recent_chapters', current);
  }

  Future<void> _initSearchIndex() async {
    setState(() => _isIndexing = true);
    try {
      final index = await BibleService.getSearchIndex();
      if (mounted) {
        setState(() {
          _searchIndex = index;
          _isIndexing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isIndexing = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = _searchIndex.where((v) {
      if (!_searchAllBooks && v.bookId != _selectedBookId) {
        return false;
      }
      return v.textKjv.toLowerCase().contains(lowerQuery) ||
             v.textNhv.toLowerCase().contains(lowerQuery) ||
             v.textTe.contains(query);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserDataProvider>(context, listen: true);
    if (userProvider.bibleBookId != null && userProvider.bibleChapter != null) {
      final book = BibleService.getBookById(userProvider.bibleBookId!);
      if (book != null) {
        setState(() {
          _selectedBookId = userProvider.bibleBookId!;
          _selectedChapter = userProvider.bibleChapter!;
          _targetVerse = userProvider.bibleVerse;
          if (_targetVerse != null) {
            _selectedVerse = _targetVerse!;
          } else {
            _selectedVerse = null;
          }
        });
        userProvider.clearBibleTarget();
        _loadVerses();
      }
    }
  }

  Future<void> _loadVerses() async {
    setState(() => _isLoading = true);
    try {
      final Map<int, String> englishMap = await BibleService.getChapter(_selectedBookId, _selectedChapter, _activeEnglishVersion);
      final Map<int, String> teluguMap = await BibleService.getChapter(_selectedBookId, _selectedChapter, _activeTeluguVersion);

      final allVerses = {...englishMap.keys, ...teluguMap.keys}.toList()..sort();
      final List<BibleVerse> verses = [];
      for (final v in allVerses) {
        verses.add(BibleVerse(
          chapter: _selectedChapter,
          verse: v,
          textTe: teluguMap[v] ?? 'ఈ వచనం త్వరలో అందుబాటులోకి వస్తుంది.',
          textKjv: englishMap[v] ?? 'This verse will be available soon.',
          textNhv: '',
        ));
      }

      setState(() {
        _verses = verses;
        _isLoading = false;
      });
      _addRecentChapter(_selectedBookId, _selectedChapter);

      // Cancel any existing notes subscription and listen to the new chapter notes
      await _notesSubscription?.cancel();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Fetch labelled and favorited verses for this chapter
        try {
          final labels = await FirebaseService.getChapterLabelledVerses(uid, _selectedBookId, _selectedChapter);
          final favoritesList = await FirebaseService.getChapterFavoritedVerses(uid, _selectedBookId, _selectedChapter);
          if (mounted) {
            setState(() {
              _labelledVerses = labels;
              _favoritedVerses = favoritesList.toSet();
            });
          }
        } catch (e) {
          // ignore: avoid_print
          print("Error loading labels/favorites: $e");
        }

        _notesSubscription = FirebaseService.getChapterNotes(uid, _selectedBookId, _selectedChapter).listen((notesList) {
          if (mounted) {
            setState(() {
              _chapterNotes = notesList;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _chapterNotes = [];
            _labelledVerses = {};
            _favoritedVerses = {};
          });
        }
      }

      if (_targetVerse != null) {
        final targetIndex = _verses.indexWhere((v) => v.verse == _targetVerse);
        if (targetIndex != -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToIndex(targetIndex);
            _targetVerse = null;
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error loading verses: $e");
      setState(() => _isLoading = false);
    }
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    final offset = (index * 95.0).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(offset);
  }

  void _changeBookAndChapter(String bookId, int chapter) {
    final book = BibleService.getBookById(bookId);
    if (book != null) {
      setState(() {
        _selectedBookId = bookId;
        _selectedChapter = chapter;
      });
      _loadVerses();
    }
  }

  void _navigateToNextChapter() {
    final book = BibleService.getBookById(_selectedBookId);
    if (book == null) return;
    if (_selectedChapter < book.chapters) {
      setState(() {
        _selectedChapter++;
      });
      _loadVerses();
      _scrollToTop();
    }
  }

  void _navigateToPreviousChapter() {
    if (_selectedChapter > 1) {
      setState(() {
        _selectedChapter--;
      });
      _loadVerses();
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    final book = BibleService.getBookById(_selectedBookId);
    final bookNameEn = book?.nameEn ?? '';
    final bookNameTe = book?.nameTe ?? '';

    return StreamBuilder<as_pkg.MediaItem?>(
      stream: AudioService.instance.mediaItem,
      builder: (context, mediaSnapshot) {
        final activeMediaItem = mediaSnapshot.data;
        int? playingVerse;
        if (activeMediaItem != null && activeMediaItem.id.startsWith('${_selectedBookId}_${_selectedChapter}_')) {
          final parts = activeMediaItem.id.split('_');
          if (parts.length == 3) {
            playingVerse = int.tryParse(parts[2]);
          }
        }

        return Scaffold(
          body: Stack(
            children: [
              // 1. Background
              const Positioned.fill(
                child: GradientBackground(child: SizedBox.shrink()),
              ),
              // 2. Immersive Verses ListView
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _barsVisible = !_barsVisible;
                    });
                  },
                  onHorizontalDragStart: (details) {
                    _dragStartX = details.globalPosition.dx;
                    _isSwipeTriggered = false;
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isSwipeTriggered) return;
                    final delta = details.globalPosition.dx - _dragStartX;
                    if (delta.abs() > 50) {
                      _isSwipeTriggered = true;
                      if (delta < 0) {
                        _navigateToNextChapter();
                      } else {
                        _navigateToPreviousChapter();
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF38BDF8),
                          ),
                        )
                      : _verses.isEmpty
                          ? const Center(
                              child: Text(
                                'No verses found.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                                bottom: MediaQuery.of(context).padding.bottom + 90,
                              ),
                              itemCount: _verses.length,
                              itemBuilder: (context, index) {
                                final v = _verses[index];
                                return _buildVerseRow(context, v, userProvider, playingVerse);
                              },
                            ),
                ),
              ),
              // 3. Static Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Visibility(
                  visible: _barsVisible,
                  maintainState: true,
                  child: _buildTopBar(bookNameEn, bookNameTe),
                ),
              ),
              // 4. Static Bottom Floating Bar
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 20,
                right: 20,
                child: Visibility(
                  visible: _barsVisible,
                  maintainState: true,
                  child: _buildBottomBar(bookNameEn, bookNameTe),
                ),
              ),
              // 5. Search overlay
              if (_isSearchActive)
                _buildSearchOverlay(),
              // 6. Instant Selector Overlay
              Positioned.fill(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showSelectorNotifier,
                  builder: (context, show, child) {
                    return Visibility(
                      visible: show,
                      maintainState: true,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showSelectorNotifier.value = false;
                            },
                            child: Container(
                              color: Colors.black54,
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                              child: _BookChapterSelectorDialog(
                                allBooks: _allBooks,
                                selectedBookId: _tempSelectedBookId,
                                selectedChapter: _selectedChapter,
                                testamentFilter: _testamentFilter,
                                onBookSelected: (bookId) {
                                  setState(() {
                                    _tempSelectedBookId = bookId;
                                  });
                                },
                                onFilterChanged: (filter) {
                                  setState(() {
                                    _testamentFilter = filter;
                                    final filtered = _allBooks!.where((b) {
                                      if (filter == 'ALL') return true;
                                      return b.testament == filter;
                                    }).toList();
                                    if (filtered.isNotEmpty && !filtered.any((b) => b.id == _tempSelectedBookId)) {
                                      _tempSelectedBookId = filtered.first.id;
                                    }
                                  });
                                },
                                onBookAndChapterSelected: (bookId, chapter) {
                                  _showSelectorNotifier.value = false;
                                  _changeBookAndChapter(bookId, chapter);
                                },
                                onClose: () {
                                  _showSelectorNotifier.value = false;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(String bookNameEn, String bookNameTe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final userProvider = Provider.of<UserDataProvider>(context);
    final currentDropdownValue = _selectedLanguage == 'telugu' ? _activeTeluguVersion : _activeEnglishVersion;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(top: statusBarHeight + 4, left: 16, right: 16, bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
          ),
          child: SizedBox(
            height: kToolbarHeight + 6,
            child: Row(
              children: [
                // 1. Back button
                if (Navigator.canPop(context))
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                if (Navigator.canPop(context)) const SizedBox(width: 8),
                
                // 2. Book & Chapter Title
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bookNameEn $_selectedChapter',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        bookNameTe,
                        style: const TextStyle(
                          color: Color(0xFFD4A574),
                          fontSize: 16,
                          fontFamily: 'NotoSansTelugu',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 3. Version Dropdown
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: isDark ? const Color(0xFF1E1E30) : Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentDropdownValue,
                      icon: Icon(Icons.arrow_drop_down, color: textColor, size: 20),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Outfit',
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          if (value == 'telugu_ov') {
                            _selectedLanguage = 'telugu';
                            _activeTeluguVersion = value;
                          } else {
                            _selectedLanguage = 'english';
                            _activeEnglishVersion = value;
                          }
                        });
                        _saveVersionPrefs();
                        _loadVerses();
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'telugu_ov',
                          child: Text('Telugu OV', style: TextStyle(color: textColor)),
                        ),
                        DropdownMenuItem(
                          value: 'english_kjv',
                          child: Text('KJV', style: TextStyle(color: textColor)),
                        ),
                        DropdownMenuItem(
                          value: 'english_asv',
                          child: Text('ASV', style: TextStyle(color: textColor)),
                        ),
                        DropdownMenuItem(
                          value: 'english_web',
                          child: Text('WEB', style: TextStyle(color: textColor)),
                        ),
                        DropdownMenuItem(
                          value: 'english_darby',
                          child: Text('Darby', style: TextStyle(color: textColor)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // 4. Bilingual Toggle
                IconButton(
                  icon: const Icon(Icons.translate),
                  color: _isBilingual ? const Color(0xFFFFD700) : textColor.withValues(alpha: 0.5),
                  tooltip: 'Bilingual Mode',
                  onPressed: () {
                    setState(() {
                      _isBilingual = !_isBilingual;
                    });
                    _saveVersionPrefs();
                    _loadVerses();
                  },
                ),

                // 5. Audio Button
                StreamBuilder<as_pkg.PlaybackState>(
                  stream: AudioService.instance.playbackState,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.headset),
                      color: isPlaying ? const Color(0xFFFFD700) : textColor.withValues(alpha: 0.8),
                      tooltip: 'Audio Playback',
                      onPressed: () {
                        if (isPlaying) {
                          AudioService.instance.pause();
                        } else {
                          _startAudioPlayback();
                        }
                      },
                    );
                  },
                ),

                // 6. Kebab Menu
                PopupMenuButton<String>(
                  color: const Color(0xFF1E1E30).withValues(alpha: 0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  icon: Icon(Icons.more_vert, color: textColor),
                  onSelected: (value) {
                    if (value == 'font_size') {
                      _showFontSizeDialog();
                    } else if (value == 'font_style') {
                      _showFontStyleBottomSheet();
                    } else if (value == 'toggle_labels') {
                      setState(() {
                        _showLabels = !_showLabels;
                      });
                      _saveShowLabelsPref();
                    } else if (value == 'bookmark_chapter') {
                      final isBookmarked = userProvider.isChapterBookmarked(_selectedBookId, _selectedChapter);
                      if (isBookmarked) {
                        userProvider.removeBookmarkedChapter(_selectedBookId, _selectedChapter);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chapter removed from bookmarks.')),
                        );
                      } else {
                        userProvider.addBookmarkedChapter(_selectedBookId, _selectedChapter);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chapter bookmarked!')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) {
                    final isBookmarked = userProvider.isChapterBookmarked(_selectedBookId, _selectedChapter);
                    return [
                      const PopupMenuItem<String>(
                        value: 'font_size',
                        child: Row(
                          children: [
                            Icon(Icons.format_size, size: 20, color: Colors.white70),
                            SizedBox(width: 8),
                            Text('Font Size', style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'font_style',
                        child: Row(
                          children: [
                            Icon(Icons.font_download_outlined, size: 20, color: Colors.white70),
                            SizedBox(width: 8),
                            Text('Font Style', style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle_labels',
                        child: Row(
                          children: [
                            Icon(_showLabels ? Icons.label : Icons.label_outline, size: 20, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              _showLabels ? 'Hide Labels' : 'Add Labels',
                              style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'bookmark_chapter',
                        child: Row(
                          children: [
                            Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: isBookmarked ? const Color(0xFFFFD700) : Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isBookmarked ? 'Remove Bookmark' : 'Bookmark Chapter',
                              style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E30) : Colors.white,
              title: Text(
                'Adjust Font Size',
                style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.text_decrease),
                        color: textColor,
                        onPressed: _fontSize > _fontSizeMin
                            ? () {
                                setDialogState(() {
                                  _fontSize = (_fontSize - 2).clamp(_fontSizeMin, _fontSizeMax);
                                });
                                setState(() {
                                  _fontSize = _fontSize;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_fontSize.round()}pt',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.text_increase),
                        color: textColor,
                        onPressed: _fontSize < _fontSizeMax
                            ? () {
                                setDialogState(() {
                                  _fontSize = (_fontSize + 2).clamp(_fontSizeMin, _fontSizeMax);
                                });
                                setState(() {
                                  _fontSize = _fontSize;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preview Text',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Thy word is a lamp unto my feet, and a light unto my path.',
                      style: TextStyle(
                        color: textColor,
                        fontSize: _fontSize,
                        fontFamily: 'Outfit',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(fontFamily: 'Outfit')),
                ),
              ],
            );
          },
        );
      },
    ).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bible_font_size', _fontSize.round());
    });
  }

  void _showFontStyleBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
        final bgColor = isDark ? const Color(0xFF1E1E30) : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Font Style',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildFontStyleOption('normal', 'Normal', textColor),
              _buildFontStyleOption('bold', 'Bold', textColor),
              _buildFontStyleOption('italic', 'Italic', textColor),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontStyleOption(String value, String label, Color textColor) {
    final isSelected = _fontStyle == value;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Outfit',
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFFFD700)) : null,
      onTap: () async {
        setState(() {
          _fontStyle = value;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_font_style', value);
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _saveShowLabelsPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bible_show_labels', _showLabels);
  }

  Widget _buildBottomBar(String bookNameEn, String bookNameTe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final book = BibleService.getBookById(_selectedBookId);
    final totalChapters = book?.chapters ?? 1;
    final isFirstChapter = _selectedChapter == 1;
    final isLastChapter = _selectedChapter == totalChapters;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. Previous Chapter button (⏮)
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 20,
                      color: textColor.withValues(alpha: isFirstChapter ? 0.3 : 0.8),
                      tooltip: 'Previous Chapter',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: isFirstChapter ? null : _navigateToPreviousChapter,
                    ),
                    // 2. Notes button (📝)
                    IconButton(
                      icon: const Icon(Icons.sticky_note_2),
                      color: textColor.withValues(alpha: 0.8),
                      tooltip: 'Notes',
                      onPressed: () => _showNotesSheet(),
                    ),
                    // 3. Search button (🔍)
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: textColor.withValues(alpha: 0.8),
                      tooltip: 'Search',
                      onPressed: () {
                        setState(() {
                          _isSearchActive = true;
                        });
                      },
                    ),
                    // 4. Current Book/Chapter indicator (📖)
                    InkWell(
                      onTap: () {
                        _tempSelectedBookId = _selectedBookId;
                        _showSelectorNotifier.value = true;
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.book_rounded, color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '$bookNameEn $_selectedChapter',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 5. Next Chapter button (⏭)
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 20,
                      color: textColor.withValues(alpha: isLastChapter ? 0.3 : 0.8),
                      tooltip: 'Next Chapter',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: isLastChapter ? null : _navigateToNextChapter,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesSheet({int? initialVerse}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in or sign up to use notes.')),
      );
      return;
    }

    final book = BibleService.getBookById(_selectedBookId);
    if (book == null) return;

    int? filterVerse = initialVerse;
    final Set<String> expandedNoteIds = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final uid = user.uid;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E30) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.sticky_note_2, color: Color(0xFFFFD700), size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filterVerse != null
                                ? 'Notes for ${book.nameEn} $_selectedChapter:$filterVerse'
                                : 'Notes for ${book.nameEn} $_selectedChapter',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (filterVerse != null)
                          TextButton.icon(
                            icon: const Icon(Icons.clear, size: 16, color: Color(0xFFFFD700)),
                            label: const Text('Show All', style: TextStyle(fontFamily: 'Outfit', color: Color(0xFFFFD700))),
                            onPressed: () {
                              setSheetState(() {
                                filterVerse = null;
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),

                  // StreamBuilder for real-time notes
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: FirebaseService.getChapterNotes(uid, book.id, _selectedChapter),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                        }

                        final allNotes = snapshot.data ?? [];
                        final notes = filterVerse != null
                            ? allNotes.where((n) => n['verseNumber'] == filterVerse).toList()
                            : allNotes;

                        if (notes.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "No notes yet. Tap + to add one.",
                                style: TextStyle(color: Colors.white54, fontFamily: 'Outfit', fontSize: 15),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            final noteId = note['id'] as String;
                            final text = note['text'] as String? ?? '';
                            final isExpanded = expandedNoteIds.contains(noteId);

                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  if (isExpanded) {
                                    expandedNoteIds.remove(noteId);
                                  } else {
                                    expandedNoteIds.add(noteId);
                                  }
                                });
                              },
                              child: Card(
                                color: const Color(0xFF1E1E30).withValues(alpha: 0.75),
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Gold badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                              border: Border.all(
                                                color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              note['verseNumber'] == null
                                                  ? 'Whole Chapter'
                                                  : 'Verse ${note['verseNumber']}',
                                              style: const TextStyle(
                                                color: Color(0xFFFFD700),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                          ),
                                          // Delete button
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: const Color(0xFF1E1E30),
                                                  title: const Text('Delete Note', style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                                                  content: const Text('Are you sure you want to delete this note?', style: TextStyle(color: Colors.white70, fontFamily: 'Outfit')),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontFamily: 'Outfit')),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                await FirebaseService.deleteNote(uid, noteId);
                                                if (mounted) {
                                                  setState(() {
                                                    _chapterNotes = _chapterNotes.where((n) => n['id'] != noteId).toList();
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Outfit',
                                        ),
                                        maxLines: isExpanded ? null : 3,
                                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // "+ Add Note" button
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      top: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          'Add Note',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showAddNoteDialog(
                          preselectedVerse: filterVerse,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddNoteDialog({int? preselectedVerse}) {
    final book = BibleService.getBookById(_selectedBookId);
    if (book == null) return;

    final totalVerses = _verses.length;
    if (totalVerses == 0) return;

    int? selectedVerse = preselectedVerse;
    if (selectedVerse != null && (selectedVerse < 1 || selectedVerse > totalVerses)) {
      selectedVerse = null;
    }

    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E30),
              title: const Text(
                '✏️ Add Note',
                style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int?>(
                    initialValue: selectedVerse,
                    dropdownColor: const Color(0xFF1E1E30),
                    style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                    decoration: const InputDecoration(
                      labelText: 'Verse Link',
                      labelStyle: TextStyle(color: Colors.white70, fontFamily: 'Outfit'),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Whole Chapter'),
                      ),
                      ...List.generate(totalVerses, (index) => index + 1).map((v) {
                        return DropdownMenuItem<int?>(
                          value: v,
                          child: Text('Verse $v'),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedVerse = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 5,
                    maxLength: 500,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                    decoration: InputDecoration(
                      hintText: 'Enter your note here...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final text = textController.text.trim();
                    if (text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Note text cannot be empty')),
                      );
                      return;
                    }

                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User must be logged in')),
                      );
                      return;
                    }

                    final verseRef = selectedVerse != null
                        ? '${book.nameEn} $_selectedChapter:$selectedVerse'
                        : 'Whole Chapter';

                    final navigator = Navigator.of(context);
                    final noteId = await FirebaseService.addNote(
                      uid,
                      _selectedBookId,
                      _selectedChapter,
                      selectedVerse,
                      verseRef,
                      text,
                    );

                    if (mounted) {
                      setState(() {
                        _chapterNotes = List.from(_chapterNotes)..add({
                          'id': noteId,
                          'bookId': _selectedBookId,
                          'chapter': _selectedChapter,
                          'verseNumber': selectedVerse,
                          'verseReference': verseRef,
                          'text': text,
                          'createdAt': Timestamp.now(),
                          'updatedAt': Timestamp.now(),
                        });
                      });
                    }

                    navigator.pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }




  Widget _buildSearchOptionsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _searchAllBooks = false;
                });
                _performSearch(_searchController.text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_searchAllBooks ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Search current book',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _searchAllBooks = true;
                });
                _performSearch(_searchController.text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _searchAllBooks ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Search entire Bible',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView() {
    if (_isIndexing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF38BDF8)),
            SizedBox(height: 12),
            Text('Indexing Bible for search...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_searchQuery.trim().isEmpty) {
      return const Center(
        child: Text(
          'Type to search scriptures...',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found.',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final isTelugu = _selectedLanguage == 'telugu';
        final textSnippet = isTelugu ? result.textTe : result.textKjv;

        return Card(
          color: Colors.white.withValues(alpha: 0.03),
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _isSearchActive = false;
                _selectedBookId = result.bookId;
                _selectedChapter = result.chapter;
                _targetVerse = result.verse;
                _selectedVerse = result.verse;


              });
              _searchController.clear();
              _searchResults = [];
              _searchQuery = '';
              _loadVerses();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.bookNameEn} (${result.bookNameTe}) ${result.chapter}:${result.verse}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    textSnippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontFamily: isTelugu ? 'NotoSansTelugu' : 'Outfit',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _toSuperscript(int val) {
    final s = val.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final char = s[i];
      switch (char) {
        case '0': buffer.write('⁰'); break;
        case '1': buffer.write('¹'); break;
        case '2': buffer.write('²'); break;
        case '3': buffer.write('³'); break;
        case '4': buffer.write('⁴'); break;
        case '5': buffer.write('⁵'); break;
        case '6': buffer.write('⁶'); break;
        case '7': buffer.write('⁷'); break;
        case '8': buffer.write('⁸'); break;
        case '9': buffer.write('⁹'); break;
      }
    }
    return buffer.toString();
  }
  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.95),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isSearchActive = false;
                          _searchController.clear();
                          _searchResults = [];
                          _searchQuery = '';
                        });
                      },
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Search verses / వచనాలను వెతకండి...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSearchOptionsRow(),
              Expanded(
                child: _buildSearchResultsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

                  if (_activeLabelingVerse == v.verse) ...[
                    const SizedBox(height: 10),
                    _buildInlineColorPalette(v),
                  ],
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              // Actions (Favorite | Bookmark | Share)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _favoritedVerses.contains(v.verse) ? Icons.star : Icons.star_border,
                      color: _favoritedVerses.contains(v.verse) ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to favorite verses.')),
                        );
                        return;
                      }
                      final verseText = _selectedLanguage == 'telugu' ? v.textTe : v.textKjv;
                      await FirebaseService.toggleFavoriteVerse(uid, _selectedBookId, _selectedChapter, v.verse, verseText);
                      if (mounted) {
                        setState(() {
                          if (_favoritedVerses.contains(v.verse)) {
                            _favoritedVerses.remove(v.verse);
                          } else {
                            _favoritedVerses.add(v.verse);
                          }
                        });
                      }
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    onPressed: () {
                      userProvider.toggleVerseBookmark(verseRef);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    onPressed: () {
                      VerseShareCard.shareVerse(
                        context: context,
                        bookNameEn: bookNameEn,
                        bookNameTe: bookNameTe,
                        chapter: _selectedChapter,
                        verse: v.verse,
                        textTe: v.textTe,
                        textEn: v.textKjv,
                        mode: _isBilingual
                            ? 'bilingual'
                            : _selectedLanguage == 'telugu'
                                ? 'te'
                                : 'kjv',
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
            if (hasNotes) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showNotesSheet(initialVerse: v.verse),
                child: const Tooltip(
                  message: 'View Notes',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Icon(
                      Icons.sticky_note_2,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildVerseRow(BuildContext context, BibleVerse v, UserDataProvider userProvider, int? playingVerse) {
    final showTelugu = _isBilingual || _selectedLanguage == 'telugu';
    final showEnglish = _isBilingual || _selectedLanguage == 'english';

    final isCurrentlyPlaying = playingVerse == v.verse;
    final isSelected = _selectedVerse == v.verse || isCurrentlyPlaying;
    final verseRef = '${_selectedBookId}_${_selectedChapter}_${v.verse}';
    final isBookmarked = userProvider.isVerseBookmarked(verseRef);
    final hasNotes = _chapterNotes.any((note) => note['verseNumber'] == v.verse);
    final label = _showLabels ? VerseLabels.getLabel(_selectedBookId, _selectedChapter, v.verse) : null;

    final labelColourHex = _labelledVerses[v.verse];
    Color? tintColour;
    if (labelColourHex != null) {
      final normalizedHex = labelColourHex.replaceAll('#', '').toUpperCase();
      if (normalizedHex == 'FFD54F' || normalizedHex == 'FFC107') {
        tintColour = const Color(0xFFFFD54F);
      } else if (normalizedHex == '90CAF9' || normalizedHex == '2196F3') {
        tintColour = const Color(0xFF90CAF9);
      } else if (normalizedHex == 'A5D6A7' || normalizedHex == '4CAF50') {
        tintColour = const Color(0xFFA5D6A7);
      } else if (normalizedHex == 'F48FB1' || normalizedHex == 'E91E63') {
        tintColour = const Color(0xFFF48FB1);
      } else {
        try {
          tintColour = Color(int.parse(labelColourHex.replaceAll('#', '0xFF')));
        } catch (_) {}
      }
    }

    final TextStyle englishStyle;
    switch (_fontStyle) {
      case 'bold':
        englishStyle = TextStyle(
          color: Colors.white.withValues(alpha: 0.9), // +10% contrast for English
          fontSize: ((_fontSize * 16 / 18).clamp(_fontSizeMin, _fontSizeMax)),
          height: 1.7,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.normal,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        );
        break;
      case 'italic':
        englishStyle = TextStyle(
          color: Colors.white.withValues(alpha: 0.88), // improved readability
          fontSize: ((_fontSize * 16 / 18).clamp(_fontSizeMin, _fontSizeMax)),
          height: 1.7,
          fontWeight: FontWeight.w600, // slightly heavier
          fontStyle: FontStyle.italic,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        );
        break;
      case 'normal':
      default:
        englishStyle = TextStyle(
          color: Colors.white.withValues(alpha: 0.88), // +10% contrast for secondary text
          fontSize: ((_fontSize * 16 / 18).clamp(_fontSizeMin, _fontSizeMax)),
          height: 1.7,
          fontWeight: FontWeight.w600, // slightly heavier for better legibility
          fontStyle: FontStyle.normal,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Telugu text (always shown in Telugu or Bilingual)
        if (showTelugu)
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      _toSuperscript(v.verse),
                      style: TextStyle(
                        fontSize: 12.0,  // Small verse number
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' '),
                if (label != null) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: VerseLabels.getLabelColor(label),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ],
                const TextSpan(text: ' '),
                TextSpan(
                  text: v.textTe,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fontSize,  // User-controlled base size (default 18px)
                    height: 1.8,        // Telugu line height 1.8
                    fontWeight: FontWeight.w400,  // Normal weight for verse body
                    fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'NotoSansTelugu',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4.0),  // Small space between Telugu and English
        // English text (bilingual sub-version)
        if (showEnglish)
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      _toSuperscript(v.verse),
                      style: TextStyle(
                        fontSize: 12.0,  // Small verse number
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' '),
                if (label != null && !showTelugu) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: VerseLabels.getLabelColor(label),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ],
                const TextSpan(text: ' '),
                TextSpan(
                  text: v.textKjv,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),  // 60% opacity for secondary text
                    fontSize: 14.0,    // Fixed 14px for English
                    height: 1.6,       // English line height 1.6
                    fontWeight: FontWeight.w400,  // Light weight for verse body
                    fontStyle: FontStyle.italic,  // Italic for English
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20.0),  // Space between verse pairs (20px as requested)
      ],
    );
  }
    final currentLabel = _labelledVerses[v.verse];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInlineColorCircle(v, 'FFD54F', const Color(0xFFFFD54F), currentLabel),
        const SizedBox(width: 12),
        _buildInlineColorCircle(v, '90CAF9', const Color(0xFF90CAF9), currentLabel),
        const SizedBox(width: 12),
        _buildInlineColorCircle(v, 'A5D6A7', const Color(0xFFA5D6A7), currentLabel),
        const SizedBox(width: 12),
        _buildInlineColorCircle(v, 'F48FB1', const Color(0xFFF48FB1), currentLabel),
      ],
    );
  }

  Widget _buildInlineColorCircle(BibleVerse v, String hex, Color color, String? currentLabel) {
    final isSelected = currentLabel == hex || currentLabel == '#$hex';
    return GestureDetector(
      onTap: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to label verses.')),
          );
          return;
        }

        if (isSelected) {
          await FirebaseService.removeLabelledVerse(uid, _selectedBookId, _selectedChapter, v.verse);
          if (mounted) {
            setState(() {
              _labelledVerses.remove(v.verse);
            });
          }
        } else {
          await FirebaseService.addLabelledVerse(uid, _selectedBookId, _selectedChapter, v.verse, hex);
          if (mounted) {
            setState(() {
              _labelledVerses[v.verse] = hex;
            });
          }
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookChapterSelectorDialog extends StatelessWidget {
  final List<BibleBook>? allBooks;
  final String selectedBookId;
  final int selectedChapter;
  final String testamentFilter;
  final Function(String bookId) onBookSelected;
  final Function(String testamentFilter) onFilterChanged;
  final Function(String bookId, int chapter) onBookAndChapterSelected;
  final VoidCallback onClose;

  const _BookChapterSelectorDialog({
    required this.allBooks,
    required this.selectedBookId,
    required this.selectedChapter,
    required this.testamentFilter,
    required this.onBookSelected,
    required this.onFilterChanged,
    required this.onBookAndChapterSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    if (allBooks == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E30) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF38BDF8),
          ),
        ),
      );
    }

    final filteredBooks = allBooks!.where((b) {
      if (testamentFilter == 'ALL') return true;
      return b.testament == testamentFilter;
    }).toList();

    final selectedBook = allBooks!.firstWhere(
      (b) => b.id == selectedBookId,
      orElse: () => allBooks!.first,
    );

    return Material(
      color: isDark ? const Color(0xFF1E1E30) : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.none,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Book & Chapter',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Outfit',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildFilterButton(context, 'ALL', 'All')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton(context, 'OT', 'OT')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton(context, 'NT', 'NT')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Books List (Left)
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemExtent: 48,
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final b = filteredBooks[index];
                        final isSelected = b.id == selectedBookId;
                        return GestureDetector(
                          onTap: () => onBookSelected(b.id),
                          child: Container(
                            color: isSelected
                                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                                : Colors.transparent,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  b.nameEn,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF38BDF8) : textColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                Text(
                                  b.nameTe,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF38BDF8).withValues(alpha: 0.7)
                                        : Colors.white38,
                                    fontSize: 10,
                                    fontFamily: 'NotoSansTelugu',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  const SizedBox(width: 12),
                  // Chapters Grid (Right)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${selectedBook.nameEn} Chapters',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 5,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: List.generate(selectedBook.chapters, (index) {
                              final ch = index + 1;
                              final isSelected = selectedBook.id == selectedBookId &&
                                  ch == selectedChapter;
                              return InkWell(
                                onTap: () => onBookAndChapterSelected(selectedBook.id, ch),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                                        : isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : Colors.black.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$ch',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFFD700) : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String value, String label) {
    final isSelected = testamentFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return InkWell(
      onTap: () => onFilterChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF38BDF8) : textColor.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }
}
