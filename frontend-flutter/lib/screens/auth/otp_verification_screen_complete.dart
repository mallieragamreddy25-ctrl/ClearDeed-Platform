import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import '../../providers/auth_provider.dart';
import 'profile_setup_screen.dart';

/// Production-Ready OTP Verification Screen
/// Features: 6-digit input, auto-submit, countdown timer, resend functionality
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
  String? _validationError;

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

  /// Start countdown timer for OTP resend (60 seconds)
  void _startResendCountdown() {
    _resendCountdown = AppConstants.otpResendDelaySeconds;
    _canResend = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  /// Handle OTP input - auto-submit when 6 digits entered
  void _handleOtpChange(String value) {
    setState(() => _validationError = null);

    // Auto-submit when 6 digits are entered
    if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
      _verifyOtp();
    }
  }

 /// Verify OTP - validate and authenticate
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    final validationError = Validators.validateOtp(otp);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    AppLogger.logFunctionEntry('_verifyOtp', {
      'phoneNumber': widget.phoneNumber,
      'otpLength': otp.length,
    });

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.verifyOtp(widget.phoneNumber, otp);

    if (!mounted) return;

    if (success) {
      AppLogger.logAuthEvent('OTP verified successfully');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      }
    } else {
      final error = ref.read(authErrorProvider) ??
          AppConstants.invalidOtpMessage;
      setState(() => _validationError = error);
      _showErrorSnackBar(error);
    }
  }

  /// Resend OTP
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || !_canResend) return;

    AppLogger.logFunctionEntry('_resendOtp',
        {'phoneNumber': widget.phoneNumber});

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.resendOtp(widget.phoneNumber);

    if (!mounted) return;

    final error = ref.read(authErrorProvider);
    if (error != null) {
      _showErrorSnackBar(error);
    } else {
      _showSuccessSnackBar('OTP sent to ${widget.phoneNumber}');
      _startResendCountdown();
      _otpController.clear();
    }
  }

  void _goBackToLogin() {
    AppLogger.logFunctionEntry('_goBackToLogin');
    Navigator.of(context).pop();
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
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                      'Back',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a 6-digit OTP to\n${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // OTP input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
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
                          borderSide: const BorderSide(color: AppTheme.errorRed),
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

                  // Error display
                  if (_validationError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _validationError!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.errorRed),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading || _otpController.text.length != 6
                          ? null
                          : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        disabledBackgroundColor:
                            AppTheme.primaryBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                              'Verify OTP',
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

              const SizedBox(height: 40),

              // Resend section
              if (_canResend)
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Didn\'t receive the OTP?',
                        style: Theme.of(context).textTheme.labelSmall,
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
                              ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Resend OTP in',
                        style: Theme.of(context).textTheme.labelSmall,
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
                ),

              const SizedBox(height: 40),

              // Info card
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
                        '💡 Tip',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The OTP will be automatically submitted once you enter all 6 digits.',
                        style: Theme.of(context).textTheme.labelSmall,
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
