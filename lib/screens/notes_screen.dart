import '../widgets/gradient_background.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/user_data/providers/user_data_providers.dart';
import '../features/bible/providers/bible_providers.dart';
import '../services/bible_service.dart';
import 'package:provider/provider.dart' as p;
import '../providers/locale_provider.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditNoteDialog(Map<String, dynamic> note) {
    final text = note['text'] as String;
    final version = note['version'] as String;
    final bookName = note['book_name'] as String;
    final chapter = note['chapter'] as int;
    final verse = note['verse'] as int;

    final controller = TextEditingController(text: text);

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              "Edit Note",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$bookName $chapter:$verse (${version.toUpperCase().replaceAll('_', ' ')})",
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Type note here...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    await ref.read(notesProvider.notifier).saveNote(
                          version: version,
                          bookName: bookName,
                          chapter: chapter,
                          verse: verse,
                          text: controller.text.trim(),
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const _CreateNoteDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF5D4037));

    // Always use white/white70 for elements drawn directly on the navy background
    const bgTextColor = Colors.white;
    const bgSubTextColor = Colors.white70;

    final filteredNotes = notes.where((n) {
      final text = (n['text'] as String? ?? '').toLowerCase();
      final bookName = (n['book_name'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return text.contains(query) || bookName.contains(query);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _showCreateNoteDialog,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bgTextColor),
                        onPressed: () => context.go('/home'),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "My Notes 📝",
                        style: TextStyle(
                          color: bgTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: bgTextColor, fontFamily: 'Outfit'),
                      decoration: InputDecoration(
                        hintText: "Search notes...",
                        hintStyle: TextStyle(color: bgSubTextColor.withValues(alpha: 0.5), fontFamily: 'Outfit'),
                        prefixIcon: Icon(Icons.search, color: bgSubTextColor.withValues(alpha: 0.5)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: bgSubTextColor.withValues(alpha: 0.5)),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: filteredNotes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note_outlined,
                                  size: 70,
                                  color: bgSubTextColor.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty ? "No Notes Yet" : "No notes found",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                    color: bgTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? "Create notes in the Bible reader by pressing the note icon on a selected verse, or tap + below."
                                      : "Try searching for a different keyword.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: bgSubTextColor,
                                    fontFamily: 'Outfit',
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final n = filteredNotes[index];
                            final id = n['id'] as String;
                            final version = n['version'] as String;
                            final bookName = n['book_name'] as String;
                            final chapter = n['chapter'] as int;
                            final verse = n['verse'] as int;
                            final text = n['text'] as String;
                            final updatedAt = n['updated_at'] as String;

                            final metadataBook = BibleService.getBooks().firstWhere(
                              (book) => book.id == bookName.toLowerCase().replaceAll(' ', ''),
                              orElse: () => BibleBook(
                                  id: bookName.toLowerCase().replaceAll(' ', ''),
                                  nameEn: bookName,
                                  nameTe: '',
                                  chapters: 1,
                                  testament: 'OT'),
                            );

                            final reference = '${metadataBook.nameEn} $chapter:$verse';
                            final displayDate = DateTime.tryParse(updatedAt)?.toLocal().toString().substring(0, 16) ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: Dismissible(
                                key: Key(id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  ref.read(notesProvider.notifier).deleteNote(id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Deleted note for $reference"),
                                    ),
                                  );
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade900,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? Colors.white12 : const Color(0xFFD4A574).withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          onTap: () => _showEditNoteDialog(n),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      reference,
                                                      style: TextStyle(
                                                        color: isDark ? const Color(0xFFFFD700) : const Color(0xFFB58D00),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        fontFamily: 'Outfit',
                                                      ),
                                                    ),
                                                    Text(
                                                      displayDate,
                                                      style: TextStyle(
                                                        color: subTextColor.withValues(alpha: 0.4),
                                                        fontSize: 11,
                                                        fontFamily: 'Outfit',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "Version: ${version.toUpperCase().replaceAll('_', ' ')}",
                                                  style: TextStyle(
                                                    color: subTextColor.withValues(alpha: 0.5),
                                                    fontSize: 11,
                                                    fontFamily: 'Outfit',
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  text,
                                                  style: TextStyle(
                                                    color: textColor.withValues(alpha: 0.9),
                                                    fontSize: 14,
                                                    fontFamily: 'Outfit',
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                                                      color: subTextColor.withValues(alpha: 0.6),
                                                      onPressed: () {
                                                        context.push('/bible/$version/$bookName/$chapter?verse=$verse');
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.edit_rounded, size: 20),
                                                      color: subTextColor.withValues(alpha: 0.6),
                                                      onPressed: () => _showEditNoteDialog(n),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_rounded, size: 20),
                                                      color: Colors.red.shade400.withValues(alpha: 0.8),
                                                      onPressed: () async {
                                                        final confirm = await showDialog<bool>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text("Delete Note"),
                                                            content: const Text("Are you sure you want to delete this note?"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, false),
                                                                child: const Text("Cancel"),
                                                              ),
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, true),
                                                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        if (confirm == true) {
                                                          ref.read(notesProvider.notifier).deleteNote(id);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
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
}

class _CreateNoteDialog extends ConsumerStatefulWidget {
  const _CreateNoteDialog();

  @override
  ConsumerState<_CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends ConsumerState<_CreateNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedVersion = 'telugu_ov';
  String _selectedBook = 'Genesis';
  final _chapterController = TextEditingController(text: '1');
  final _verseController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final localeProvider = p.Provider.of<LocaleProvider>(context, listen: false);
    _selectedVersion = localeProvider.activeVersion;
  }

  final List<String> _versions = [
    'telugu_ov',
    'telugu_wbtc',
    'telugu_irv',
    'kjv',
    'asv',
    'web',
    'darby',
  ];

  @override
  void dispose() {
    _chapterController.dispose();
    _verseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = BibleService.getBooks().map((b) => b.nameEn).toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Create Note",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Version Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedVersion,
                    dropdownColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontFamily: 'Outfit'),
                    decoration: InputDecoration(
                      labelText: "Version",
                      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    items: _versions.map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text(v.toUpperCase().replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedVersion = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Book Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBook,
                    dropdownColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontFamily: 'Outfit'),
                    decoration: InputDecoration(
                      labelText: "Book",
                      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    items: books.map((b) {
                      return DropdownMenuItem(
                        value: b,
                        child: Text(b),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBook = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Chapter & Verse Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _chapterController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Chapter",
                            labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Required";
                            final ch = int.tryParse(value);
                            if (ch == null || ch <= 0) return "Invalid";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _verseController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Verse",
                            labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Required";
                            final vs = int.tryParse(value);
                            if (vs == null || vs <= 0) return "Invalid";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Note Text
                  TextFormField(
                    controller: _noteController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Type note here...",
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Please enter some text";
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final chapter = int.parse(_chapterController.text);
                final verse = int.parse(_verseController.text);

                // Let's verify the verse exists in the SQLite Bible database first!
                final repository = ref.read(bibleRepositoryProvider);
                final verseExists = await repository.getVerse(_selectedVersion, _selectedBook, chapter, verse);

                if (verseExists == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("The verse $_selectedBook $chapter:$verse does not exist in the $_selectedVersion database."),
                        backgroundColor: Colors.red.shade900,
                      ),
                    );
                  }
                  return;
                }

                await ref.read(notesProvider.notifier).saveNote(
                      version: _selectedVersion,
                      bookName: _selectedBook,
                      chapter: chapter,
                      verse: verse,
                      text: _noteController.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Added note for $_selectedBook $chapter:$verse"),
                    ),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
