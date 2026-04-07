import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import '../../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

/// Production-Ready Login Screen
/// Handles phone number collection and OTP flow initiation
/// Features: Phone formatting, rate limiting, error feedback, loading states
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  String? _validationError;
  int _attemptCount = 0;
  static const int _maxAttempts = 5;
  DateTime? _lockoutUntil;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    AppLogger.logFunctionEntry('LoginScreen.initState');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Check if rate limited after max failed attempts
  bool _isRateLimited() {
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      return true;
    }
    if (_lockoutUntil != null && DateTime.now().isAfter(_lockoutUntil!)) {
      _lockoutUntil = null;
      _attemptCount = 0;
    }
    return false;
  }

  /// Auto-format phone number to Indian format: +91 XXX XXX XXXX
  void _formatPhoneNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length > 10) {
      _phoneController.text = digitsOnly.substring(0, 10);
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: 10),
      );
      return;
    }

    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length <= 3) {
        formatted = '+91 ${digitsOnly}';
      } else if (digitsOnly.length <= 6) {
        formatted =
            '+91 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
      } else {
        formatted =
            '+91 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
      }
    }

    if (formatted != value) {
      _phoneController.text = formatted;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }
  }

  /// Send OTP - validate, check limits, call API, navigate
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isRateLimited()) {
      _showErrorSnackBar('Too many attempts. Please try again in 15 minutes.');
      return;
    }

    setState(() => _validationError = null);

    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    AppLogger.logFunctionEntry('_sendOtp', {'phoneNumber': phoneNumber});

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.sendOtp(phoneNumber);

    if (!mounted) return;

    final error = ref.read(authErrorProvider);
    if (error != null) {
      setState(() {
        _validationError = error;
        _attemptCount++;
        if (_attemptCount >= _maxAttempts) {
          _lockoutUntil = DateTime.now().add(const Duration(minutes: 15));
        }
      });
      _showErrorSnackBar(error);
      authNotifier.clearError();
    } else {
      _attemptCount = 0;
      _lockoutUntil = null;

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: phoneNumber,
            ),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              // Header
              Text(
                'Welcome to ClearDeed',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'End-to-end verified real estate & investment execution',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Phone form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Phone input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        onChanged: _formatPhoneNumber,
                        enabled: !isLoading && !_isRateLimited(),
                        validator: (value) => Validators.validatePhoneNumber(value),
                        decoration: InputDecoration(
                          hintText: '+91 9876543210',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              '🇮🇳',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.textHint),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.errorRed,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppTheme.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),

                    // Error display
                    if (_validationError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.1),
                          border: Border.all(color: AppTheme.errorRed),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _validationError!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.errorRed),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Rate limit warning
                    if (_isRateLimited()) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withOpacity(0.1),
                          border: Border.all(color: AppTheme.warningOrange),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: AppTheme.warningOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Too many attempts. Please try again later.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.warningOrange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Terms
                    Text(
                      'By proceeding, you agree to our Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 32),

                    // Send button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (isLoading || _isRateLimited()) ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          disabledBackgroundColor:
                              AppTheme.primaryBlue.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Send OTP',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Help card
              Card(
                elevation: 0,
                color: AppTheme.lightGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Help?',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Make sure you have access to your registered phone number to receive the OTP.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
