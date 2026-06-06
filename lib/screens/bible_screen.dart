import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/bible.dart';
import '../services/bible_service.dart';
import '../providers/user_data_provider.dart';
import '../widgets/verse_share_card.dart';
import '../widgets/gradient_background.dart';
import 'bookmarked_verses_screen.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  String _selectedBookId = 'genesis';
  int _selectedChapter = 1;
  // 'te' = Telugu only, 'bilingual' = Telugu + English sub
  String _selectedVersion = 'te';
  // Bilingual sub-version: 'kjv' or 'nhv'
  String _bilingualSub = 'kjv';
  String _selectedTestament = 'OT'; // 'OT' | 'NT'

  // Font size (persisted)
  double _fontSize = 16.0;
  static const double _fontSizeMin = 14.0;
  static const double _fontSizeMax = 28.0;
  static const double _fontSizeStep = 2.0;

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
  Set<int> _highlightedVerses = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadVerses();
    _initSearchIndex();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedVersion = prefs.getString('bible_version') ?? 'te';
        _bilingualSub    = prefs.getString('bible_bilingual_sub') ?? 'kjv';
        _fontSize        = (prefs.getDouble('bible_font_size') ?? 16.0)
            .clamp(_fontSizeMin, _fontSizeMax);
      });
    }
  }

  Future<void> _saveVersionPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bible_version', _selectedVersion);
    await prefs.setString('bible_bilingual_sub', _bilingualSub);
  }

  Future<void> _saveFontSizePref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', _fontSize);
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
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
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
          _selectedTestament = book.testament;
          _targetVerse = userProvider.bibleVerse;
          if (_targetVerse != null) {
            _highlightedVerses = {_targetVerse!};
          } else {
            _highlightedVerses = {};
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
      final verses = await BibleService.getChapterVerses(_selectedBookId, _selectedChapter);
      setState(() {
        _verses = verses;
        _isLoading = false;
      });

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
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _changeBook(String bookId) {
    final book = BibleService.getBookById(bookId);
    if (book != null) {
      setState(() {
        _selectedBookId = bookId;
        _selectedChapter = 1;
        _selectedTestament = book.testament;
      });
      _loadVerses();
    }
  }

  void _changeChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
    });
    _loadVerses();
  }

  void _showBookSelector() {
    final books = _selectedTestament == 'OT'
        ? BibleService.getOTBooks()
        : BibleService.getNTBooks();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return _BookSelectorSheet(
                  books: books,
                  onBookSelected: (bookId) {
                    Navigator.pop(context);
                    _changeBook(bookId);
                  },
                  scrollController: controller,
                );
              },
            );
          },
        );
      },
    );
  }

  void _showChapterSelector() {
    final book = BibleService.getBookById(_selectedBookId);
    if (book == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E30),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Chapter / అధ్యాయాన్ని ఎంచుకోండి',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: book.chapters,
                  itemBuilder: (context, index) {
                    final ch = index + 1;
                    final isSelected = ch == _selectedChapter;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _changeChapter(ch);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$ch',
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    final book = BibleService.getBookById(_selectedBookId);
    final bookName = book != null
        ? '${book.nameEn} (${book.nameTe})'
        : 'Select Book';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearchActive
            ? Container(
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
              )
            : const Text(
                'Holy Bible • పరిశుద్ధ గ్రంథము',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
        centerTitle: !_isSearchActive,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearchActive) {
                  _isSearchActive = false;
                  _searchController.clear();
                  _searchResults = [];
                  _searchQuery = '';
                } else {
                  _isSearchActive = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkedVersesScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_isSearchActive) _buildSearchOptionsRow() else _buildNavPanel(bookName),
                if (!_isSearchActive) _buildVersionSelector(),
                Expanded(
                  child: _isSearchActive
                      ? _buildSearchResultsView()
                      : _isLoading
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  itemCount: _verses.length,
                                  itemBuilder: (context, index) {
                                    final v = _verses[index];
                                    return _buildVerseRow(v, userProvider);
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        final isTelugu = _selectedVersion == 'te';
        final textSnippet = isTelugu
            ? result.textTe
            : _bilingualSub == 'nhv'
                ? result.textNhv
                : result.textKjv;

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
                _highlightedVerses = {result.verse};

                final book = BibleService.getBookById(result.bookId);
                if (book != null) {
                  _selectedTestament = book.testament;
                }
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

  Widget _buildNavPanel(String bookName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          // Testament Toggle Selector
          Row(
            children: [
              Expanded(
                child: _buildTestamentButton('OT', 'Old Testament / పాత నిబంధన'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTestamentButton('NT', 'New Testament / కొత్త నిబంధన'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Book & Chapter buttons + Font size
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: _showBookSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            bookName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showChapterSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Ch $_selectedChapter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Font size controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _fontSize > _fontSizeMin
                          ? () {
                              setState(() => _fontSize -= _fontSizeStep);
                              _saveFontSizePref();
                            }
                          : null,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Icon(
                          Icons.text_decrease,
                          color: _fontSize > _fontSizeMin
                              ? Colors.white70
                              : Colors.white24,
                          size: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        '${_fontSize.toInt()}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _fontSize < _fontSizeMax
                          ? () {
                              setState(() => _fontSize += _fontSizeStep);
                              _saveFontSizePref();
                            }
                          : null,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Icon(
                          Icons.text_increase,
                          color: _fontSize < _fontSizeMax
                              ? Colors.white70
                              : Colors.white24,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestamentButton(String testament, String label) {
    final isSelected = _selectedTestament == testament;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedTestament = testament;
            if (testament == 'OT') {
              _changeBook('genesis');
            } else {
              _changeBook('matthew');
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          testament,
          style: TextStyle(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }

  Widget _buildVersionSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main version toggle: Telugu | Bilingual
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildVersionPill('te', 'Telugu / తెలుగు'),
              _buildVersionPill('bilingual', 'Bilingual / ద్విభాష'),
            ],
          ),
        ),
        // Bilingual sub-selector: KJV | NHV
        if (_selectedVersion == 'bilingual')
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 40, right: 40, bottom: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                _buildSubPill('kjv', 'KJV'),
                _buildSubPill('nhv', 'NHV'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVersionPill(String version, String label) {
    final isSelected = _selectedVersion == version;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedVersion = version;
          });
          _saveVersionPrefs();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              fontFamily: 'Outfit',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubPill(String sub, String label) {
    final isSelected = _bilingualSub == sub;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _bilingualSub = sub;
          });
          _saveVersionPrefs();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
              fontFamily: 'Outfit',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseRow(BibleVerse v, UserDataProvider userProvider) {
    final book = BibleService.getBookById(_selectedBookId);
    final bookNameEn = book?.nameEn ?? '';
    final bookNameTe = book?.nameTe ?? '';

    final isTelugu = _selectedVersion == 'te';
    final isBilingual = _selectedVersion == 'bilingual';
    final showNhv = isBilingual && _bilingualSub == 'nhv';

    final isHighlighted = _highlightedVerses.contains(v.verse);
    final verseRef = '${_selectedBookId}_${_selectedChapter}_${v.verse}';
    final isBookmarked = userProvider.isVerseBookmarked(verseRef);

    return InkWell(
      onTap: () {
        setState(() {
          if (_highlightedVerses.contains(v.verse)) {
            _highlightedVerses.remove(v.verse);
          } else {
            _highlightedVerses.add(v.verse);
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFFFD700).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: isHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse Number Badge
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isHighlighted
                      ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${v.verse}',
                style: TextStyle(
                  color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Verse Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Telugu text (always shown in Telugu or Bilingual)
                  if (isTelugu || isBilingual)
                    Text(
                      v.textTe,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontSize,
                        height: 1.6,
                        fontFamily: 'NotoSansTelugu',
                      ),
                    ),
                  if (isBilingual) const SizedBox(height: 8),
                  // English text (bilingual sub-version)
                  if (isBilingual)
                    Text(
                      showNhv ? v.textNhv : v.textKjv,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: (_fontSize - 1).clamp(_fontSizeMin, _fontSizeMax),
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Outfit',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions (Bookmark & Share)
            Column(
              children: [
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
                      textEn: showNhv ? v.textNhv : v.textKjv,
                      mode: _selectedVersion,
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
        ),
      ),
    );
  }
}

class _BookSelectorSheet extends StatefulWidget {
  final List<BibleBook> books;
  final Function(String) onBookSelected;
  final ScrollController scrollController;

  const _BookSelectorSheet({
    required this.books,
    required this.onBookSelected,
    required this.scrollController,
  });

  @override
  State<_BookSelectorSheet> createState() => _BookSelectorSheetState();
}

class _BookSelectorSheetState extends State<_BookSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredBooks = widget.books.where((b) {
      final q = _searchQuery.toLowerCase();
      return b.nameEn.toLowerCase().contains(q) || b.nameTe.contains(q);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search book / పుస్తకాన్ని వెతకండి...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Book List
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final b = filteredBooks[index];
                return ListTile(
                  title: Text(
                    b.nameEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  subtitle: Text(
                    b.nameTe,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'NotoSansTelugu',
                    ),
                  ),
                  trailing: Text(
                    '${b.chapters} Ch',
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  onTap: () => widget.onBookSelected(b.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
