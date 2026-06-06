import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _referralController = TextEditingController();

  AuthView _currentView = AuthView.guest;
  AuthMethod _currentMethod = AuthMethod.email;

  String _errorMessage = "";
  bool _isLoading = false;

  // Phone auth variables
  bool _otpSent = false;
  String? _verificationId;
  String _enteredOtp = "";
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  CountryCode _selectedCountry = countryCodes[0];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _changeView(AuthView view) {
    setState(() {
      _currentView = view;
      _errorMessage = "";
      _otpSent = false;
      _verificationId = null;
      _enteredOtp = "";
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _referralController.clear();
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
          
          final referralCode = _referralController.text.trim();
          if (referralCode.isNotEmpty) {
            try {
              await FirebaseService.applyReferralCode(referralCode, user.uid);
            } catch (e) {
              // ignore: avoid_print
              print("Error applying referral code: $e");
            }
          }
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

  void _handleAuth() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      if (_currentView == AuthView.guest) {
        if (_nameController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = "Please enter your nickname.";
            _isLoading = false;
          });
          return;
        }
        
        await FirebaseService.signInAnonymously();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await FirebaseService.createUserProfile(user.uid, displayName: _nameController.text.trim());
          
          final referralCode = _referralController.text.trim();
          if (referralCode.isNotEmpty) {
            try {
              await FirebaseService.applyReferralCode(referralCode, user.uid);
            } catch (e) {
              // ignore: avoid_print
              print("Error applying referral code: $e");
            }
          }
        }
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (_currentView == AuthView.login) {
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

        await FirebaseService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          "en",
          referralCode: _referralController.text.trim(),
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

    return Scaffold(
      body: Stack(
        children: [
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
                opacity: 0.15,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF38BDF8),
                        blurRadius: 120,
                        spreadRadius: 100,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ContentLanguageMode>(
                              value: localeProvider.contentMode,
                              dropdownColor: const Color(0xFF1E2020),
                              icon: const Icon(Icons.translate, color: Color(0xFF38BDF8), size: 18),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 13),
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
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: const Icon(
                                  Icons.auto_stories,
                                  size: 32,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Telugu Bible Quiz",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "తెలుగు బైబిల్ క్విజ్",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              fontFamily: 'NotoSerifTelugu',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0xFF0284C7),
                                          Color(0xFF38BDF8),
                                          Color(0xFF0284C7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 8),
                                      if (_currentView != AuthView.guest) ...[
                                        _buildMethodSelector(),
                                        const SizedBox(height: 20),
                                      ],
                                      if (_errorMessage.isNotEmpty) ...[
                                        Text(
                                          _errorMessage,
                                          style: const TextStyle(
                                            color: Color(0xFFFFB4AB),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: 'Outfit',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: _buildFormFields(),
                                      ),
                                      const SizedBox(height: 24),
                                      _isLoading
                                          ? const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                                child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: _currentMethod == AuthMethod.phone && _currentView != AuthView.guest
                                                  ? (_otpSent ? _verifyOtp : _sendOtp)
                                                  : _handleAuth,
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0284C7),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                                      blurRadius: 15,
                                                      offset: const Offset(0, 5),
                                                    )
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      _currentView == AuthView.guest
                                                          ? "PLAY SOLO"
                                                          : (_currentMethod == AuthMethod.phone
                                                              ? (_otpSent ? "VERIFY OTP" : "SEND OTP")
                                                              : (_currentView == AuthView.login ? "LOGIN" : "SIGN UP")),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Outfit',
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      if (_currentView != AuthView.guest) ...[
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                "or",
                                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontFamily: 'Outfit'),
                                              ),
                                            ),
                                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        InkWell(
                                          onTap: () {
                                            _changeView(AuthView.guest);
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.person_outline, color: Colors.white, size: 18),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Continue as Guest",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: _buildFooterLinks(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentMethod = AuthMethod.email;
                  _errorMessage = "";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _currentMethod == AuthMethod.email
                      ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      color: _currentMethod == AuthMethod.email ? const Color(0xFF38BDF8) : Colors.white60,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Email",
                      style: TextStyle(
                        color: _currentMethod == AuthMethod.email ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentMethod = AuthMethod.phone;
                  _errorMessage = "";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _currentMethod == AuthMethod.phone
                      ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: _currentMethod == AuthMethod.phone ? const Color(0xFF38BDF8) : Colors.white60,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Phone",
                      style: TextStyle(
                        color: _currentMethod == AuthMethod.phone ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    if (_currentView == AuthView.guest) {
      return Column(
        key: const ValueKey('guest_fields'),
        children: [
          _buildTextField(
            controller: _nameController,
            hint: "Enter Nickname",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _referralController,
            hint: "Referral Code (Optional)",
            icon: Icons.card_giftcard,
          ),
        ],
      );
    } else if (_currentMethod == AuthMethod.email) {
      return Column(
        key: const ValueKey('email_fields'),
        children: [
          if (_currentView == AuthView.signUp) ...[
            _buildTextField(
              controller: _nameController,
              hint: "Full Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            hint: "Email",
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            hint: "Password",
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          if (_currentView == AuthView.signUp) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _referralController,
              hint: "Referral Code (Optional)",
              icon: Icons.card_giftcard,
            ),
          ],
        ],
      );
    } else {
      // Phone Authentication Form fields
      if (_otpSent) {
        return Column(
          key: const ValueKey('otp_fields'),
          children: [
            const Text(
              "Enter the 6-digit OTP sent to your phone number",
              style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OtpInputWidget(
              length: 6,
              onChanged: (val) {
                _enteredOtp = val;
              },
              onCompleted: (val) {
                _enteredOtp = val;
                _verifyOtp();
              },
            ),
            const SizedBox(height: 20),
            if (_resendCooldown > 0)
              Text(
                "Resend OTP in $_resendCooldown seconds",
                style: const TextStyle(color: Colors.white60, fontFamily: 'Outfit', fontSize: 13),
              )
            else
              TextButton(
                onPressed: _sendOtp,
                child: const Text(
                  "Resend OTP",
                  style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 13),
                ),
              ),
          ],
        );
      } else {
        return Column(
          key: const ValueKey('phone_fields'),
          children: [
            if (_currentView == AuthView.signUp) ...[
              _buildTextField(
                controller: _nameController,
                hint: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                GestureDetector(
                  onTap: _showCountryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedCountry.flag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(_selectedCountry.code, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 14)),
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                      decoration: InputDecoration(
                        hintText: "Phone Number",
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontFamily: 'Outfit'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_currentView == AuthView.signUp) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _referralController,
                hint: "Referral Code (Optional)",
                icon: Icons.card_giftcard,
              ),
            ],
          ],
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontFamily: 'Outfit'),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    if (_currentView == AuthView.guest) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Have an account? ", style: TextStyle(color: Color(0xFFCBC3D4), fontFamily: 'Outfit')),
          GestureDetector(
            onTap: () {
              _changeView(AuthView.login);
            },
            child: const Text(
              "Login",
              style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
          ),
        ],
      );
    } else if (_currentView == AuthView.login) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? ", style: TextStyle(color: Color(0xFFCBC3D4), fontFamily: 'Outfit')),
              GestureDetector(
                onTap: () {
                  _changeView(AuthView.signUp);
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              _changeView(AuthView.guest);
            },
            child: const Text(
              "Continue as Guest",
              style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account? ", style: TextStyle(color: Color(0xFFCBC3D4), fontFamily: 'Outfit')),
          GestureDetector(
            onTap: () {
              _changeView(AuthView.login);
            },
            child: const Text(
              "Login",
              style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
          ),
        ],
      );
    }
  }
}
