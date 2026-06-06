import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/achievement.dart';
import '../models/profile_title.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/otp_input.dart';
import '../widgets/achievement_celebration.dart';
import '../providers/theme_provider.dart';
import 'bookmarks_screen.dart';
import 'wisdom_tree_screen.dart';
import 'bookmarked_verses_screen.dart';

class CountryCode {
  final String code;
  final String flag;
  final String name;

  const CountryCode({required this.code, required this.flag, required this.name});
}

const List<CountryCode> countryCodes = [
  CountryCode(code: "+91", flag: "🇮🇳", name: "India"),
  CountryCode(code: "+1", flag: "🇺🇸", name: "US"),
  CountryCode(code: "+44", flag: "🇬🇧", name: "UK"),
  CountryCode(code: "+61", flag: "🇦🇺", name: "Australia"),
  CountryCode(code: "+971", flag: "🇦🇪", name: "UAE"),
  CountryCode(code: "+65", flag: "🇸🇬", name: "Singapore"),
  CountryCode(code: "+94", flag: "🇱🇰", name: "Sri Lanka"),
  CountryCode(code: "+880", flag: "🇧🇩", name: "Bangladesh"),
  CountryCode(code: "+977", flag: "🇳🇵", name: "Nepal"),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loadingUser = false;
  bool _isSavingProfile = false;
  bool _controllersInitialized = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String? _referralCode;
  int _referralCount = 0;
  int _referralXp = 0;
  List<String> _referredUsers = [];
  bool _loadingReferrals = true;
  String? _loadedUserId;
  bool _achievementsExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReferralStats();
    });
  }

  void _loadReferralStats() async {
    final userProvider = context.read<UserDataProvider>();
    final uid = userProvider.userId;
    if (uid != null && uid != _loadedUserId) {
      _loadedUserId = uid;
      if (mounted) {
        setState(() {
          _loadingReferrals = true;
        });
      }
      try {
        final code = await FirebaseService.getReferralCode(uid);
        final stats = await FirebaseService.getReferralStats(uid);
        if (mounted && uid == _loadedUserId) {
          setState(() {
            _referralCode = code;
            _referralCount = stats.totalReferrals;
            _referralXp = stats.xpEarned;
            _referredUsers = stats.referredUsers;
            _loadingReferrals = false;
          });
        }
      } catch (e) {
        if (mounted && uid == _loadedUserId) {
          setState(() {
            _referralCode ??= 'WELCOME123';
            _loadingReferrals = false;
          });
        }
      }
    } else if (uid == null) {
      if (mounted) {
        setState(() {
          _referralCode = 'WELCOME123';
          _referralCount = 0;
          _referralXp = 0;
          _referredUsers = [];
          _loadingReferrals = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty', style: TextStyle(fontFamily: 'Outfit'))),
      );
      return;
    }

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 3 characters', style: TextStyle(fontFamily: 'Outfit'))),
      );
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    final isUnique = await FirebaseService.isUsernameUnique(username);
    if (!isUnique) {
      setState(() {
        _isSavingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken', style: TextStyle(fontFamily: 'Outfit'))),
        );
      }
      return;
    }

    await FirebaseService.updateProfile(name, username);

    if (mounted) {
      setState(() {
        _isSavingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Outfit'))),
      );
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
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
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
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
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() {
      _loadingUser = true;
    });

    final userId = await FirebaseService.getCurrentUserUid() ?? 'mock_user';
    await FirebaseService.uploadAvatar(userId, file);
    setState(() {
      _loadingUser = false;
    });
  }

  void _startEmailLinkingFlow() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool linking = false;
        String? linkError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: const Color(0xFF1E1E2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                title: const Text(
                  "Link Email Address",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (linkError != null) ...[
                      Text(linkError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontFamily: 'Outfit')),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Outfit'),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF38BDF8)), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Outfit'),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF38BDF8)), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
                  ),
                  ElevatedButton(
                    onPressed: linking ? null : () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) {
                        setDialogState(() {
                          linkError = "Please fill in email and password.";
                        });
                        return;
                      }
                      setDialogState(() {
                        linking = true;
                        linkError = null;
                      });
                      try {
                        await FirebaseService.linkEmailCredential(email, password);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email linked successfully!', style: TextStyle(fontFamily: 'Outfit'))),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          linking = false;
                          linkError = e.toString().replaceAll("Exception: ", "");
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                    child: linking
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("LINK", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startPhoneLinkingFlow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final phoneController = TextEditingController();
        CountryCode selectedCountry = countryCodes[0];
        bool sending = false;
        bool codeSent = false;
        String? verificationId;
        String enteredOtp = "";
        int cooldown = 0;
        Timer? timer;
        String? phoneError;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void startTimer() {
              timer?.cancel();
              setSheetState(() {
                cooldown = 30;
              });
              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (cooldown == 0) {
                  t.cancel();
                } else {
                  setSheetState(() {
                    cooldown--;
                  });
                }
              });
            }

            void sendOtp() async {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) {
                setSheetState(() {
                  phoneError = "Please enter your phone number.";
                });
                return;
              }
              if (selectedCountry.code == "+91" && phone.length != 10) {
                setSheetState(() {
                  phoneError = "Please enter a valid 10-digit phone number.";
                });
                return;
              }

              setSheetState(() {
                sending = true;
                phoneError = null;
              });

              final fullPhone = "${selectedCountry.code}$phone";
              try {
                await FirebaseService.verifyPhoneNumber(
                  phoneNumber: fullPhone,
                  onCodeSent: (vId, resendToken) {
                    setSheetState(() {
                      verificationId = vId;
                      codeSent = true;
                      sending = false;
                      startTimer();
                    });
                  },
                  onVerificationFailed: (e) {
                    setSheetState(() {
                      phoneError = e.message ?? e.toString();
                      sending = false;
                    });
                  },
                  onVerificationCompleted: (credential) async {
                    setSheetState(() {
                      sending = true;
                    });
                    try {
                      await FirebaseService.linkPhoneCredential(credential);
                      if (context.mounted) {
                        timer?.cancel();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Phone number linked successfully!', style: TextStyle(fontFamily: 'Outfit'))),
                        );
                      }
                    } catch (e) {
                      setSheetState(() {
                        phoneError = e.toString().replaceAll("Exception: ", "");
                        sending = false;
                      });
                    }
                  },
                );
              } catch (e) {
                setSheetState(() {
                  phoneError = e.toString().replaceAll("Exception: ", "");
                  sending = false;
                });
              }
            }

            void verifyOtp() async {
              if (enteredOtp.length < 6) {
                setSheetState(() {
                  phoneError = "Please enter a 6-digit OTP.";
                });
                return;
              }
              if (verificationId == null) {
                setSheetState(() {
                  phoneError = "Verification session expired.";
                });
                return;
              }
              setSheetState(() {
                sending = true;
                phoneError = null;
              });

              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: verificationId!,
                  smsCode: enteredOtp,
                );
                await FirebaseService.linkPhoneCredential(credential);
                if (context.mounted) {
                  timer?.cancel();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone number linked successfully!', style: TextStyle(fontFamily: 'Outfit'))),
                  );
                }
              } catch (e) {
                setSheetState(() {
                  phoneError = e.toString().replaceAll("Exception: ", "");
                  sending = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Link Phone Number",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (phoneError != null) ...[
                      Text(phoneError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontFamily: 'Outfit'), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                    ],
                    if (!codeSent) ...[
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: const Color(0xFF1E1E2E),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                builder: (ctx) {
                                  return SafeArea(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: countryCodes.length,
                                      itemBuilder: (ctx, idx) {
                                        final c = countryCodes[idx];
                                        return ListTile(
                                          leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                                          title: Text(c.name, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit')),
                                          trailing: Text(c.code, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                                          onTap: () {
                                            setSheetState(() {
                                              selectedCountry = c;
                                            });
                                            Navigator.pop(ctx);
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Text(selectedCountry.flag, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(selectedCountry.code, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 14)),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                                decoration: const InputDecoration(
                                  hintText: "Phone Number",
                                  hintStyle: TextStyle(color: Colors.white30, fontFamily: 'Outfit'),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: sending ? null : sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: sending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("SEND VERIFICATION CODE", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      ),
                    ] else ...[
                      const Text(
                        "Enter the 6-digit OTP code sent to your phone:",
                        style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OtpInputWidget(
                        length: 6,
                        onChanged: (val) {
                          enteredOtp = val;
                        },
                        onCompleted: (val) {
                          enteredOtp = val;
                          verifyOtp();
                        },
                      ),
                      const SizedBox(height: 20),
                      if (cooldown > 0)
                        Text(
                          "Resend OTP in $cooldown seconds",
                          style: const TextStyle(color: Colors.white60, fontFamily: 'Outfit', fontSize: 13),
                          textAlign: TextAlign.center,
                        )
                      else
                        TextButton(
                          onPressed: sendOtp,
                          child: const Text("Resend OTP", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: sending ? null : verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: sending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("VERIFY OTP", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            title: const Text(
              "Delete Account?",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            content: const Text(
              "This action is permanent and cannot be undone. All your stats, scores, achievements, and quizzes will be deleted forever.",
              style: TextStyle(color: Colors.white70, fontFamily: 'Outfit'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _loadingUser = true;
                  });
                  final userId = await FirebaseService.getCurrentUserUid() ?? 'mock_user';
                  await FirebaseService.deleteAccount(userId);
                  await FirebaseService.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/auth');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "DELETE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUserInitials(String name) {
    if (name.isEmpty) return "G";
    final parts = name.split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildAvatarImage(String url, double size, String name) {
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64Str = url.split('base64,')[1];
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              _getUserInitials(name),
              style: TextStyle(color: Colors.white, fontSize: size * 0.32, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
          ),
        );
      } catch (_) {}
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Text(
          _getUserInitials(name),
          style: TextStyle(color: Colors.white, fontSize: size * 0.32, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showAchievementCelebration(BuildContext context, Achievement achievement, UserDataProvider userProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AchievementCelebrationDialog(
          achievement: achievement,
          onContinue: () {
            userProvider.clearNewlyUnlocked();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (!_controllersInitialized && userProvider.username != "guest_username" && userProvider.displayName != "Guest Player") {
      _nameController.text = userProvider.displayName;
      _usernameController.text = userProvider.username;
      _controllersInitialized = true;
    } else if (!_controllersInitialized) {
      _nameController.text = userProvider.displayName;
      _usernameController.text = userProvider.username;
      if (userProvider.displayName != "Guest Player") {
        _controllersInitialized = true;
      }
    }

    if (userProvider.userId != _loadedUserId && userProvider.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadReferralStats();
      });
    }

    final displayName = userProvider.displayName;
    final username = userProvider.username;
    final email = userProvider.email;
    final photoURL = userProvider.photoURL;

    if (_loadingUser) {
      return const Scaffold(
        backgroundColor: Color(0xFF121414),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }

    // Trigger Newly Unlocked Achievement Celebration Overlay
    final newlyUnlocked = userProvider.newlyUnlocked;
    if (newlyUnlocked != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAchievementCelebration(context, newlyUnlocked, userProvider);
      });
    }

    final level = userProvider.playerLevel;
    final totalXp = userProvider.totalXp;
    final streak = userProvider.streakDays;
    final quizzes = userProvider.quizHighScores.length;
    
    // Filter and compute achievement counts
    final unlockedAchievements = userProvider.achievements.where((a) => a.isUnlocked).toList();
    final badgesCount = unlockedAchievements.length;

    return Scaffold(
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
          // Luminous background elements
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF38BDF8),
                        blurRadius: 150,
                        spreadRadius: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Header Title
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Avatar & Display Name
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: ClipOval(
                                child: photoURL != null && photoURL.isNotEmpty
                                    ? _buildAvatarImage(photoURL, 100, displayName)
                                    : Center(
                                        child: Text(
                                          _getUserInitials(displayName),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0284C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7BC64),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Text(
                                  "Lvl $level",
                                  style: const TextStyle(
                                    color: Color(0xFF442B00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@$username",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF38BDF8),
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (userProvider.activeTitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showTitleSelector(context, userProvider),
                          child: _buildTitleBadge(userProvider.activeTitle),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showTitleSelector(context, userProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Tap to Select Title ✝",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFCBC3D4),
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 🌳 Wisdom Tree Card
                  _buildGlassCard(
                    isGold: true,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WisdomTreeScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF81C784).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.park_rounded,
                                color: Color(0xFF81C784),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "🌳 My Wisdom Tree",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Current Stage: ${userProvider.getTreeGrowthProgress()['stage']}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white30,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Friend Referral Card (moved before achievements)
                  _buildReferralCard(context),
                  const SizedBox(height: 28),

                  // Horizontal scrollable ribbon for unlocked achievements
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
                    child: Text(
                      "Unlocked Badges",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  _buildUnlockedRibbon(unlockedAchievements),
                  const SizedBox(height: 28),

                  // Collapsible "View All Achievements" section
                  _buildGlassCard(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _achievementsExpanded = !_achievementsExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded, color: Color(0xFFF7BC64), size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  "View All Achievements (${unlockedAchievements.length} unlocked)",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _achievementsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _achievementsExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              _buildAllAchievementsList(userProvider.achievements),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 28),

                  // Stats Grid Card
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
                    child: Text(
                      "User Statistics",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  _buildGlassCard(
                    isGold: true,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildStatItem("Total XP", "$totalXp"),
                          _buildStatItem("Streak", "$streak days"),
                          _buildStatItem("Quizzes", "$quizzes"),
                          _buildStatItem("Badges", "$badgesCount"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Account Information Card (moved below Stats Cards)
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
                    child: Text(
                      "Account Information",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  _buildGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Display Name Field
                          const Text(
                            "Display Name",
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                            decoration: InputDecoration(
                              hintText: "Enter display name",
                              hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Outfit'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          ),
                          const SizedBox(height: 16),
                          // Username Field
                          const Text(
                            "Username",
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                            decoration: InputDecoration(
                              hintText: "Enter username",
                              hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Outfit'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          ),
                          const SizedBox(height: 20),
                          if (userProvider.authMethod == 'email' || userProvider.authMethod == 'both') ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Email Address",
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.check, size: 10, color: Color(0xFF10B981)),
                                      SizedBox(width: 2),
                                      Text(
                                        "Verified",
                                        style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: false,
                              controller: TextEditingController(text: userProvider.email),
                              style: const TextStyle(color: Colors.white54, fontFamily: 'Outfit'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.02),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            const Text(
                              "Email Address",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _startEmailLinkingFlow,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Not Linked",
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'Outfit'),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.link, size: 16, color: Color(0xFF38BDF8)),
                                        SizedBox(width: 4),
                                        Text(
                                          "LINK EMAIL",
                                          style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Outfit'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (userProvider.authMethod == 'phone' || userProvider.authMethod == 'both') ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Phone Number",
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.check, size: 10, color: Color(0xFF10B981)),
                                      SizedBox(width: 2),
                                      Text(
                                        "Verified",
                                        style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: false,
                              controller: TextEditingController(text: userProvider.phoneNumber ?? ''),
                              style: const TextStyle(color: Colors.white54, fontFamily: 'Outfit'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.02),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            const Text(
                              "Phone Number",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _startPhoneLinkingFlow,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Not Linked",
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'Outfit'),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.link, size: 16, color: Color(0xFF38BDF8)),
                                        SizedBox(width: 4),
                                        Text(
                                          "LINK PHONE",
                                          style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Outfit'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          // Save Button
                          ElevatedButton(
                            onPressed: _isSavingProfile ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            child: _isSavingProfile
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'SAVE CHANGES',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Outfit'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // My Bookmarks Card
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
                    child: Text(
                      "My Bookmarks",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarksScreen(),
                              ),
                            );
                          },
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.bookmark_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "📚 Saved Questions",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${userProvider.bookmarkedQuestionIds.length} questions saved for review",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white30,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 1,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarkedVersesScreen(),
                              ),
                            );
                          },
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.bookmark_added_rounded,
                                    color: Color(0xFF10B981),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "📖 Saved Verses",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${userProvider.bookmarkedVerseRefs.length} verses bookmarked",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white30,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 1v1 Battle History Stats Card
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
                    child: Text(
                      "1v1 Battle Stats",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  _buildGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBattleStatItem("Played", "${userProvider.battlesPlayed}", Colors.blue),
                          _buildBattleStatItem("Won", "${userProvider.battlesWon}", Colors.green),
                          _buildBattleStatItem("Lost", "${userProvider.battlesLost}", Colors.red),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Settings / Language Display Mode Card
                  _buildGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Content Display Mode",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF3E2723),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ContentLanguageMode>(
                            dropdownColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E2020)
                                : Colors.white,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF3E2723),
                              fontFamily: 'Outfit',
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : const Color(0xFFD4A574).withValues(alpha: 0.4),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF6C4AB6),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.white,
                            ),
                            initialValue: localeProvider.contentMode,
                            items: [
                              DropdownMenuItem(
                                value: ContentLanguageMode.english,
                                child: Text(
                                  'English Only',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: ContentLanguageMode.telugu,
                                child: Text(
                                  'Telugu Only (తెలుగు)',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: ContentLanguageMode.bilingual,
                                child: Text(
                                  'Bilingual',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                localeProvider.setContentMode(val);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white24
                                : const Color(0xFFD4A574).withValues(alpha: 0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    themeProvider.themeMode == ThemeMode.dark
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: themeProvider.themeMode == ThemeMode.dark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF6C4AB6),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Dark Mode",
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF3E2723),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: themeProvider.themeMode == ThemeMode.dark,
                                activeThumbColor: const Color(0xFF38BDF8),
                                activeTrackColor: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                inactiveThumbColor: const Color(0xFF6C4AB6),
                                inactiveTrackColor: const Color(0xFF6C4AB6).withValues(alpha: 0.2),
                                onChanged: (val) {
                                  themeProvider.toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Out Button
                  InkWell(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await FirebaseService.signOut();
                      navigator.pushReplacementNamed('/auth');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB4AB).withValues(alpha: 0.5)),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Out",
                          style: TextStyle(
                            color: Color(0xFFFFB4AB),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete Account Button
                  InkWell(
                    onTap: _showDeleteAccountDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: const Center(
                        child: Text(
                          "Delete Account",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Padding behind the bottom navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedRibbon(List<Achievement> unlocked) {
    if (unlocked.isEmpty) {
      return _buildGlassCard(
        child: Container(
          height: 90,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            "Complete quizzes to earn badges!",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontFamily: 'Outfit',
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: unlocked.length,
        itemBuilder: (context, index) {
          final a = unlocked[index];
          return Container(
            width: 170,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == unlocked.length - 1 ? 0 : 8,
            ),
            child: _buildGlassCard(
              isGold: true,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        a.icon,
                        color: Colors.amber.shade400,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Unlocked",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllAchievementsList(List<Achievement> achievements) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        final double progressPct = (a.currentProgress / a.requiredCount).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Opacity(
            opacity: a.isUnlocked ? 1.0 : 0.6,
            child: _buildGlassCard(
              isGold: a.isUnlocked,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: a.isUnlocked
                            ? Colors.amber.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                      child: Icon(
                        a.icon,
                        color: a.isUnlocked ? Colors.amber.shade400 : Colors.grey.shade500,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Achievement Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: TextStyle(
                              color: a.isUnlocked ? Colors.amber.shade100 : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Custom Gradient Progress Bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  children: [
                                    Container(
                                      width: constraints.maxWidth * progressPct,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.grey.shade600, Colors.amber.shade400],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Progress Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a.type == 'speed' && a.currentProgress == 999
                                    ? "No record yet"
                                    : (a.type == 'speed'
                                        ? "${a.currentProgress}s / ${a.requiredCount}s"
                                        : "${a.currentProgress} / ${a.requiredCount}"),
                                style: TextStyle(
                                  color: a.isUnlocked ? Colors.amber.shade300 : Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              if (a.dateUnlocked != null)
                                Text(
                                  "${a.dateUnlocked!.day}/${a.dateUnlocked!.month}/${a.dateUnlocked!.year}",
                                  style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 9,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Lock / Unlock State Icon
                    Icon(
                      a.isUnlocked ? Icons.check_circle : Icons.lock,
                      color: a.isUnlocked ? Colors.amber : Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFCBC3D4),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF7BC64),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildBattleStatItem(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFCBC3D4),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child, bool isGold = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isGold ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isGold ? const Color(0xFFF7BC64).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Profile Titles UI Helpers ──

  Widget _buildTitleBadge(String titleId) {
    if (titleId.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final title = ProfileTitle.allTitles.firstWhere(
      (t) => t.id == titleId,
      orElse: () => ProfileTitle(id: titleId, name: titleId.toUpperCase(), rarity: TitleRarity.common, description: ''),
    );

    Color textColor = Colors.white;
    List<Color> gradientColors;
    bool isLegendary = false;

    switch (title.rarity) {
      case TitleRarity.common:
        gradientColors = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
        break;
      case TitleRarity.rare:
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF6366F1)];
        break;
      case TitleRarity.epic:
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        textColor = const Color(0xFF3E2723);
        break;
      case TitleRarity.legendary:
        isLegendary = true;
        gradientColors = [
          const Color(0xFFEC4899),
          const Color(0xFF8B5CF6),
          const Color(0xFF3B82F6),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
          const Color(0xFFEC4899),
        ];
        break;
    }

    if (isLegendary) {
      return AnimatedRainbowBadge(titleName: title.name);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(
        title.name,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontFamily: 'Outfit',
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showTitleSelector(BuildContext context, UserDataProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Select Display Title",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ProfileTitle.allTitles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = provider.activeTitle.isEmpty;
                        return ListTile(
                          onTap: () {
                            provider.setActiveTitle("");
                            Navigator.pop(context);
                          },
                          leading: Icon(
                            Icons.block,
                            color: isSelected ? const Color(0xFF38BDF8) : Colors.white54,
                          ),
                          title: Text(
                            "None",
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                              fontFamily: 'Outfit',
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8))
                              : null,
                        );
                      }

                      final title = ProfileTitle.allTitles[index - 1];
                      final isUnlocked = provider.unlockedTitles.contains(title.id);
                      final isSelected = provider.activeTitle == title.id;

                      Color rarityColor;
                      switch (title.rarity) {
                        case TitleRarity.common:
                          rarityColor = Colors.grey;
                          break;
                        case TitleRarity.rare:
                          rarityColor = const Color(0xFF3B82F6);
                          break;
                        case TitleRarity.epic:
                          rarityColor = const Color(0xFFF59E0B);
                          break;
                        case TitleRarity.legendary:
                          rarityColor = const Color(0xFFEC4899);
                          break;
                      }

                      return ListTile(
                        onTap: isUnlocked
                            ? () {
                                provider.setActiveTitle(title.id);
                                Navigator.pop(context);
                              }
                            : null,
                        leading: Icon(
                          isUnlocked ? Icons.workspace_premium_rounded : Icons.lock_rounded,
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : (isUnlocked ? rarityColor : Colors.white24),
                        ),
                        title: Text(
                          title.name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : (isUnlocked ? Colors.white : Colors.white38),
                            fontFamily: 'Outfit',
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          title.description,
                          style: TextStyle(
                            color: isUnlocked ? Colors.white54 : Colors.white24,
                            fontFamily: 'Outfit',
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8))
                            : (isUnlocked
                                ? null
                                : const Icon(Icons.lock_outline, color: Colors.white24)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Referral Card UI Helpers ──

  Widget _buildReferralCard(BuildContext context) {
    if (_loadingReferrals) {
      return _buildGlassCard(
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF7BC64), // Gold
            Color(0xFFF59E0B), // Darker Gold/Amber
            Color(0xFFD97706), // Even darker gold
            Color(0xFFF7BC64), // Gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5), // Border width
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 20 : 0, sigmaY: isDark ? 20 : 0),
          child: Container(
            color: isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: Color(0xFFF7BC64), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "Invite Friends & Earn XP 🎁",
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF3E2723),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: Color(0xFF38BDF8), size: 20),
                      onPressed: () async {
                        final shareText = "Join me on Bible Quiz! Play games, study scripture and learn together. Use my referral code: ${_referralCode ?? 'WELCOME123'} to get +100 XP! Download now: https://biblequizapp.page.link/join";
                        await Share.share(shareText);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Share your code. When friends join, you both get +100 XP!",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                    fontSize: 13,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4A574).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _referralCode ?? 'WELCOME123',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _referralCode ?? 'WELCOME123'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Referral code copied to clipboard!", style: TextStyle(fontFamily: 'Outfit')),
                                    backgroundColor: Color(0xFF0284C7),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text("Copy Code", style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                foregroundColor: isDark ? Colors.white : const Color(0xFF3E2723),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final shareText = "Join me on Bible Quiz! Play games, study scripture and learn together. Use my referral code: ${_referralCode ?? 'WELCOME123'} to get +100 XP! Download now: https://biblequizapp.page.link/join";
                                await Share.share(shareText);
                              },
                              icon: const Icon(Icons.share_rounded, size: 16),
                              label: const Text("Share Code", style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "👥 $_referralCount friends joined",
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF3E2723),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      "⭐ $_referralXp XP earned",
                      style: TextStyle(
                        color: const Color(0xFFF7BC64),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                
                if (_referredUsers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white10 : const Color(0xFFD4A574).withValues(alpha: 0.2)),
                  const SizedBox(height: 8),
                  Text(
                    "Referred Friends:",
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF5D4037),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_referredUsers.length, (index) {
                    return ReferredUserWidget(
                      userId: _referredUsers[index],
                      index: index + 1,
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReferredUserWidget extends StatelessWidget {
  final String userId;
  final int index;
  const ReferredUserWidget({super.key, required this.userId, required this.index});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "• Friend #$index (loading...)",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontFamily: 'Outfit',
                fontSize: 14,
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final name = data?['displayName'] ?? data?['username'] ?? "Friend #$index";
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "• $name",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            "• Friend #$index",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontFamily: 'Outfit',
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedRainbowBadge extends StatefulWidget {
  final String titleName;
  const AnimatedRainbowBadge({super.key, required this.titleName});

  @override
  State<AnimatedRainbowBadge> createState() => _AnimatedRainbowBadgeState();
}

class _AnimatedRainbowBadgeState extends State<AnimatedRainbowBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: const [
                Color(0xFFEF4444),
                Color(0xFFF59E0B),
                Color(0xFF10B981),
                Color(0xFF3B82F6),
                Color(0xFF8B5CF6),
                Color(0xFFEF4444),
              ],
              transform: GradientRotation(_controller.value * 2 * pi),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Text(
            widget.titleName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'Outfit',
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
