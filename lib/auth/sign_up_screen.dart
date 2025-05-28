// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously, unused_element_parameter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkdeals/auth/sign_in_screen.dart';
import 'package:talkdeals/theme/color_theme.dart';
import 'package:talkdeals/theme/text_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (password != _confirmCtrl.text.trim()) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Create base user doc
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user?.uid)
          .set({
            'email': email,
            'name': name.isNotEmpty ? name : 'User',
            'profile_pic_Url': '',
            'user_type': 'Admin',
            'created_at': FieldValue.serverTimestamp(),
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
      );
      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                          const SizedBox(height: 20),
                          Text(
                            'Create an Account',
                            style: CustomTextStyle.headlineSmall(context)
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Join our community today!',
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
                          // Name Field
                          _Label(context, 'Full Name'),
                          const SizedBox(height: 8),
                          _NameField(_nameCtrl),
                          const SizedBox(height: 20),

                          // Email Field
                          _Label(context, 'Email Address'),
                          const SizedBox(height: 8),
                          _EmailField(_emailCtrl),
                          const SizedBox(height: 20),

                          // Password Field
                          _Label(context, 'Password'),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _passCtrl,
                            obscure: _obscurePass,
                            onToggle: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          _Label(context, 'Confirm Password'),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _confirmCtrl,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUpUser,
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
                                      'Sign Up',
                                      style: CustomTextStyle.titleSmall(context)
                                          .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Already have an account
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SigninScreen(),
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: CustomTextStyle.bodyMedium(
                                    context,
                                  ).copyWith(color: AppColors.textSecondary),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
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
                        // ignore: deprecated_member_use
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
                            'Welcome to TalkDeals',
                            style: CustomTextStyle.headlineLarge(context)
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Join thousands of users who are already part of our community. Get access to exclusive deals and offers.',
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

class _NameField extends StatelessWidget {
  const _NameField(this.controller);
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primary,
      decoration: _inputDecoration(
        hint: 'Enter your full name',
        icon: FluentIcons.person_16_filled,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your name';
        return null;
      },
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
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
