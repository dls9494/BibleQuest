import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_data_provider.dart';
import '../providers/locale_provider.dart';
import '../services/profile_assets.dart';
import '../services/bible_service.dart';
import '../services/firebase_service.dart';
import '../models/achievement.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;

  // Banner state
  String? _bannerUrl;
  File? _bannerFile;

  // Avatar state
  String _avatarType = 'custom';
  String? _photoURL;
  String? _defaultAvatarId;
  File? _avatarFile;

  // Text controllers
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioEnController;
  late TextEditingController _bioTeController;
  late TextEditingController _favVerseController;
  late TextEditingController _youtubeController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  late TextEditingController _blogController;
  late TextEditingController _testimonyEnController;
  late TextEditingController _testimonyTeController;

  // Selected values
  String? _favVersePreview;
  String? _selectedMinistryRole;
  late String _selectedAccentColor;
  final List<String> _selectedShowcaseBadges = [];
  late String _activityVisibility;
  late String _profileVisibility;
  late bool _showPrayersOnProfile;
  late bool _showTestimonyOnProfile;

  // Maps for accent colors
  static const Map<String, Color> _accentColorMap = {
    'gold': Color(0xFFF7BC64),
    'blue': Color(0xFF38BDF8),
    'green': Color(0xFF4ADE80),
    'purple': Color(0xFFC084FC),
    'rose': Color(0xFFFB7185),
    'silver': Color(0xFFCBD5E1),
  };

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserDataProvider>();

    _bannerUrl = provider.bannerUrl;
    _avatarType = provider.avatarType;
    _photoURL = provider.photoURL;
    _defaultAvatarId = provider.defaultAvatarId;

    _nameController = TextEditingController(text: provider.displayName);
    _usernameController = TextEditingController(text: provider.username);
    _bioEnController = TextEditingController(text: provider.bioEn);
    _bioTeController = TextEditingController(text: provider.bioTe);
    _favVerseController = TextEditingController(text: provider.favoriteVerseRef);

    final social = provider.socialLinks ?? {};
    _youtubeController = TextEditingController(text: social['youtube']);
    _instagramController = TextEditingController(text: social['instagram']);
    _facebookController = TextEditingController(text: social['facebook']);
    _blogController = TextEditingController(text: social['blog']);

    _testimonyEnController = TextEditingController(text: provider.testimonyEn);
    _testimonyTeController = TextEditingController(text: provider.testimonyTe);

    _selectedMinistryRole = provider.ministryRole;
    _selectedAccentColor = provider.accentColor;
    _selectedShowcaseBadges.addAll(provider.showcaseBadges);

    _activityVisibility = provider.activityVisibility;
    _profileVisibility = provider.profileVisibility;
    _showPrayersOnProfile = provider.showPrayersOnProfile;
    _showTestimonyOnProfile = provider.showTestimonyOnProfile;

    if (_favVerseController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previewVerse();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioEnController.dispose();
    _bioTeController.dispose();
    _favVerseController.dispose();
    _youtubeController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _blogController.dispose();
    _testimonyEnController.dispose();
    _testimonyTeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBanner) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    final file = await picker.pickImage(
      source: source,
      maxWidth: isBanner ? 800 : 300,
      maxHeight: isBanner ? 400 : 300,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() {
      if (isBanner) {
        _bannerFile = File(file.path);
        _bannerUrl = null;
      } else {
        _avatarFile = File(file.path);
        _avatarType = 'custom';
        _photoURL = null;
        _defaultAvatarId = null;
      }
    });
  }

  Future<void> _previewVerse() async {
    final ref = _favVerseController.text.trim();
    if (ref.isEmpty) {
      setState(() {
        _favVersePreview = null;
      });
      return;
    }

    final currentLang = context.read<LocaleProvider>().locale.languageCode;
    try {
      final lastSpaceIdx = ref.lastIndexOf(' ');
      if (lastSpaceIdx == -1) {
        setState(() {
          _favVersePreview = "Invalid format. E.g., John 3:16";
        });
        return;
      }

      final bookName = ref.substring(0, lastSpaceIdx).trim();
      final refParts = ref.substring(lastSpaceIdx + 1).split(':');
      if (refParts.length != 2) {
        setState(() {
          _favVersePreview = "Invalid format. E.g., John 3:16";
        });
        return;
      }

      final chapter = int.tryParse(refParts[0]);
      final verse = int.tryParse(refParts[1]);
      if (chapter == null || verse == null) {
        setState(() {
          _favVersePreview = "Invalid chapter/verse.";
        });
        return;
      }

      final book = BibleService.findBookByName(bookName);
      if (book == null) {
        setState(() {
          _favVersePreview = "Book not found: '$bookName'";
        });
        return;
      }

      final verses = await BibleService.getChapter(book.id, chapter, currentLang);
      final verseText = verses[verse];
      if (verseText != null) {
        setState(() {
          _favVersePreview = "\"$verseText\" (${book.nameTe} $chapter:$verse)";
        });
      } else {
        final versesKjv = await BibleService.getChapter(book.id, chapter, 'kjv');
        final verseTextKjv = versesKjv[verse];
        if (verseTextKjv != null) {
          setState(() {
            _favVersePreview = "\"$verseTextKjv\" (${book.nameEn} $chapter:$verse)";
          });
        } else {
          setState(() {
            _favVersePreview = "Verse not found.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _favVersePreview = "Error fetching verse: $e";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userProvider = context.read<UserDataProvider>();
      final userId = userProvider.userId ?? 'mock_user';

      String? finalBannerUrl = _bannerUrl;
      if (_bannerFile != null) {
        finalBannerUrl = await FirebaseService.uploadProfileBanner(_bannerFile!, userId);
      }

      String? finalPhotoUrl = _photoURL;
      if (_avatarFile != null) {
        finalPhotoUrl = await FirebaseService.uploadProfileAvatar(_avatarFile!, userId);
      } else if (_avatarType == 'default' && _defaultAvatarId != null) {
        finalPhotoUrl = _defaultAvatarId;
      }

      final updates = <String, dynamic>{
        'displayName': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bannerUrl': finalBannerUrl,
        'bioEn': _bioEnController.text.trim().isEmpty ? null : _bioEnController.text.trim(),
        'bioTe': _bioTeController.text.trim().isEmpty ? null : _bioTeController.text.trim(),
        'favoriteVerseRef': _favVerseController.text.trim().isEmpty ? null : _favVerseController.text.trim(),
        'showcaseBadges': _selectedShowcaseBadges,
        'activityVisibility': _activityVisibility,
        'profileVisibility': _profileVisibility,
        'showPrayersOnProfile': _showPrayersOnProfile,
        'showTestimonyOnProfile': _showTestimonyOnProfile,
        'accentColor': _selectedAccentColor,
        'ministryRole': _selectedMinistryRole,
        'testimonyEn': _testimonyEnController.text.trim().isEmpty ? null : _testimonyEnController.text.trim(),
        'testimonyTe': _testimonyTeController.text.trim().isEmpty ? null : _testimonyTeController.text.trim(),
        'socialLinks': {
          'youtube': _youtubeController.text.trim(),
          'instagram': _instagramController.text.trim(),
          'facebook': _facebookController.text.trim(),
          'blog': _blogController.text.trim(),
        },
        'avatarType': _avatarType,
        'defaultAvatarId': _defaultAvatarId,
      };

      if (finalPhotoUrl != null) {
        updates['photoURL'] = finalPhotoUrl;
      }

      userProvider.updateProfile(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Outfit'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e', style: const TextStyle(fontFamily: 'Outfit'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildGlassCard({required Widget child, bool isGold = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isGold ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isGold ? const Color(0xFFF7BC64).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxChars,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxChars,
          style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
          validator: validator,
          buildCounter: maxChars == null
              ? null
              : (context, {required currentLength, required isFocused, maxLength}) => Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "$currentLength / $maxLength",
                      style: const TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'Outfit'),
                    ),
                  ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = context.select<UserDataProvider, List<Achievement>>((p) => p.achievements.where((a) => a.isUnlocked).toList());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0xFF38BDF8), blurRadius: 150, spreadRadius: 100)
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
            )
          else
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. BANNER SECTION
                      _buildSectionHeader("Profile Banner"),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _bannerFile != null
                                    ? Image.file(_bannerFile!, fit: BoxFit.cover)
                                    : _bannerUrl != null
                                        ? (_bannerUrl!.startsWith('assets/')
                                            ? Image.asset(_bannerUrl!, fit: BoxFit.cover)
                                            : Image.network(_bannerUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image))))
                                        : Container(
                                            color: Colors.white.withValues(alpha: 0.05),
                                            child: const Center(
                                              child: Text("No Banner Selected", style: TextStyle(color: Colors.white38, fontFamily: 'Outfit')),
                                            ),
                                          ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: ProfileAssets.banners.length,
                                itemBuilder: (context, idx) {
                                  final banner = ProfileAssets.banners[idx];
                                  final isSelected = _bannerUrl == banner && _bannerFile == null;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _bannerUrl = banner;
                                        _bannerFile = null;
                                      });
                                    },
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFF7BC64) : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(banner, fit: BoxFit.cover),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white12,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.upload, size: 16),
                              label: const Text("Upload from Gallery", style: TextStyle(fontFamily: 'Outfit')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. AVATAR SECTION
                      _buildSectionHeader("Avatar Image"),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: _avatarFile != null
                                        ? Image.file(_avatarFile!, fit: BoxFit.cover)
                                        : _photoURL != null
                                            ? (_photoURL!.startsWith('assets/')
                                                ? Image.asset(_photoURL!, fit: BoxFit.cover)
                                                : Image.network(_photoURL!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person)))
                                            : const Icon(Icons.person, size: 40, color: Colors.white30),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text("Choose Default Avatar", style: TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: ProfileAssets.avatars.length,
                              itemBuilder: (context, idx) {
                                final avatar = ProfileAssets.avatars[idx];
                                final isSelected = _avatarType == 'default' && _defaultAvatarId == avatar && _avatarFile == null;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _avatarType = 'default';
                                      _defaultAvatarId = avatar;
                                      _photoURL = avatar;
                                      _avatarFile = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFF7BC64) : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(avatar, fit: BoxFit.cover),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white12,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.photo_library, size: 16),
                              label: const Text("Upload Custom Photo", style: TextStyle(fontFamily: 'Outfit')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. NAME & USERNAME SECTION
                      _buildSectionHeader("Basic Information"),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: "Display Name",
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Display name cannot be empty";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _usernameController,
                              label: "Username",
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Username cannot be empty";
                                }
                                if (val.trim().length < 3) {
                                  return "Username must be at least 3 characters";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. BIO SECTION
                      _buildSectionHeader("Biographies"),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _bioEnController,
                              label: "English Bio (Max 150 characters)",
                              maxChars: 150,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _bioTeController,
                              label: "Telugu Bio (గరిష్టంగా 150 అక్షరాలు)",
                              maxChars: 150,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. FAVORITE VERSE SECTION
                      _buildSectionHeader("Favorite Bible Verse"),
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField(
                              controller: _favVerseController,
                              label: "Scripture Reference (e.g. John 3:16 or యోహాను 3:16)",
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _previewVerse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Preview Verse", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                            ),
                            if (_favVersePreview != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Text(
                                  _favVersePreview!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic, fontFamily: 'Outfit'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. MINISTRY ROLE SECTION
                      _buildSectionHeader("Ministry Role"),
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Your Role", style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF1E1E2E),
                              initialValue: _selectedMinistryRole,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.04),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'pastor', child: Text('Pastor')),
                                DropdownMenuItem(value: 'youth_leader', child: Text('Youth Leader')),
                                DropdownMenuItem(value: 'sunday_school_teacher', child: Text('Sunday School Teacher')),
                                DropdownMenuItem(value: 'church_member', child: Text('Church Member')),
                                DropdownMenuItem(value: 'student', child: Text('Student')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedMinistryRole = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 7. SOCIAL LINKS SECTION
                      _buildSectionHeader("Social Links"),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildTextField(controller: _youtubeController, label: "YouTube Link"),
                            const SizedBox(height: 12),
                            _buildTextField(controller: _instagramController, label: "Instagram Link"),
                            const SizedBox(height: 12),
                            _buildTextField(controller: _facebookController, label: "Facebook Link"),
                            const SizedBox(height: 12),
                            _buildTextField(controller: _blogController, label: "Blog / Website Link"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 8. TESTIMONY SECTION
                      _buildSectionHeader("Personal Testimony"),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _testimonyEnController,
                              label: "English Testimony (Max 1000 characters)",
                              maxChars: 1000,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _testimonyTeController,
                              label: "Telugu Testimony (గరిష్టంగా 1000 అక్షరాలు)",
                              maxChars: 1000,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 9. ACCENT COLOR SECTION
                      _buildSectionHeader("Accent Theme Color"),
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Choose Your Accent Color", style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _accentColorMap.length,
                              itemBuilder: (context, idx) {
                                final entry = _accentColorMap.entries.elementAt(idx);
                                final isSelected = _selectedAccentColor == entry.key;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedAccentColor = entry.key;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: entry.value,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: entry.value.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 10. BADGE SHOWCASE SECTION
                      _buildSectionHeader("Showcase Badges (Max 5)"),
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selected: ${_selectedShowcaseBadges.length} / 5",
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            if (unlockedAchievements.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Text("No badges unlocked yet.", style: TextStyle(color: Colors.white38, fontFamily: 'Outfit')),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: unlockedAchievements.length,
                                itemBuilder: (context, idx) {
                                  final ach = unlockedAchievements[idx];
                                  final isSelected = _selectedShowcaseBadges.contains(ach.id);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedShowcaseBadges.remove(ach.id);
                                        } else {
                                          if (_selectedShowcaseBadges.length < 5) {
                                            _selectedShowcaseBadges.add(ach.id);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('You can select a maximum of 5 badges', style: TextStyle(fontFamily: 'Outfit'))),
                                            );
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFF7BC64) : Colors.white10,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                                                          Icon(
                                            ach.icon,
                                            size: 24,
                                            color: isSelected ? const Color(0xFFF7BC64) : Colors.white70,
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              right: 2,
                                              top: 2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFF7BC64),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.check, size: 8, color: Color(0xFF442B00)),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 11. PRIVACY & VISIBILITY SECTION
                      _buildSectionHeader("Privacy Settings"),
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text("Profile Visibility", style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF1E1E2E),
                              initialValue: _profileVisibility,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.04),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'public', child: Text('Public')),
                                DropdownMenuItem(value: 'followers', child: Text('Followers Only')),
                                DropdownMenuItem(value: 'private', child: Text('Private')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _profileVisibility = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text("Activity Visibility", style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF1E1E2E),
                              initialValue: _activityVisibility,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.04),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'public', child: Text('Public')),
                                DropdownMenuItem(value: 'followers', child: Text('Followers Only')),
                                DropdownMenuItem(value: 'private', child: Text('Private')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _activityVisibility = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              activeThumbColor: const Color(0xFF38BDF8),
                              title: const Text("Show Prayers on Profile", style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Outfit')),
                              value: _showPrayersOnProfile,
                              onChanged: (val) {
                                setState(() {
                                  _showPrayersOnProfile = val;
                                });
                              },
                            ),
                            SwitchListTile(
                              activeThumbColor: const Color(0xFF38BDF8),
                              title: const Text("Show Testimony on Profile", style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Outfit')),
                              value: _showTestimonyOnProfile,
                              onChanged: (val) {
                                setState(() {
                                  _showTestimonyOnProfile = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // SAVE BUTTON
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
