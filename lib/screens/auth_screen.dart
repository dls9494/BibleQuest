// ignore_for_file: unused_import, unused_field, unused_element, unused_local_variable
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/otp_input.dart';

enum AuthView { landing, login, signUp, phoneAuth }
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

  AuthView _currentView = AuthView.landing;
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

  // Phone auth variables
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _mapFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email.";
        case 'wrong-password':
          return "Incorrect password.";
        case 'email-already-in-use':
          return "An account already exists with this email.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        case 'weak-password':
          return "Password should be at least 6 characters.";
        case 'network-request-failed':
          return "No internet connection.";
        default:
          return e.message ?? "Authentication failed. Please try again.";
      }
    }
    final errStr = e.toString();
    if (errStr.contains("ApiException: 10")) {
      return "Google Sign-In misconfigured (Developer Error 10). Make sure to register the debug SHA-1 key in Firebase Console.";
    }
    if (errStr.contains("sign_in_failed")) {
      return "Google Sign-In failed. Please check your network or device configuration.";
    }
    return errStr.replaceAll("Exception: ", "");
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showErrorSnackBar("Please enter your phone number.");
      return;
    }
    if (_selectedCountry.code == "+91" && phone.length != 10) {
      _showErrorSnackBar("Please enter a valid 10-digit phone number.");
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
            _isLoading = false;
          });
          _showErrorSnackBar(_mapFirebaseError(e));
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
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
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
      _showErrorSnackBar("Please enter a 6-digit OTP.");
      return;
    }

    if (_verificationId == null) {
      _showErrorSnackBar("Verification session expired. Please resend OTP.");
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
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
    }
  }

  Future<void> _onLoginSuccess(User user) async {
    if (!mounted) return;
    await context.read<UserDataProvider>().restoreSession(user);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final user = await FirebaseService.signInWithPhoneCredential(credential);
      if (user != null) {
        if (_nameController.text.trim().isNotEmpty) {
          await user.updateDisplayName(_nameController.text.trim());
          await FirebaseService.createUserProfile(
            user.uid,
            displayName: _nameController.text.trim(),
            phoneNumber: user.phoneNumber,
            authMethod: 'phone',
          );
        }
        await _onLoginSuccess(user);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar("Please enter your email address to reset your password.");
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
            backgroundColor: const Color(0xFFC5A85C),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
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
            _isLoading = false;
          });
          _showErrorSnackBar("Please fill in email and password.");
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

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _onLoginSuccess(user);
        }
      } else if (_currentView == AuthView.signUp) { // Sign Up / Register
        if (_nameController.text.trim().isEmpty) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar("Please enter your name.");
          return;
        }
        if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar("Please enter email and password to sign up.");
          return;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar("Passwords do not match.");
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
              backgroundColor: const Color(0xFFC5A85C),
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
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
    }
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final user = await FirebaseService.signInWithGoogle();
      if (user != null) {
        await _onLoginSuccess(user);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
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
        await _onLoginSuccess(user);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_mapFirebaseError(e));
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000F26),
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
                  trailing: Text(country.code, style: const TextStyle(color: Color(0xFFC5A85C), fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
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
    if (_currentView == AuthView.landing) {
      return _buildLandingView();
    } else if (_currentView == AuthView.login) {
      return _buildLoginView();
    } else if (_currentView == AuthView.signUp) {
      return _buildSignUpView();
    } else {
      return _buildPhoneAuthView();
    }
  }

  // --- 1. LANDING VIEW (Mockup Replicated Exactly) ---
  Widget _buildLandingView() {
    return Scaffold(
      backgroundColor: const Color(0xFF000F26),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image containing Bible artwork, title, description and 4 badges
            Image.asset(
              'assets/banners/login_header_770.jpg',
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 16),
            // Padded section containing the 3 buttons and the footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Button 1: Continue with Google
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A85C))))
                      : _buildGoogleButton(),
                  const SizedBox(height: 16),
                  // Button 2: Continue with Email
                  _buildOutlineButton(
                    icon: Icons.mail_outline,
                    text: "Continue with Email",
                    onTap: () => _changeView(AuthView.login),
                  ),
                  const SizedBox(height: 16),
                  // Button 3: Continue with Phone (Displays billing/coming soon fallback)
                  _buildOutlineButton(
                    icon: Icons.phone_iphone,
                    text: "Continue with Phone",
                    onTap: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Phone sign-in coming soon!", style: TextStyle(fontFamily: 'Outfit')),
                          backgroundColor: Color(0xFFC5A85C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Button 4: Continue as Guest text link
                  Center(
                    child: GestureDetector(
                      onTap: _handleGuestLogin,
                      child: const Text(
                        "Continue as Guest",
                        style: TextStyle(
                          color: Color(0xFFC5A85C),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Outfit',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Footer Text & Links
                  _buildFooterText(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- 2. EMAIL LOGIN VIEW ---
  Widget _buildLoginView() {
    return Scaffold(
      backgroundColor: const Color(0xFF000F26),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Smaller header image to give space for forms
                Image.asset(
                  'assets/banners/login_header_520.jpg',
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "Log in to continue your spiritual quest",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        isFocused: _isEmailFocused,
                        labelText: "Email Address",
                        placeholder: "e.g., name@domain.com",
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        isFocused: _isPasswordFocused,
                        labelText: "Password",
                        placeholder: "Enter password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _rememberMe ? const Color(0xFFC5A85C) : Colors.white10,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _rememberMe ? const Color(0xFFC5A85C) : Colors.white30,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: _rememberMe
                                      ? const Icon(Icons.check, size: 12, color: Colors.black)
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
                                color: Color(0xFFC5A85C),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A85C))))
                          : _buildGradientButton(
                              text: "Log In",
                              onTap: _handleAuth,
                            ),
                      const SizedBox(height: 16),
                      _buildOutlineButton(
                        icon: Icons.person_outline,
                        text: "Continue as Guest",
                        onTap: _handleGuestLogin,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () => _changeView(AuthView.signUp),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFFC5A85C),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFC5A85C)),
                onPressed: () => _changeView(AuthView.landing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. EMAIL SIGN UP VIEW ---
  Widget _buildSignUpView() {
    return Scaffold(
      backgroundColor: const Color(0xFF000F26),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/banners/login_header_520.jpg',
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "Join the BibleQuest community today",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        isFocused: _isNameFocused,
                        labelText: "Full Name",
                        placeholder: "e.g., John Doe",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        isFocused: _isEmailFocused,
                        labelText: "Email Address",
                        placeholder: "e.g., name@domain.com",
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        isFocused: _isPasswordFocused,
                        labelText: "Password",
                        placeholder: "Create password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
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
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        isFocused: _isConfirmPasswordFocused,
                        labelText: "Confirm Password",
                        placeholder: "Re-enter password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                      ),
                      const SizedBox(height: 28),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A85C))))
                          : _buildGradientButton(
                              text: "Sign Up",
                              onTap: _handleAuth,
                            ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () => _changeView(AuthView.login),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Color(0xFFC5A85C),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFC5A85C)),
                onPressed: () => _changeView(AuthView.landing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. PHONE AUTH VIEW ---
  Widget _buildPhoneAuthView() {
    return Scaffold(
      backgroundColor: const Color(0xFF000F26),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/banners/login_header_520.jpg',
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          _otpSent ? "OTP Verification" : "Mobile Login",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _otpSent ? "Enter the verification code sent to your device" : "Sign in using your mobile number",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_otpSent) ...[
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showCountryPicker,
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12, width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.code,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Color(0xFFC5A85C), size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12, width: 1.2),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                                  decoration: const InputDecoration(
                                    hintText: "Phone number",
                                    hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                                    prefixIcon: Icon(Icons.phone, color: Colors.white54, size: 20),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A85C))))
                            : _buildGradientButton(
                                text: "Send verification code",
                                onTap: _sendOtp,
                              ),
                      ] else ...[
                        OtpInputWidget(
                          length: 6,
                          onChanged: (code) {
                            _enteredOtp = code;
                          },
                          onCompleted: (code) {
                            _enteredOtp = code;
                            _verifyOtp();
                          },
                        ),
                        const SizedBox(height: 28),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A85C))))
                            : _buildGradientButton(
                                text: "Verify code",
                                onTap: _verifyOtp,
                              ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: _resendCooldown == 0 ? _sendOtp : null,
                            child: Text(
                              _resendCooldown == 0 ? "Resend Code" : "Resend in ${_resendCooldown}s",
                              style: TextStyle(
                                color: _resendCooldown == 0 ? const Color(0xFFC5A85C) : Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFC5A85C)),
                onPressed: () {
                  if (_otpSent) {
                    setState(() {
                      _otpSent = false;
                      _enteredOtp = "";
                    });
                  } else {
                    _changeView(AuthView.landing);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF7CB60),
              Color(0xFFE2A02B),
              Color(0xFFD4871B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4871B).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/banners/google_logo.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Text(
                "Continue with Google",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.85),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(width: 32), // balanced spacing for the circle logo
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC5A85C).withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFC5A85C),
              size: 22,
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(width: 22), // balanced spacing for the icon
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF7CB60),
              Color(0xFFE2A02B),
              Color(0xFFD4871B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4871B).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.85),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String labelText,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFFC5A85C) : Colors.white12,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: isFocused ? const Color(0xFFC5A85C) : Colors.white54,
            fontSize: 13,
            fontFamily: 'Outfit',
          ),
          hintText: placeholder,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13, fontFamily: 'Outfit'),
          prefixIcon: Icon(icon, color: isFocused ? const Color(0xFFC5A85C) : Colors.white54, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontFamily: 'Outfit',
          height: 1.5,
        ),
        children: [
          TextSpan(text: "By continuing, you agree to our "),
          TextSpan(
            text: "Terms of Service",
            style: TextStyle(
              color: Color(0xFFC5A85C),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: "\nand "),
          TextSpan(
            text: "Privacy Policy",
            style: TextStyle(
              color: Color(0xFFC5A85C),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: "."),
        ],
      ),
    );
  }
}
