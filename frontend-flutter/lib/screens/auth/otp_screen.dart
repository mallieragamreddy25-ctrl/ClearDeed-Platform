import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/app_logger.dart';
import '../providers/auth_provider.dart';

/// OTP verification screen
/// Displays OTP input field with countdown timer and verification logic
class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final Function(String token) onVerifySuccess;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.onVerifySuccess,
  }) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late TextEditingController _otpController;
  int _resendCountdown = 0;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _stopwatch = Stopwatch()..start();
    _startCountdown();
    AppLogger.logFunctionEntry('OtpScreen.initState');
  }

  @override
  void dispose() {
    _otpController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  /// Start OTP resend countdown timer
  void _startCountdown() {
    _resendCountdown = AppConstants.otpResendDelaySeconds;

    Future.doWhile(() async {
      if (!mounted) return false;

      await Future.delayed(const Duration(seconds: 1));

      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
        return true;
      }

      return false;
    });
  }

  /// Verify OTP
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    // Validate OTP
    final validationError = Validators.validateOtp(otp);
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    AppLogger.logFunctionEntry('_verifyOtp', {'otpLength': otp.length});

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.verifyOtp(widget.phoneNumber, otp);

    if (success && mounted) {
      AppLogger.logAuthEvent('OTP verified successfully');
      widget.onVerifySuccess(ref.read(authTokenProvider) ?? '');
    } else if (mounted) {
      final error = ref.read(authErrorProvider) ?? 'OTP verification failed';
      _showErrorSnackBar(error);
    }
  }

  /// Resend OTP
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    AppLogger.logFunctionEntry('_resendOtp');

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.resendOtp(widget.phoneNumber);

    if (mounted) {
      _showSuccessSnackBar('OTP sent to ${widget.phoneNumber}');
      _startCountdown();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Phone number display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Text(
                    'Verify your phone number',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'OTP sent to ${widget.phoneNumber}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // OTP Input Field
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              enabled: !isLoading,
              style: Theme.of(context).textTheme.displayMedium,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 24,
                ),
                labelText: 'Enter OTP',
              ),
              onChanged: (value) {
                // Auto-submit when 6 digits are entered
                if (value.length == 6) {
                  _verifyOtp();
                }
              },
            ),

            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resend OTP Button
            TextButton(
              onPressed: _resendCountdown > 0 ? null : _resendOtp,
              child: Text(
                _resendCountdown > 0
                    ? 'Resend OTP in $_resendCountdown seconds'
                    : 'Resend OTP',
                style: TextStyle(
                  color: _resendCountdown > 0
                      ? AppTheme.textHint
                      : AppTheme.primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppTheme.infoBlue, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppTheme.infoBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter the 6-digit OTP sent to your phone number',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Import for FilteringTextInputFormatter
import 'package:flutter/services.dart';
