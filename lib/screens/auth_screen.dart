// ignore_for_file: unused_import, unused_field, unused_element, unused_local_variable
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/otp_input.dart';

enum AuthView { login, signUp, guest }
enum AuthMethod { email, phone }

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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AuthView _currentView = AuthView.login;
  final AuthMethod _currentMethod = AuthMethod.email;

  String _errorMessage = "";
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Focus nodes for input styling
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isNameFocused = false;
  bool _isConfirmPasswordFocused = false;

  // Phone auth variables (kept for future phone auth support)
  bool _otpSent = false;
  String? _verificationId;
  String _enteredOtp = "";
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  CountryCode _selectedCountry = countryCodes[0];

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    _nameFocusNode.addListener(() {
      setState(() {
        _isNameFocused = _nameFocusNode.hasFocus;
      });
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
      });
    });
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _loadRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('remembered_email') ?? '';
      final remember = prefs.getBool('remember_me') ?? false;
      if (remember && email.isNotEmpty) {
        setState(() {
          _emailController.text = email;
          _rememberMe = true;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error loading remembered email: $e");
    }
  }

  void _saveRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailController.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('remembered_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error saving remembered email: $e");
    }
  }

  void _changeView(AuthView view) {
    setState(() {
      _currentView = view;
      _errorMessage = "";
      _otpSent = false;
      _verificationId = null;
      _enteredOtp = "";
      _phoneController.clear();
      if (!_rememberMe) {
        _emailController.clear();
      }
      _passwordController.clear();
      _nameController.clear();
      _confirmPasswordController.clear();
    });
    _cooldownTimer?.cancel();
    _resendCooldown = 0;
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your phone number.";
      });
      return;
    }
    if (_selectedCountry.code == "+91" && phone.length != 10) {
      setState(() {
        _errorMessage = "Please enter a valid 10-digit phone number.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final fullPhoneNumber = "${_selectedCountry.code}$phone";

    try {
      await FirebaseService.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
            _startCooldownTimer();
          });
        },
        onVerificationFailed: (e) {
          setState(() {
            _errorMessage = e.message ?? e.toString();
            _isLoading = false;
          });
        },
        onVerificationCompleted: (credential) async {
          setState(() {
            _isLoading = true;
          });
          await _signInWithCredential(credential);
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    setState(() {
      _resendCooldown = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  void _verifyOtp() async {
    if (_enteredOtp.length < 6) {
      setState(() {
        _errorMessage = "Please enter a 6-digit OTP.";
      });
      return;
    }

    if (_verificationId == null) {
      setState(() {
        _errorMessage = "Verification session expired. Please resend OTP.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _enteredOtp,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final user = await FirebaseService.signInWithPhoneCredential(credential);
      if (user != null) {
        if (_currentView == AuthView.signUp && _nameController.text.trim().isNotEmpty) {
          await user.updateDisplayName(_nameController.text.trim());
          await FirebaseService.createUserProfile(
            user.uid,
            displayName: _nameController.text.trim(),
            phoneNumber: user.phoneNumber,
            authMethod: 'phone',
          );
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      String msg = e.toString();
      if (e is FirebaseAuthException) {
        msg = e.message ?? e.toString();
      } else {
        msg = msg.replaceAll("Exception: ", "");
      }
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email address to reset your password.";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Password reset email sent to $email",
              style: const TextStyle(fontFamily: 'Outfit'),
            ),
            backgroundColor: const Color(0xFF0284C7),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _handleAuth() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      if (_currentView == AuthView.login) {
        if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = "Please fill in email and password.";
            _isLoading = false;
          });
          return;
        }

        await FirebaseService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        try {
          await FirebaseService.checkEmailVerification();
        } catch (e) {
          await FirebaseService.signOut();
          rethrow;
        }

        _saveRememberedEmail();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else { // Sign Up / Register
        if (_nameController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = "Please enter your name.";
            _isLoading = false;
          });
          return;
        }
        if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = "Please enter email and password to sign up.";
            _isLoading = false;
          });
          return;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = "Passwords do not match.";
            _isLoading = false;
          });
          return;
        }

        await FirebaseService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          "en",
          referralCode: "",
        );

        await FirebaseService.sendEmailVerification();
        await FirebaseService.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Verification email sent to ${_emailController.text.trim()}. Please verify before logging in.",
                style: const TextStyle(fontFamily: 'Outfit'),
              ),
              backgroundColor: const Color(0xFF0284C7),
            ),
          );
          setState(() {
            _currentView = AuthView.login;
            _isLoading = false;
            _confirmPasswordController.clear();
          });
        }
      }
    } catch (e) {
      String msg = e.toString();
      if (e is FirebaseAuthException) {
        msg = e.message ?? e.toString();
      } else {
        msg = msg.replaceAll("Exception: ", "");
      }
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  void _handleGuestLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      await FirebaseService.signInAnonymously();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName("Guest");
        await FirebaseService.createUserProfile(user.uid, displayName: "Guest");
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countryCodes.length,
              itemBuilder: (context, index) {
                final country = countryCodes[index];
                return ListTile(
                  leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(country.name, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit')),
                  trailing: Text(country.code, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
        child: Stack(
          children: [
            // Dark glassmorphism floating accent light
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 450,
                    height: 450,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C4AB6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6C4AB6),
                          blurRadius: 160,
                          spreadRadius: 130,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Language Dropdown Selector at Top Right
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ContentLanguageMode>(
                                value: localeProvider.contentMode,
                                dropdownColor: const Color(0xFF1A1A2E),
                                icon: const Icon(Icons.translate, color: Color(0xFFFFD700), size: 16),
                                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 12),
                                onChanged: (ContentLanguageMode? mode) {
                                  if (mode != null) {
                                    localeProvider.setContentMode(mode);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: ContentLanguageMode.english,
                                    child: Text("English Only"),
                                  ),
                                  DropdownMenuItem(
                                    value: ContentLanguageMode.telugu,
                                    child: Text("Telugu Only"),
                                  ),
                                  DropdownMenuItem(
                                    value: ContentLanguageMode.bilingual,
                                    child: Text("Bilingual"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Logo & Title
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
                                ),
                                child: const Icon(
                                  Icons.auto_stories,
                                  size: 30,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _currentView == AuthView.signUp ? "Create Account" : "Welcome Back",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Sign in to continue your spiritual journey",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Error message
                        if (_errorMessage.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B1FA2).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFAB47BC).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Color(0xFFFFB4AB),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                fontFamily: 'Outfit',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Forms & Input Fields
                        _buildFormInputFields(),
                        const SizedBox(height: 20),

                        // Options Row (Remember Me & Forgot Password)
                        if (_currentView == AuthView.login) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Custom checkbox
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: _rememberMe ? const Color(0xFF6C4AB6) : Colors.white.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _rememberMe ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _rememberMe
                                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Remember Me",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _handleForgotPassword,
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Main Actions & Buttons
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                                ),
                              )
                            : Column(
                                children: [
                                  // Log In / Sign Up Button
                                  GestureDetector(
                                    onTap: _handleAuth,
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C4AB6),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6C4AB6).withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _currentView == AuthView.login ? "Log In" : "Sign Up",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Continue as Guest Button
                                  GestureDetector(
                                    onTap: _handleGuestLogin,
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Continue as Guest",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 28),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15), height: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "or",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.54),
                                  fontSize: 12,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15), height: 1)),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              bgColor: Colors.white,
                              child: const Text(
                                "G",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              onTap: () {},
                            ),
                            const SizedBox(width: 20),
                            _buildSocialButton(
                              bgColor: const Color(0xFF1877F2),
                              child: const Text(
                                "f",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                              onTap: () {},
                            ),
                            const SizedBox(width: 20),
                            _buildSocialButton(
                              bgColor: Colors.transparent,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF56040)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Bottom Sign Up Switch Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _currentView == AuthView.login
                                  ? "Don't have an account? "
                                  : "Already have an account? ",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_currentView == AuthView.login) {
                                  _changeView(AuthView.signUp);
                                } else {
                                  _changeView(AuthView.login);
                                }
                              },
                              child: Text(
                                _currentView == AuthView.login ? "Sign Up" : "Log In",
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 44),

                        // Footer Links
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildFooterLink("Help"),
                            _buildFooterDivider(),
                            _buildFooterLink("Privacy Policy"),
                            _buildFooterDivider(),
                            _buildFooterLink("Terms of Service"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "© 2026 Bible Quest",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInputFields() {
    return Column(
      children: [
        // Name field for registration
        if (_currentView == AuthView.signUp) ...[
          _buildFormContainer(
            isFocused: _isNameFocused,
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              decoration: _buildInputDecoration(
                label: "Full Name",
                placeholder: "Enter your full name",
                icon: Icons.person_outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Username / Email field
        _buildFormContainer(
          isFocused: _isEmailFocused,
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
            decoration: _buildInputDecoration(
              label: "Username / Email / Phone Number",
              placeholder: "e.g., name@company.com or +1 234 567 890",
              icon: Icons.person_outline,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password field
        _buildFormContainer(
          isFocused: _isPasswordFocused,
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
            decoration: _buildInputDecoration(
              label: "Password",
              placeholder: "Enter Password",
              icon: Icons.lock_outline,
              suffix: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),

        // Confirm Password field for registration
        if (_currentView == AuthView.signUp) ...[
          const SizedBox(height: 16),
          _buildFormContainer(
            isFocused: _isConfirmPasswordFocused,
            child: TextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              decoration: _buildInputDecoration(
                label: "Confirm Password",
                placeholder: "Re-enter Password",
                icon: Icons.lock_outline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormContainer({required bool isFocused, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String placeholder,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit'),
      hintText: placeholder,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 13, fontFamily: 'Outfit'),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffix,
      border: InputBorder.none,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Widget _buildSocialButton({
    required Widget child,
    required Color bgColor,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        "|",
        style: TextStyle(color: Colors.white24, fontSize: 11),
      ),
    );
  }
}
