import '../widgets/gradient_background.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
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
import '../providers/theme_provider.dart';
import 'bookmarks_screen.dart';
import 'wisdom_tree_screen.dart';
import 'bookmarked_verses_screen.dart';
import 'edit_profile_screen.dart';
import '../services/bible_service.dart';

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
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ignore: unused_field
  bool _loadingUser = false;
  // ignore: unused_field
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

  // New viewed profile fields
  bool get _isOwnProfile => widget.userId == null || widget.userId == FirebaseAuth.instance.currentUser?.uid;
  Map<String, dynamic>? _viewedUserData;
  bool _loadingViewedUser = false;
  bool _isFollowing = false;
  static final Set<String> _viewedUserIds = {};
  bool _testimonyExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReferralStats();
      _loadProfileIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _loadProfileIfNeeded();
    }
  }

  void _loadProfileIfNeeded() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetUid = widget.userId;

    if (targetUid != null && targetUid != currentUid) {
      if (mounted) {
        setState(() {
          _loadingViewedUser = true;
        });
      }

      try {
        final data = await FirebaseService.getUserById(targetUid);
        bool following = false;
        if (currentUid != null) {
          following = await FirebaseService.isFollowing(currentUid, targetUid);
        }

        if (mounted) {
          setState(() {
            _viewedUserData = data;
            _isFollowing = following;
            _loadingViewedUser = false;
          });
        }

        // View Counter Logic
        if (!_viewedUserIds.contains(targetUid)) {
          _viewedUserIds.add(targetUid);
          await FirebaseFirestore.instance.collection('users').doc(targetUid).update({
            'profileViews': FieldValue.increment(1),
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loadingViewedUser = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _viewedUserData = null;
          _loadingViewedUser = false;
        });
      }
    }
  }

  void _loadReferralStats() async {
    final userProvider = context.read<UserDataProvider>();
    final uid = _isOwnProfile ? userProvider.userId : widget.userId;
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

  dynamic _getProfileValue(String key, dynamic defaultValue) {
    if (_isOwnProfile) {
      final provider = context.read<UserDataProvider>();
      switch (key) {
        case 'displayName': return provider.displayName;
        case 'username': return provider.username;
        case 'email': return provider.email;
        case 'photoURL': return provider.photoURL;
        case 'bannerUrl': return provider.bannerUrl;
        case 'bioEn': return provider.bioEn;
        case 'bioTe': return provider.bioTe;
        case 'favoriteVerseRef': return provider.favoriteVerseRef;
        case 'showcaseBadges': return provider.showcaseBadges;
        case 'activityVisibility': return provider.activityVisibility;
        case 'profileVisibility': return provider.profileVisibility;
        case 'showPrayersOnProfile': return provider.showPrayersOnProfile;
        case 'showTestimonyOnProfile': return provider.showTestimonyOnProfile;
        case 'accentColor': return provider.accentColor;
        case 'ministryRole': return provider.ministryRole;
        case 'testimonyEn': return provider.testimonyEn;
        case 'testimonyTe': return provider.testimonyTe;
        case 'socialLinks': return provider.socialLinks;
        case 'profileViews': return provider.profileViews;
        case 'avatarType': return provider.avatarType;
        case 'defaultAvatarId': return provider.defaultAvatarId;
        case 'playerLevel': return provider.playerLevel;
        case 'totalXp': return provider.totalXp;
        case 'streakDays': return provider.streakDays;
        case 'quizCount': return provider.quizHighScores.length;
        case 'battlesPlayed': return provider.battlesPlayed;
        case 'battlesWon': return provider.battlesWon;
        case 'battlesLost': return provider.battlesLost;
        case 'activeTitle': return provider.activeTitle;
      }
    } else if (_viewedUserData != null) {
      switch (key) {
        case 'displayName': return _viewedUserData!['displayName'] ?? "Guest Player";
        case 'username': return _viewedUserData!['username'] ?? "guest_username";
        case 'email': return _viewedUserData!['email'] ?? "";
        case 'photoURL': return _viewedUserData!['photoURL'];
        case 'bannerUrl': return _viewedUserData!['bannerUrl'];
        case 'bioEn': return _viewedUserData!['bioEn'];
        case 'bioTe': return _viewedUserData!['bioTe'];
        case 'favoriteVerseRef': return _viewedUserData!['favoriteVerseRef'];
        case 'showcaseBadges': return List<String>.from(_viewedUserData!['showcaseBadges'] ?? []);
        case 'activityVisibility': return _viewedUserData!['activityVisibility'] ?? 'public';
        case 'profileVisibility': return _viewedUserData!['profileVisibility'] ?? 'public';
        case 'showPrayersOnProfile': return _viewedUserData!['showPrayersOnProfile'] ?? true;
        case 'showTestimonyOnProfile': return _viewedUserData!['showTestimonyOnProfile'] ?? true;
        case 'accentColor': return _viewedUserData!['accentColor'] ?? 'gold';
        case 'ministryRole': return _viewedUserData!['ministryRole'];
        case 'testimonyEn': return _viewedUserData!['testimonyEn'];
        case 'testimonyTe': return _viewedUserData!['testimonyTe'];
        case 'socialLinks': return _viewedUserData!['socialLinks'] != null ? Map<String, String>.from(_viewedUserData!['socialLinks']) : null;
        case 'profileViews': return _viewedUserData!['profileViews'] ?? 0;
        case 'avatarType': return _viewedUserData!['avatarType'] ?? 'custom';
        case 'defaultAvatarId': return _viewedUserData!['defaultAvatarId'];
        case 'playerLevel': return 1 + ((_viewedUserData!['totalXp'] ?? 0) as int) ~/ 1000;
        case 'totalXp': return _viewedUserData!['totalXp'] ?? 0;
        case 'streakDays': return _viewedUserData!['streak'] ?? 0;
        case 'quizCount': return (_viewedUserData!['quizHighScores'] as Map?)?.length ?? 0;
        case 'battlesPlayed': return _viewedUserData!['battlesPlayed'] ?? 0;
        case 'battlesWon': return _viewedUserData!['battlesWon'] ?? 0;
        case 'battlesLost': return _viewedUserData!['battlesLost'] ?? 0;
        case 'activeTitle': return _viewedUserData!['activeTitle'] ?? '';
      }
    }
    return defaultValue;
  }

  Color _getAccentColor() {
    final colorStr = _getProfileValue('accentColor', 'gold') as String;
    switch (colorStr) {
      case 'blue': return const Color(0xFF38BDF8);
      case 'green': return const Color(0xFF4ADE80);
      case 'purple': return const Color(0xFFC084FC);
      case 'rose': return const Color(0xFFFB7185);
      case 'silver': return const Color(0xFFCBD5E1);
      case 'gold':
      default:
        return const Color(0xFFF7BC64);
    }
  }

  // ignore: unused_element
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

  // ignore: unused_element
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

  // ignore: unused_element
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

  // ignore: unused_element
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
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
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

  Widget _buildHeader(String? bannerUrl, String? photoURL, String displayName, String username, String? ministryRole, int level) {
    final accentColor = _getAccentColor();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Banner
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: bannerUrl != null
                    ? (bannerUrl.startsWith('assets/')
                        ? Image.asset(bannerUrl, fit: BoxFit.cover)
                        : Image.network(bannerUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/banners/sunrise.jpg', fit: BoxFit.cover)))
                    : Image.asset('assets/banners/sunrise.jpg', fit: BoxFit.cover),
              ),
            ),
            // Avatar overlapping
            Positioned(
              bottom: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1E2E),
                  border: Border.all(color: accentColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
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
            ),
            // Level badge overlapping bottom-right of avatar
            Positioned(
              bottom: -54,
              child: Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    "Lvl $level",
                    style: const TextStyle(
                      color: Color(0xFF442B00),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60), // Space for overlapping avatar
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
          style: TextStyle(
            fontSize: 16,
            color: accentColor,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
          ),
        ),
        if (ministryRole != null) ...[
          const SizedBox(height: 8),
          _buildMinistryRoleBadge(ministryRole),
        ],
      ],
    );
  }

  Widget _buildMinistryRoleBadge(String? role) {
    if (role == null) return const SizedBox.shrink();

    String title = "";
    IconData icon = Icons.person;
    switch (role) {
      case 'pastor':
        title = "Pastor";
        icon = Icons.church_rounded;
        break;
      case 'youth_leader':
        title = "Youth Leader";
        icon = Icons.group_rounded;
        break;
      case 'sunday_school_teacher':
        title = "Sunday School Teacher";
        icon = Icons.school_rounded;
        break;
      case 'church_member':
        title = "Church Member";
        icon = Icons.people_alt_rounded;
        break;
      case 'student':
        title = "Student";
        icon = Icons.menu_book_rounded;
        break;
      case 'other':
      default:
        title = "Ministry Helper";
        icon = Icons.favorite_rounded;
        break;
    }

    final accentColor = _getAccentColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accentColor),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(Map<String, String>? links) {
    if (links == null || links.values.every((v) => v.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final youtube = links['youtube']?.trim() ?? "";
    final instagram = links['instagram']?.trim() ?? "";
    final facebook = links['facebook']?.trim() ?? "";
    final blog = links['blog']?.trim() ?? "";

    Widget buildSocialIcon(IconData icon, String url, Color color) {
      if (url.isEmpty) return const SizedBox.shrink();
      return IconButton(
        icon: Icon(icon, color: color),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening link: $url', style: const TextStyle(fontFamily: 'Outfit'))),
          );
        },
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSocialIcon(Icons.video_library_rounded, youtube, Colors.red),
        buildSocialIcon(Icons.photo_camera_rounded, instagram, Colors.pinkAccent),
        buildSocialIcon(Icons.facebook_rounded, facebook, Colors.blueAccent),
        buildSocialIcon(Icons.language_rounded, blog, Colors.tealAccent),
      ],
    );
  }

  Widget _buildFavoriteVerseCard(String? ref) {
    if (ref == null || ref.isEmpty) return const SizedBox.shrink();

    final currentLang = context.read<LocaleProvider>().locale.languageCode;

    return FutureBuilder<String?>(
      future: () async {
        try {
          final lastSpaceIdx = ref.lastIndexOf(' ');
          if (lastSpaceIdx == -1) return null;
          final bookName = ref.substring(0, lastSpaceIdx).trim();
          final refParts = ref.substring(lastSpaceIdx + 1).split(':');
          if (refParts.length != 2) return null;
          final chapter = int.tryParse(refParts[0]);
          final verse = int.tryParse(refParts[1]);
          if (chapter == null || verse == null) return null;

          final book = BibleService.findBookByName(bookName);
          if (book == null) return null;

          final verses = await BibleService.getChapter(book.id, chapter, currentLang);
          final txt = verses[verse];
          if (txt != null) {
            return "\"$txt\" (${book.nameTe} $chapter:$verse)";
          }
          // fallback
          final versesKjv = await BibleService.getChapter(book.id, chapter, 'kjv');
          final txtKjv = versesKjv[verse];
          if (txtKjv != null) {
            return "\"$txtKjv\" (${book.nameEn} $chapter:$verse)";
          }
        } catch (_) {}
        return null;
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final accentColor = _getAccentColor();

        return _buildGlassCard(
          isGold: true,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote_rounded, color: accentColor, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      "Favorite Verse",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    fontFamily: 'Outfit',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeShowcase(List<String> badgeIds) {
    if (badgeIds.isEmpty) return const SizedBox.shrink();

    final allAchievements = Achievement.allAchievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
          child: Text(
            "Badge Showcase",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badgeIds.length,
            itemBuilder: (context, index) {
              final id = badgeIds[index];
              final ach = allAchievements.firstWhere((a) => a.id == id, orElse: () => allAchievements.first);
              return Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF7BC64), // Gold border
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF7BC64).withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Tooltip(
                  message: ach.title,
                  child: Icon(
                    ach.icon,
                    size: 28,
                    color: const Color(0xFFF7BC64),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTestimonySection(String? testimonyEn, String? testimonyTe) {
    final hasTe = testimonyTe != null && testimonyTe.trim().isNotEmpty;
    final hasEn = testimonyEn != null && testimonyEn.trim().isNotEmpty;

    if (!hasTe && !hasEn) return const SizedBox.shrink();

    final currentLang = context.read<LocaleProvider>().locale.languageCode;
    String text = "";
    if (currentLang == 'te') {
      text = hasTe ? testimonyTe : testimonyEn!;
    } else {
      text = hasEn ? testimonyEn : testimonyTe!;
    }

    final isLong = text.length > 200;
    final displayBio = isLong && !_testimonyExpanded ? "${text.substring(0, 200)}..." : text;

    final accentColor = _getAccentColor();

    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_rounded, color: accentColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Testimony",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              displayBio,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Outfit',
              ),
            ),
            if (isLong) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _testimonyExpanded = !_testimonyExpanded;
                  });
                },
                child: Text(
                  _testimonyExpanded ? "Show Less" : "Read Full Testimony",
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    fontSize: 13,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLimitedProfileView(String? bannerUrl, String? photoURL, String displayName, String username, int level, String reason) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(bannerUrl, photoURL, displayName, username, null, level),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildGlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.lock_rounded, size: 48, color: Colors.white38),
                            const SizedBox(height: 16),
                            Text(
                              reason,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () async {
                                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                                if (currentUid == null) return;
                                if (_isFollowing) {
                                  await FirebaseService.unfollowUser(currentUid, widget.userId!);
                                  setState(() {
                                    _isFollowing = false;
                                  });
                                } else {
                                  await FirebaseService.followUser(currentUid, widget.userId!);
                                  setState(() {
                                    _isFollowing = true;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing ? Colors.white12 : const Color(0xFF38BDF8),
                                foregroundColor: _isFollowing ? Colors.white70 : const Color(0xFF1A1A2E),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _isFollowing ? "Following" : "Follow",
                                style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Select only what this build actually needs from UserDataProvider
    final userAchievements = context.select<UserDataProvider, List<Achievement>>((p) => p.achievements);
    final userDisplayName = context.select<UserDataProvider, String>((p) => p.displayName);
    final userUsername = context.select<UserDataProvider, String>((p) => p.username);
    final userId = context.select<UserDataProvider, String?>((p) => p.userId);
    // Also keep a read reference for methods called in build side-effects
    final userProvider = context.read<UserDataProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (_loadingViewedUser) {
      return const Scaffold(
        backgroundColor: Color(0xFF121414),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }

    // Checking privacy visibility rules
    if (!_isOwnProfile) {
      final visibility = _getProfileValue('profileVisibility', 'public') as String;
      if (visibility == 'private') {
        return _buildLimitedProfileView(
          _getProfileValue('bannerUrl', null) as String?,
          _getProfileValue('photoURL', null) as String?,
          _getProfileValue('displayName', 'Player') as String,
          _getProfileValue('username', 'player') as String,
          _getProfileValue('playerLevel', 1) as int,
          "This profile is private.",
        );
      }

      if (visibility == 'followers' && !_isFollowing) {
        return _buildLimitedProfileView(
          _getProfileValue('bannerUrl', null) as String?,
          _getProfileValue('photoURL', null) as String?,
          _getProfileValue('displayName', 'Player') as String,
          _getProfileValue('username', 'player') as String,
          _getProfileValue('playerLevel', 1) as int,
          "This profile is visible to followers only.",
        );
      }
    }

    if (!_controllersInitialized && userUsername != "guest_username" && userDisplayName != "Guest Player") {
      _nameController.text = userDisplayName;
      _usernameController.text = userUsername;
      _controllersInitialized = true;
    } else if (!_controllersInitialized) {
      _nameController.text = userDisplayName;
      _usernameController.text = userUsername;
      if (userDisplayName != "Guest Player") {
        _controllersInitialized = true;
      }
    }

    if (userId != _loadedUserId && userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadReferralStats();
      });
    }



    final displayName = _getProfileValue('displayName', 'Guest Player') as String;
    final username = _getProfileValue('username', 'guest_username') as String;
    final photoURL = _getProfileValue('photoURL', null) as String?;
    final bannerUrl = _getProfileValue('bannerUrl', null) as String?;
    final bioEn = _getProfileValue('bioEn', null) as String?;
    final bioTe = _getProfileValue('bioTe', null) as String?;
    final ministryRole = _getProfileValue('ministryRole', null) as String?;
    final favoriteVerse = _getProfileValue('favoriteVerseRef', null) as String?;
    final testimonyEn = _getProfileValue('testimonyEn', null) as String?;
    final testimonyTe = _getProfileValue('testimonyTe', null) as String?;
    final socialLinks = _getProfileValue('socialLinks', null) as Map<String, String>?;
    final views = _getProfileValue('profileViews', 0) as int;
    final showcaseBadges = _getProfileValue('showcaseBadges', <String>[]) as List<String>;
    final activeTitle = _getProfileValue('activeTitle', '') as String;

    final level = _getProfileValue('playerLevel', 1) as int;
    final totalXp = _getProfileValue('totalXp', 0) as int;
    final streak = _getProfileValue('streakDays', 0) as int;
    final quizzes = _getProfileValue('quizCount', 0) as int;
    final battlesPlayed = _getProfileValue('battlesPlayed', 0) as int;
    final battlesWon = _getProfileValue('battlesWon', 0) as int;
    final battlesLost = _getProfileValue('battlesLost', 0) as int;

    final unlockedAchievements = _isOwnProfile
        ? userAchievements.where((a) => a.isUnlocked).toList()
        : <Achievement>[];
    final badgesCount = _isOwnProfile
        ? unlockedAchievements.length
        : showcaseBadges.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          _isOwnProfile ? "My Profile" : displayName,
          style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isOwnProfile) ...[
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                  ],

                  // Profile Header
                  _buildHeader(bannerUrl, photoURL, displayName, username, ministryRole, level),
                  const SizedBox(height: 16),

                  if (activeTitle.isNotEmpty) ...[
                    Center(child: _buildTitleBadge(activeTitle)),
                    const SizedBox(height: 8),
                  ],

                  // Follow Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFollowStat("Following", _isOwnProfile ? userProvider.userId : widget.userId),
                      const SizedBox(width: 24),
                      _buildFollowStat("Followers", _isOwnProfile ? userProvider.userId : widget.userId),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Profile Views and Action Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "$views views",
                        style: const TextStyle(color: Colors.white60, fontFamily: 'Outfit', fontSize: 13),
                      ),
                      if (!_isOwnProfile) ...[
                        const SizedBox(width: 20),
                        // Follow action button for viewing others
                        ElevatedButton(
                          onPressed: () async {
                            final currentUid = FirebaseAuth.instance.currentUser?.uid;
                            if (currentUid == null) return;
                            if (_isFollowing) {
                              await FirebaseService.unfollowUser(currentUid, widget.userId!);
                              setState(() {
                                _isFollowing = false;
                              });
                            } else {
                              await FirebaseService.followUser(currentUid, widget.userId!);
                              setState(() {
                                _isFollowing = true;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing ? Colors.white12 : const Color(0xFF38BDF8),
                            foregroundColor: _isFollowing ? Colors.white70 : const Color(0xFF1A1A2E),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            _isFollowing ? "Following" : "Follow",
                            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Display bio depending on current locale
                  () {
                    final currentLang = localeProvider.locale.languageCode;
                    final bio = currentLang == 'te'
                        ? (bioTe != null && bioTe.isNotEmpty ? bioTe : bioEn)
                        : (bioEn != null && bioEn.isNotEmpty ? bioEn : bioTe);
                    if (bio != null && bio.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          bio,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }(),

                  _buildSocialLinks(socialLinks),
                  const SizedBox(height: 16),

                  // Prominent edit profile button for owner
                  if (_isOwnProfile) ...[
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit Profile", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Badge Showcase ribbon
                  _buildBadgeShowcase(showcaseBadges),

                  // Favorite Verse Card
                  _buildFavoriteVerseCard(favoriteVerse),
                  const SizedBox(height: 20),

                  // Testimony Card
                  _buildTestimonySection(testimonyEn, testimonyTe),
                  const SizedBox(height: 20),

                  // Wisdom Tree Card (only for own profile or public)
                  if (_isOwnProfile) ...[
                    _buildGlassCard(
                      isGold: true,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WisdomTreeScreen()),
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
                    const SizedBox(height: 20),
                  ],

                  if (_isOwnProfile) ...[
                    _buildReferralCard(context),
                    const SizedBox(height: 20),
                  ],

                  // Achievements Ribbon & Collapsible List (only for own profile)
                  if (_isOwnProfile) ...[
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                  ],

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
                          _buildBattleStatItem("Played", "$battlesPlayed", Colors.blue),
                          _buildBattleStatItem("Won", "$battlesWon", Colors.green),
                          _buildBattleStatItem("Lost", "$battlesLost", Colors.red),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  if (_isOwnProfile) ...[
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
                                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
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
                                MaterialPageRoute(builder: (context) => const BookmarkedVersesScreen()),
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
                    const SizedBox(height: 20),
                  ],

                  if (_isOwnProfile) ...[
                    // Content Mode Card
                    _buildGlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Content Display Mode",
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF3E2723),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ContentLanguageMode>(
                              dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2020) : Colors.white,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF3E2723),
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
                                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                              ),
                              initialValue: localeProvider.contentMode,
                              items: [
                                DropdownMenuItem(
                                  value: ContentLanguageMode.bilingual,
                                  child: Text('Bilingual (తెలుగు + English)', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF3E2723))),
                                ),
                                DropdownMenuItem(
                                  value: ContentLanguageMode.english,
                                  child: Text('English Only', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF3E2723))),
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
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFFD4A574).withValues(alpha: 0.2),
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                                      color: themeProvider.themeMode == ThemeMode.dark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Dark Mode",
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF3E2723),
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
                  ],
                  const SizedBox(height: 80),
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: a.isUnlocked ? Colors.amber.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.06),
                      ),
                      child: Icon(
                        a.icon,
                        color: a.isUnlocked ? Colors.amber.shade400 : Colors.grey.shade500,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Outfit'),
                          ),
                          const SizedBox(height: 10),
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
                                        gradient: LinearGradient(colors: [Colors.grey.shade600, Colors.amber.shade400]),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a.type == 'speed' && a.currentProgress == 999
                                    ? "No record yet"
                                    : (a.type == 'speed' ? "${a.currentProgress}s / ${a.requiredCount}s" : "${a.currentProgress} / ${a.requiredCount}"),
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
                                  style: const TextStyle(color: Colors.white30, fontSize: 9, fontFamily: 'Outfit'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
        textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF3E2723);
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
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: gradientColors.first.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Text(
        title.name,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Outfit', letterSpacing: 0.8),
      ),
    );
  }

  // ignore: unused_element
  void _showTitleSelector(BuildContext context, UserDataProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
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
                          leading: Icon(Icons.block, color: isSelected ? const Color(0xFF38BDF8) : Colors.white54),
                          title: Text(
                            "None",
                            style: TextStyle(color: isSelected ? const Color(0xFF38BDF8) : Colors.white, fontFamily: 'Outfit', fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8)) : null,
                        );
                      }

                      final title = ProfileTitle.allTitles[index - 1];
                      final isUnlocked = provider.unlockedTitles.contains(title.id);
                      final isSelected = provider.activeTitle == title.id;

                      Color rarityColor;
                      switch (title.rarity) {
                        case TitleRarity.common: rarityColor = Colors.grey; break;
                        case TitleRarity.rare: rarityColor = const Color(0xFF3B82F6); break;
                        case TitleRarity.epic: rarityColor = const Color(0xFFF59E0B); break;
                        case TitleRarity.legendary: rarityColor = const Color(0xFFEC4899); break;
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
                          color: isSelected ? const Color(0xFF38BDF8) : (isUnlocked ? rarityColor : Colors.white24),
                        ),
                        title: Text(
                          title.name,
                          style: TextStyle(color: isSelected ? const Color(0xFF38BDF8) : (isUnlocked ? Colors.white : Colors.white38), fontFamily: 'Outfit', fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                        subtitle: Text(
                          title.description,
                          style: TextStyle(color: isUnlocked ? Colors.white54 : Colors.white24, fontFamily: 'Outfit', fontSize: 12),
                        ),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8)) : (isUnlocked ? null : const Icon(Icons.lock_outline, color: Colors.white24)),
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7BC64), Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFF7BC64)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: const Color(0xFF1E1E2E),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFF7BC64), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Refer a Friend & Earn 200 XP",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Invite friends to test their Bible knowledge. Once they sign up, you both get a 200 XP boost!",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit', height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("YOUR REFERRAL CODE", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, fontFamily: 'Outfit')),
                        const SizedBox(height: 4),
                        Text(_referralCode ?? 'WELCOME123', style: AppTextStyles.sectionHeader.copyWith(color: Color(0xFFF7BC64), letterSpacing: 1.2, fontFamily: 'Outfit')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF38BDF8), size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _referralCode ?? 'WELCOME123'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral code copied to clipboard!', style: TextStyle(fontFamily: 'Outfit'))),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("FRIENDS INVITED", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      const SizedBox(height: 4),
                      Text("$_referralCount users", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("TOTAL XP EARNED", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      const SizedBox(height: 4),
                      Text("+$_referralXp XP", style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    ],
                  ),
                ],
              ),
              if (_referredUsers.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text("Referred Friends:", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _referredUsers.length,
                  itemBuilder: (ctx, index) {
                    return ReferredUserWidget(userId: _referredUsers[index], index: index + 1);
                  },
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(ShareParams(text: "Join me on the multilingual Bible Quiz app! Use my referral code: ${_referralCode ?? 'WELCOME123'} to claim a 200 XP welcome reward. Download now!"));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: const Color(0xFF442B00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text("SHARE APPLINK", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit', letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowStat(String label, String? userId) {
    if (userId == null) return const SizedBox.shrink();
    final isFollowers = label == "Followers";

    return StreamBuilder<List<String>>(
      stream: isFollowers ? FirebaseService.getFollowers(userId) : FirebaseService.getFollowing(userId),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        final list = snapshot.data ?? [];
        return InkWell(
          onTap: count > 0 ? () => _showFollowList(label, list) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              children: [
                Text(
                  "$count",
                  style: AppTextStyles.sectionHeader.copyWith(color: Colors.white, fontFamily: 'Outfit'),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Outfit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFollowList(String title, List<String> userIds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: AppTextStyles.sectionHeader.copyWith(color: Colors.white, fontFamily: 'Outfit'),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: userIds.length,
                  itemBuilder: (context, index) {
                    return _buildUserFollowItem(userIds[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserFollowItem(String targetUserId) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final showUnfollow = _isOwnProfile;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(targetUserId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text("Loading...", style: TextStyle(color: Colors.white54, fontFamily: 'Outfit')),
          );
        }

        final userDoc = snapshot.data!;
        if (!userDoc.exists) return const SizedBox.shrink();
        final data = userDoc.data() as Map<String, dynamic>;
        final displayName = data['displayName'] ?? 'Player';
        final username = data['username'] ?? 'player';
        final photoURL = data['photoURL'] as String?;

        return StreamBuilder<List<String>>(
          stream: FirebaseService.getFollowing(currentUserId),
          builder: (context, followingSnapshot) {
            final followingList = followingSnapshot.data ?? [];
            final isFollowing = followingList.contains(targetUserId);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0284C7),
                child: photoURL != null && photoURL.isNotEmpty
                    ? ClipOval(child: _buildAvatarImage(photoURL, 36, displayName))
                    : Center(
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              title: Text(
                displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 14),
              ),
              subtitle: Text(
                "@$username",
                style: const TextStyle(color: Colors.white70, fontFamily: 'Outfit', fontSize: 12),
              ),
              trailing: showUnfollow
                  ? TextButton(
                      onPressed: () async {
                        await FirebaseService.unfollowUser(currentUserId, targetUserId);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Unfollow", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    )
                  : TextButton(
                      onPressed: () async {
                        if (isFollowing) {
                          await FirebaseService.unfollowUser(currentUserId, targetUserId);
                        } else {
                          await FirebaseService.followUser(currentUserId, targetUserId);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF38BDF8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isFollowing ? "Following" : "Follow Back",
                        style: TextStyle(
                          color: isFollowing ? Colors.white70 : const Color(0xFF1A1A2E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
            );
          },
        );
      },
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

class _AnimatedRainbowBadgeState extends State<AnimatedRainbowBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
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
              BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)
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
                Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 2)
              ],
            ),
          ),
        );
      },
    );
  }
}
