import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import 'auth_providers.dart';
import 'profile_setup_screen.dart';

/// OTP verification screen
/// Displays OTP input field with countdown timer and verification logic
/// Features: Auto-submit on 6 digits, resend countdown, rate limiting, attempt tracking
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  late TextEditingController _otpController;
  late Timer _countdownTimer;
  int _resendCountdown = 0;
  bool _canResend = false;
  static const int _resendDelaySeconds = 60;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startResendCountdown();
    AppLogger.logFunctionEntry('OtpVerificationScreen.initState',
        {'phoneNumber': widget.phoneNumber});
  }

  @override
  void dispose() {
    _otpController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  /// Start countdown timer for OTP resend (120 seconds)
  void _startResendCountdown() {
    _resendCountdown = _resendDelaySeconds;
    _canResend = false;

    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
      }

      if (_resendCountdown <= 0) {
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
        timer.cancel();
      }
    });
  }

  /// Handle OTP input - auto-submit when 6 digits entered
  void _handleOtpChange(String value) {
    // Auto-submit when 6 digits are entered
    if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
      _verifyOtp();
    }
  }

  /// Verify OTP with the backend
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    // Validate OTP format
    final validationError = Validators.validateOtp(otp);
    if (validationError != null) {
      AppLogger.warning('OTP validation failed: $validationError');
      _showErrorDialog('Invalid OTP', validationError);
      return;
    }

    AppLogger.logFunctionEntry('_verifyOtp', {
      'phoneNumber': widget.phoneNumber,
      'otpLength': otp.length,
    });

    try {
      // Verify OTP through provider
      final otpNotifier = ref.read(otpProvider.notifier);
      final success = await otpNotifier.verifyOtp(widget.phoneNumber, otp);

      if (!mounted) return;

      if (success) {
        AppLogger.logAuthEvent('OTP verified successfully');
        // Navigate to profile setup
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProfileSetupScreen(),
            ),
          );
        }
      } else {
        // Show error from provider
        final otpState = ref.read(otpProvider);
        final errorMessage =
            otpState.error ?? AppConstants.invalidOtpMessage;

        _showErrorDialog('Verification Failed', errorMessage);

        // Show remaining attempts if applicable
        if (otpState.attemptsRemaining > 0 &&
            otpState.attemptsRemaining <= 2) {
          _showInfoDialog(
            'Attempts Remaining',
            '${otpState.attemptsRemaining} attempts remaining before lockout',
          );
        }
      }
    } catch (e) {
      AppLogger.error('OTP verification error: $e');
      _showErrorDialog('Error', 'An unexpected error occurred');
    }
  }

  /// Resend OTP
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || !_canResend) return;

    AppLogger.logFunctionEntry('_resendOtp', {
      'phoneNumber': widget.phoneNumber,
    });

    try {
      final otpNotifier = ref.read(otpProvider.notifier);
      final success = await otpNotifier.resendOtp();

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar('OTP sent to ${widget.phoneNumber}');
        _startResendCountdown();
        _otpController.clear();
      } else {
        final errorMessage = ref.read(otpErrorProvider) ?? 'Failed to resend OTP';
        _showErrorDialog('Resend Failed', errorMessage);
      }
    } catch (e) {
      AppLogger.error('Resend OTP error: $e');
      _showErrorDialog('Error', 'Failed to resend OTP');
    }
  }

  /// Go back to login screen
  void _goBackToLogin() {
    AppLogger.logFunctionEntry('_goBackToLogin');
    ref.read(otpProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);
    final isLoading = otpState.isLoading;
    final isLockedOut = otpState.nextRetryTime != null &&
        DateTime.now().isBefore(otpState.nextRetryTime!);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              GestureDetector(
                onTap: _goBackToLogin,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Change Number',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Header
              Text(
                'Verify Your Number',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a 6-digit OTP to\n${widget.phoneNumber}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // OTP input field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter 6-Digit OTP',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
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
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: _handleOtpChange,
                      enabled: !isLockedOut,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            letterSpacing: 8,
                            fontWeight: FontWeight.w600,
                          ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              color: AppTheme.textHint,
                              letterSpacing: 8,
                            ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.textHint,
                          ),
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
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ||
                              _otpController.text.length != 6 ||
                              isLockedOut
                          ? null
                          : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        disabledBackgroundColor:
                            AppTheme.primaryBlue.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      AppTheme.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Verifying...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: AppTheme.white,
                                      ),
                                ),
                              ],
                            )
                          : Text(
                              'Verify OTP',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Attempts remaining display
              if (otpState.attemptsRemaining < 3 &&
                  otpState.attemptsRemaining > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    border: Border.all(
                      color: AppTheme.warningOrange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_outlined,
                        color: AppTheme.warningOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${otpState.attemptsRemaining} attempts remaining',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.warningOrange,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Lockout display
              if (isLockedOut)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    border: Border.all(
                      color: AppTheme.errorRed,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Too many attempts. Try again in 30 minutes.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.errorRed,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Resend OTP section
              if (!isLockedOut)
                Center(
                  child: Column(
                    children: [
                      if (_canResend)
                        Column(
                          children: [
                            Text(
                              'Didn\'t receive the OTP?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                'Resend OTP',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Resend OTP in',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_resendCountdown}s',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.infoBlue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.infoBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The OTP will auto-submit once you enter all 6 digits.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
