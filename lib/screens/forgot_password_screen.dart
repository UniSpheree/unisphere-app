import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../services/sqlite_backend.dart';

/// Forgot-password flow – 3 steps:
///   1. Enter university email
///   2. Enter the 6-digit code (fake: always "123456")
///   3. Set a new password (same rules as registration)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ── Shared state ──────────────────────────────────────────────────────────
  int _step = 1; // 1 | 2 | 3
  bool _isLoading = false;

  // Step 1
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 2
  final _codeFormKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  static const _fakeCode = '123456';

  // Step 3
  final _pwFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _submitEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim().toLowerCase();
    final exists = await SqliteBackend().forgotPassword(email);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (exists) {
      setState(() => _step = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No account found with this email.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _submitCode() async {
    if (!_codeFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (_codeController.text.trim() != _fakeCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Invalid code. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    setState(() => _step = 3);
  }

  Future<void> _submitNewPassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim().toLowerCase();
    final newPassword = _newPasswordController.text;
    final success = await SqliteBackend().resetPassword(email, newPassword);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password reset successfully! Please log in.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2D3A8C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to reset password. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: const AuthHeader(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 1
                    ? _StepEmail(
                        key: const ValueKey(1),
                        formKey: _emailFormKey,
                        controller: _emailController,
                        isLoading: _isLoading,
                        onSubmit: _submitEmail,
                      )
                    : _step == 2
                    ? _StepCode(
                        key: const ValueKey(2),
                        formKey: _codeFormKey,
                        controller: _codeController,
                        email: _emailController.text.trim(),
                        isLoading: _isLoading,
                        onSubmit: _submitCode,
                        onResend: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Code resent! (hint: 123456)',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF2D3A8C),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      )
                    : _StepNewPassword(
                        key: const ValueKey(3),
                        formKey: _pwFormKey,
                        newPasswordController: _newPasswordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscureNew: _obscureNew,
                        obscureConfirm: _obscureConfirm,
                        onToggleNew: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        onToggleConfirm: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        isLoading: _isLoading,
                        onSubmit: _submitNewPassword,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Email entry
// ─────────────────────────────────────────────────────────────────────────────
class _StepEmail extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _StepEmail({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              color: Color(0xFF2D3A8C),
              size: 28,
            ),
          ),

          const Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your university email and we\'ll send you a reset code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 28),

          AuthTextField(
            label: 'University Email Address',
            hintText: 'alex@university.edu',
            prefixIcon: Icons.email_outlined,
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            validator: validateUniversityEmail,
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3A8C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send Reset Code',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),
          _BackToLogin(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Code verification
// ─────────────────────────────────────────────────────────────────────────────
class _StepCode extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String email;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  const _StepCode({
    super.key,
    required this.formKey,
    required this.controller,
    required this.email,
    required this.isLoading,
    required this.onSubmit,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Color(0xFF2D3A8C),
              size: 28,
            ),
          ),

          const Text(
            'Check your Email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit code to $email',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 6),
          // Fake hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Color(0xFFF9A825)),
                SizedBox(width: 6),
                Text(
                  'Demo hint: use code 123456',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF795548),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          AuthTextField(
            label: 'Verification Code',
            hintText: '123456',
            prefixIcon: Icons.pin_outlined,
            controller: controller,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Code is required';
              if (v.trim().length != 6) return 'Code must be 6 digits';
              return null;
            },
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3A8C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Resend
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                "Didn't receive it? ",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              GestureDetector(
                onTap: onResend,
                child: const Text(
                  'Resend Code',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2D3A8C),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          _BackToLogin(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 – New password
// ─────────────────────────────────────────────────────────────────────────────
class _StepNewPassword extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _StepNewPassword({
    super.key,
    required this.formKey,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFF2D3A8C),
              size: 28,
            ),
          ),

          const Text(
            'Set New Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your new password must be at least 8 characters and include a number and a special character.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 28),

          // ── New password ──────────────────────────────────────────────
          AuthTextField(
            label: 'New Password',
            prefixIcon: Icons.lock_outline,
            obscureText: obscureNew,
            controller: newPasswordController,
            validator: validatePassword,
            suffixWidget: IconButton(
              icon: Icon(
                obscureNew
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: Colors.grey.shade500,
              ),
              onPressed: onToggleNew,
            ),
          ),

          const SizedBox(height: 18),

          // ── Confirm password ──────────────────────────────────────────
          AuthTextField(
            label: 'Confirm New Password',
            prefixIcon: Icons.lock_outline,
            obscureText: obscureConfirm,
            controller: confirmPasswordController,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your password';
              }
              if (v != newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            suffixWidget: IconButton(
              icon: Icon(
                obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: Colors.grey.shade500,
              ),
              onPressed: onToggleConfirm,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3A8C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check_circle_outline, size: 18),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 18),
          _BackToLogin(),
        ],
      ),
    );
  }
}

// ── Shared "Back to Login" link ────────────────────────────────────────────
class _BackToLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Icon(Icons.arrow_back, size: 13, color: Colors.grey),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2D3A8C),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
