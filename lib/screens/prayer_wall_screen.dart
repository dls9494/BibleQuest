import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prayer_request.dart';
import '../models/profile_title.dart';
import '../services/firebase_service.dart';
import '../services/activity_service.dart';
import '../services/analytics_service.dart';
import '../providers/user_data_provider.dart';
import '../widgets/floating_emoji.dart';

class PrayerWallScreen extends StatefulWidget {
  const PrayerWallScreen({super.key});

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen> {
  final TextEditingController _requestController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _showAnsweredOnly = false;


  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  void _showContextMenu(PrayerRequest request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              
              // Edit option
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.amber),
                title: const Text(
                  'Edit Prayer Request',
                  style: TextStyle(fontFamily: 'Outfit'),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditWithDeleteDialog(request);
                },
              ),
              
              // Delete option
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Prayer Request',
                  style: TextStyle(color: Colors.red, fontFamily: 'Outfit'),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteDialog(request.id);
                },
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditWithDeleteDialog(PrayerRequest request) async {
    final controller = TextEditingController(text: request.request);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5D4037);
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Edit Prayer Request',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 500,
                maxLines: 5,
                style: TextStyle(fontFamily: 'Outfit', color: textColor),
                decoration: InputDecoration(
                  hintText: 'Update your prayer request...',
                  hintStyle: TextStyle(
                    color: subTextColor.withValues(alpha: 0.6),
                    fontFamily: 'Outfit',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.amber.shade200 : const Color(0xFF6C4AB6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              // Delete button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showDeleteDialog(request.id);
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  label: Text(
                    'Delete Prayer Request',
                    style: TextStyle(color: Colors.red.shade300, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty && text != request.request) {
                Navigator.pop(ctx);
                _updateRequest(request.id, text);
              } else if (text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Prayer request cannot be empty', style: TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C4AB6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRequest(String requestId, String newText) async {
    try {
      await FirebaseService.updatePrayerRequest(requestId, newText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer request updated', style: TextStyle(fontFamily: 'Outfit')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e', style: const TextStyle(fontFamily: 'Outfit')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Delete Prayer Request?',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this prayer request? This cannot be undone.',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Outfit', color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await FirebaseService.deletePrayerRequest(requestId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prayer request deleted', style: TextStyle(fontFamily: 'Outfit')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e', style: const TextStyle(fontFamily: 'Outfit')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }




  Future<void> _submitRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to post prayer requests', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final requestText = _requestController.text.trim();
    if (requestText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a prayer request', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = context.read<UserDataProvider>();
      final userId = currentUser.uid;
      final userName = _isAnonymous ? 'Anonymous' : userProvider.displayName;

      await FirebaseService.submitPrayerRequest(userId, userName, requestText);
      // Analytics: prayer request created
      AnalyticsService.logPrayerRequestCreated();

      // Log activity
      await ActivityService.logActivity(
        userId,
        userName,
        'prayer_request',
        {
          'requestText': requestText,
        },
      );

      _requestController.clear();
      if (mounted) {
        setState(() {
          _isAnonymous = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer request posted successfully!', style: TextStyle(fontFamily: 'Outfit')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e', style: const TextStyle(fontFamily: 'Outfit')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildGlassCard({
    required Widget child,
    required BuildContext context,
    bool isSelected = false,
    bool isAnswered = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isAnswered
            ? (isDark ? const Color(0xFFD4AF37).withValues(alpha: 0.1) : const Color(0xFFFFF8E1))
            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnswered
              ? const Color(0xFFFFD700)
              : (isSelected
                  ? const Color(0xFF6C4AB6)
                  : (isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD4A574).withValues(alpha: 0.4))),
          width: isAnswered ? 2.0 : (isSelected ? 2 : 1),
        ),
        boxShadow: isAnswered
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            : (isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFilterTab(String text, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showAnsweredOnly = text == "Answered";
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (text == "Answered" ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFF6C4AB6).withValues(alpha: 0.2))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? (text == "Answered" ? Colors.amber : const Color(0xFF6C4AB6))
                  : (isDark ? Colors.white24 : Colors.black12),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive
                    ? (text == "Answered" ? Colors.amber : (isDark ? Colors.white : const Color(0xFF6C4AB6)))
                    : (isDark ? Colors.white60 : Colors.black54),
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5D4037);

    return Scaffold(
      body: Stack(
        children: [
          // Background Theme-Aware Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                    : const [Color(0xFFFDF6EC), Color(0xFFF3E7D8)],
              ),
            ),
          ),
          
          // Ambient background glow
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD4A574).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD4A574).withValues(alpha: 0.5),
                        blurRadius: 150,
                        spreadRadius: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.church_rounded, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6), size: 30),
                          const SizedBox(width: 10),
                          Text(
                            "Prayer Wall 🙏",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Share your prayer requests and pray for others",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.white24, height: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 4.0),
                  child: Row(
                    children: [
                      _buildFilterTab("All Requests", !_showAnsweredOnly),
                      const SizedBox(width: 12),
                      _buildFilterTab("Answered", _showAnsweredOnly),
                    ],
                  ),
                ),


                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    color: const Color(0xFF6C4AB6),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Submit Request Form Card
                          _buildGlassCard(
                            context: context,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Request Prayer",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _requestController,
                                    maxLength: 500,
                                    maxLines: 4,
                                    style: TextStyle(color: textColor, fontFamily: 'Outfit'),
                                    decoration: InputDecoration(
                                      hintText: "Enter your prayer request...",
                                      hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.6)),
                                      filled: true,
                                      fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark ? Colors.white24 : const Color(0xFFD4A574).withValues(alpha: 0.4),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Switch(
                                            value: _isAnonymous,
                                            onChanged: (val) {
                                              setState(() {
                                                _isAnonymous = val;
                                              });
                                            },
                                            activeThumbColor: const Color(0xFF6C4AB6),
                                          ),
                                          Text(
                                            "Post Anonymously",
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 14,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: _isSubmitting ? null : _submitRequest,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6C4AB6),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                              )
                                            : const Text(
                                                "Post Request",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 28),
                          
                          Text(
                            "Recent Prayer Requests",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 12),

                          // StreamBuilder for Prayer Requests
                          StreamBuilder<List<PrayerRequest>>(
                            stream: FirebaseService.getPrayerRequests(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(color: Color(0xFF6C4AB6)),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Error loading requests: ${snapshot.error}',
                                          style: const TextStyle(color: Colors.redAccent, fontFamily: 'Outfit'),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.refresh_rounded),
                                          label: const Text("Retry"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6C4AB6),
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              var list = snapshot.data ?? [];
                              if (_showAnsweredOnly) {
                                list = list.where((req) => req.isAnswered).toList();
                                list.sort((a, b) {
                                  final timeA = a.answeredAt ?? a.createdAt;
                                  final timeB = b.answeredAt ?? b.createdAt;
                                  return timeB.compareTo(timeA);
                                });
                              }
                              if (list.isEmpty) {

                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Text(
                                      'No prayer requests yet. Be the first to share!',
                                      style: TextStyle(color: subTextColor, fontFamily: 'Outfit', fontSize: 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final request = list[index];
                                  return PrayerRequestCard(
                                    request: request,
                                    currentUserId: currentUserId,
                                    isDark: isDark,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    onLongPress: _showContextMenu,
                                    onEditTap: _showEditWithDeleteDialog,
                                    buildGlassCard: _buildGlassCard,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

class _FloatingEmojiData {
  final Key key;
  final String emoji;
  final Offset position;

  _FloatingEmojiData({
    required this.key,
    required this.emoji,
    required this.position,
  });
}

class PrayerRequestCard extends StatefulWidget {
  final PrayerRequest request;
  final String currentUserId;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final Function(PrayerRequest) onLongPress;
  final Function(PrayerRequest) onEditTap;
  final Widget Function({
    required Widget child,
    required BuildContext context,
    bool isSelected,
    bool isAnswered,
  }) buildGlassCard;


  const PrayerRequestCard({
    super.key,
    required this.request,
    required this.currentUserId,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.onLongPress,
    required this.onEditTap,
    required this.buildGlassCard,
  });

  @override
  State<PrayerRequestCard> createState() => _PrayerRequestCardState();
}

class _PrayerRequestCardState extends State<PrayerRequestCard> {
  final GlobalKey _cardKey = GlobalKey();
  final List<_FloatingEmojiData> _floatingEmojis = [];

  void _spawnEmoji(String emoji, Offset globalPosition) {
    final RenderBox? renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final localPosition = renderBox.globalToLocal(globalPosition);
    final key = UniqueKey();
    
    setState(() {
      _floatingEmojis.add(_FloatingEmojiData(
        key: key,
        emoji: emoji,
        position: localPosition,
      ));
    });
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _floatingEmojis.removeWhere((item) => item.key == key);
        });
      }
    });
  }

  void _handleReaction(String reactionType, Offset globalPosition) async {
    if (widget.currentUserId.isEmpty) return;
    
    final emojiMap = {
      'praying': '🙏',
      'amen': '❤️',
      'encouraged': '🕊️',
    };
    final emoji = emojiMap[reactionType] ?? '🙏';
    _spawnEmoji(emoji, globalPosition);

    try {
      await FirebaseService.reactToPrayer(widget.request.id, widget.currentUserId, reactionType);
      // Analytics: prayer reaction
      AnalyticsService.logPrayerReaction();
    } catch (_) {}
  }

  void _showMarkAnsweredDialog() {
    final testimonyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Share Your Testimony", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How did God answer your prayer? Share it to encourage others! (Optional)",
              style: TextStyle(fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: testimonyController,
              maxLines: 3,
              style: TextStyle(fontFamily: 'Outfit', color: widget.textColor),
              decoration: InputDecoration(
                hintText: "Write your testimony...",
                hintStyle: TextStyle(color: widget.subTextColor.withValues(alpha: 0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final testimony = testimonyController.text.trim();
              Navigator.pop(ctx);
              try {
                await FirebaseService.markPrayerAnswered(widget.request.id, testimony);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Glory to God! Marked as answered."),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed: $e"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPrayed = widget.request.prayedByUserIds.contains(widget.currentUserId);
    final isOwner = widget.request.userId == widget.currentUserId;
    
    return Padding(
      key: _cardKey,
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onLongPress: isOwner ? () => widget.onLongPress(widget.request) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.buildGlassCard(
              context: context,
              isSelected: hasPrayed,
              isAnswered: widget.request.isAnswered,
              child: Padding(

                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.request.userName == 'Anonymous'
                                  ? Icons.visibility_off_rounded
                                  : Icons.account_circle_rounded,
                              color: hasPrayed
                                  ? const Color(0xFF6C4AB6)
                                  : (widget.isDark ? const Color(0xFF38BDF8) : const Color(0xFF5D4037)),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                String activeTitleName = '';
                                if (widget.request.userTitle.isNotEmpty) {
                                  final matchingTitle = ProfileTitle.allTitles.firstWhere(
                                    (t) => t.id == widget.request.userTitle,
                                    orElse: () => ProfileTitle(
                                      id: widget.request.userTitle,
                                      name: widget.request.userTitle.toUpperCase(),
                                      rarity: TitleRarity.common,
                                      description: '',
                                    ),
                                  );
                                  activeTitleName = matchingTitle.name;
                                }
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.request.userName + (activeTitleName.isNotEmpty ? " • $activeTitleName" : ""),
                                      style: TextStyle(
                                        color: widget.textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    if (widget.request.isAnswered) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.amber, width: 1),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("✅ ", style: TextStyle(fontSize: 10)),
                                            Text(
                                              "Answered",
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              _formatTimeAgo(widget.request.createdAt),
                              style: TextStyle(
                                color: widget.subTextColor.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            if (isOwner) const SizedBox(width: 24),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Request Text
                    Text(
                      widget.request.request,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 15,
                        height: 1.5,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    
                    if (widget.request.isAnswered) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text("✨ ", style: TextStyle(fontSize: 14)),
                                Text(
                                  "Testimony / సాక్ష్యం:",
                                  style: TextStyle(
                                    color: widget.textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.request.testimony ?? "Prayer was answered! Praise the Lord.",
                              style: TextStyle(
                                color: widget.textColor.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),

                    
                    // Reaction Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ReactionButton(
                          emoji: '🙏',
                          label: 'Praying',
                          count: widget.request.reactions['praying'] ?? 0,
                          isActive: widget.request.userReactions[widget.currentUserId] == 'praying',
                          onTap: (globalPos) => _handleReaction('praying', globalPos),
                        ),
                        _ReactionButton(
                          emoji: '❤️',
                          label: 'Amen',
                          count: widget.request.reactions['amen'] ?? 0,
                          isActive: widget.request.userReactions[widget.currentUserId] == 'amen',
                          onTap: (globalPos) => _handleReaction('amen', globalPos),
                        ),
                        _ReactionButton(
                          emoji: '🕊️',
                          label: 'Encouraged',
                          count: widget.request.reactions['encouraged'] ?? 0,
                          isActive: widget.request.userReactions[widget.currentUserId] == 'encouraged',
                          onTap: (globalPos) => _handleReaction('encouraged', globalPos),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Actions (Counts & Pray button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pray Count
                        Row(
                          children: [
                            const Text(
                              "🙏 ",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              widget.request.prayerCount == 0
                                  ? "Be the first to pray"
                                  : (widget.request.prayerCount == 1
                                      ? "Prayed by 1 person"
                                      : "Prayed by ${widget.request.prayerCount} people"),
                              style: TextStyle(
                                color: hasPrayed
                                    ? const Color(0xFF6C4AB6)
                                    : widget.subTextColor,
                                fontSize: 13,
                                fontWeight: hasPrayed ? FontWeight.bold : FontWeight.normal,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),

                        // Pray Button
                        _PrayActionButton(
                          requestId: widget.request.id,
                          hasPrayed: hasPrayed,
                          currentUserId: widget.currentUserId,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isOwner && !widget.request.isAnswered)
              Positioned(
                top: 8,
                right: 48,
                child: GestureDetector(
                  onTap: _showMarkAnsweredDialog,
                  child: Tooltip(
                    message: 'Mark as Answered',
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
            if (isOwner)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => widget.onEditTap(widget.request),

                  child: Tooltip(
                    message: 'Tap to edit or delete',
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.amber.shade200.withValues(alpha: 0.5)
                              : Colors.amber.shade700.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: widget.isDark ? Colors.amber.shade200 : Colors.amber.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            // Floating Emojis Overlay
            ..._floatingEmojis.map((emojiData) {
              return Positioned(
                key: emojiData.key,
                left: emojiData.position.dx - 14,
                top: emojiData.position.dy - 14,
                child: FloatingEmoji(
                  emoji: emojiData.emoji,
                  color: Colors.transparent,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final bool isActive;
  final Function(Offset) onTap;

  const _ReactionButton({
    required this.emoji,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textThemeColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return GestureDetector(
      onTapDown: (details) {
        onTap(details.globalPosition);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? (isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.1)) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.25),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: isActive ? Colors.amber : textThemeColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayActionButton extends StatefulWidget {
  final String requestId;
  final bool hasPrayed;
  final String currentUserId;

  const _PrayActionButton({
    required this.requestId,
    required this.hasPrayed,
    required this.currentUserId,
  });

  @override
  State<_PrayActionButton> createState() => _PrayActionButtonState();
}

class _PrayActionButtonState extends State<_PrayActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isClicking = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPray() async {
    if (widget.hasPrayed || _isClicking || widget.currentUserId.isEmpty) return;

    setState(() {
      _isClicking = true;
    });

    _animController.forward(from: 0.0);

    try {
      await FirebaseService.prayForRequest(widget.requestId, widget.currentUserId);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isClicking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: OutlinedButton.icon(
        onPressed: widget.hasPrayed ? null : _onPray,
        icon: Icon(
          widget.hasPrayed ? Icons.check_circle_outline_rounded : Icons.favorite_border_rounded,
          size: 16,
          color: widget.hasPrayed ? Colors.white : const Color(0xFF6C4AB6),
        ),
        label: Text(
          widget.hasPrayed ? "I Prayed" : "Pray",
          style: TextStyle(
            color: widget.hasPrayed ? Colors.white : const Color(0xFF6C4AB6),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Outfit',
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: widget.hasPrayed ? Colors.transparent : const Color(0xFF6C4AB6),
            width: 1.5,
          ),
          backgroundColor: widget.hasPrayed ? const Color(0xFF6C4AB6) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),
    );
  }
}

String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 5) {
    return 'Just now';
  } else if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  }
}
