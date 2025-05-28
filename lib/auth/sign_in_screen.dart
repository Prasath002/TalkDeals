// ignore_for_file: unused_import, unused_local_variable, use_build_context_synchronously, unused_element_parameter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkdeals/auth/checking_auth.dart';
import 'package:talkdeals/auth/sign_up_screen.dart';
import 'package:talkdeals/screens/admin/admin_bottom_nav_bar.dart';
import 'package:talkdeals/theme/color_theme.dart';
import 'package:talkdeals/theme/text_theme.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future signin(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .whenComplete(() {
              debugPrint('-----Sigin Successfully-----');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CheckingAuth()),
              );
            });
      } on FirebaseAuthException catch (e) {
        if (e.code == e.code) {
          setState(() {
            _isLoading = false;
          });
          wronguser(
            'User not located. Please verify the details and try again',
          );
        } else if (e.code == e.code) {
          setState(() {
            _isLoading = false;
          });
          wronguser('Access denied. The password you provided is incorrect');
        } else {
          setState(() {
            _isLoading = false;
          });
          wronguser('Email or Password invaild');
        }
      }
    } else {
      const CircularProgressIndicator();
    }
  }

  void wronguser(String message) {
    final snakcredential = SnackBar(
      content: Text(message),
      elevation: 10,
      duration: const Duration(milliseconds: 250),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );

    ScaffoldMessenger.of(context).showSnackBar(snakcredential);
  }

  // Rest of your widget code remains the same...
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Left side - Form
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 30,
                  vertical: 40,
                ),
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Title
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    FluentIcons.chat_24_filled,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Talkdeals',
                                style: CustomTextStyle.headlineMedium(context)
                                    .copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome Back',
                            style: CustomTextStyle.headlineSmall(context)
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in to continue to TalkDeals',
                            style: CustomTextStyle.bodyMedium(
                              context,
                            ).copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Field
                          _Label(context, 'Email Address'),
                          const SizedBox(height: 8),
                          _EmailField(_emailController),
                          const SizedBox(height: 20),

                          // Password Field
                          _Label(context, 'Password'),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _passwordController,
                            obscure: _obscureText,
                            onToggle: () =>
                                setState(() => _obscureText = !_obscureText),
                          ),
                          const SizedBox(height: 10),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                    fillColor:
                                        WidgetStateProperty.resolveWith<Color>((
                                          Set<WidgetState> states,
                                        ) {
                                          if (states.contains(
                                            WidgetState.selected,
                                          )) {
                                            return AppColors.primary;
                                          }
                                          return Colors.transparent;
                                        }),
                                    side: BorderSide(
                                      color: AppColors.gray,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    'Remember me',
                                    style: CustomTextStyle.labelSmall(context),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    builder: (context) => Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.lock_reset,
                                                color: AppColors.primary,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Forgot Password',
                                                style:
                                                    CustomTextStyle.titleLarge(
                                                      context,
                                                    ).copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Enter your email address and we\'ll send you a link to reset your password.',
                                            style: CustomTextStyle.bodyMedium(
                                              context,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            initialValue: _emailController.text,
                                            decoration: _inputDecoration(
                                              hint: 'Email address',
                                              icon: FluentIcons.mail_16_filled,
                                            ),
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await FirebaseAuth.instance
                                                      .sendPasswordResetEmail(
                                                        email: _emailController
                                                            .text,
                                                      );
                                                  Navigator.pop(context);
                                                  Get.snackbar(
                                                    'Success',
                                                    'Password reset link sent to your email',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        AppColors.success,
                                                    colorText: AppColors.white,
                                                  );
                                                } catch (e) {
                                                  Get.snackbar(
                                                    'Error',
                                                    'Failed to send reset link: ${e.toString()}',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        AppColors.error,
                                                    colorText: AppColors.white,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                'Send Reset Link',
                                                style:
                                                    CustomTextStyle.titleSmall(
                                                      context,
                                                    ).copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: CustomTextStyle.labelSmall(
                                    context,
                                  ).copyWith(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                signin(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: CustomTextStyle.titleSmall(context)
                                          .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Don't have an account
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: CustomTextStyle.bodyMedium(
                                    context,
                                  ).copyWith(color: AppColors.textSecondary),
                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: CustomTextStyle.bodyMedium(context)
                                          .copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ),
          ),

          // Right side - Image (only on desktop)
          if (isDesktop)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1551434678-e076c223a692?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.7),
                        AppColors.primary.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(80.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Discover Amazing Deals',
                            style: CustomTextStyle.headlineLarge(context)
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Join thousands of users who are saving money every day with our exclusive deals and offers.',
                            style: CustomTextStyle.bodyLarge(context).copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _FeatureChip(
                                icon: FluentIcons.shield_checkmark_16_filled,
                                text: 'Secure Platform',
                              ),
                              _FeatureChip(
                                icon: FluentIcons.clock_16_filled,
                                text: 'Fast Service',
                              ),
                              _FeatureChip(
                                icon: FluentIcons.people_community_16_filled,
                                text: 'Community Support',
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
        ],
      ),
    );
  }
}

/* ────────────────────────── Re-usable widgets ────────────────────────── */

class _Label extends StatelessWidget {
  final String text;
  final bool required;

  const _Label(BuildContext context, this.text, {this.required = true});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: CustomTextStyle.labelLarge(
          context,
        ).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField(this.controller);
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primary,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(
        hint: 'Enter your email',
        icon: FluentIcons.mail_16_filled,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: AppColors.primary,
      decoration: _inputDecoration(
        hint: 'Enter your password',
        icon: FluentIcons.lock_closed_16_filled,
        suffix: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: CustomTextStyle.labelMedium(
              context,
            ).copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/* Shared decoration builder */
InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.grayLight.withOpacity(0.3),
    prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
