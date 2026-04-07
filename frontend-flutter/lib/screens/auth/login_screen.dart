import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import 'auth_providers.dart';
import 'otp_verification_screen.dart';

/// Login Screen - Entry point for authentication flow
/// Collects phone number and sends OTP for verification
/// Supports Indian phone format (+91 or 10-digit)
/// Features rate limiting, validation feedback, and loading states
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(_formatPhoneNumber);
    AppLogger.logFunctionEntry('LoginScreen.initState');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Format phone number as user types into Indian format: +91 XXXXX XXXXX
  void _formatPhoneNumber() {
    String value = _phoneController.text;
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length <= 3) {
        formatted = '+91 ${digitsOnly}';
      } else if (digitsOnly.length <= 6) {
        formatted =
            '+91 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
      } else {
        final finalLength = digitsOnly.length > 10 ? 10 : digitsOnly.length;
        formatted =
            '+91 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, finalLength)}';
      }
    }

    if (formatted != value && digitsOnly.length <= 10) {
      _phoneController.text = formatted;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }
  }

  /// Send OTP to phone number
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _validationError = null;
    });

    try {
      // Extract digits from phone number
      final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final phoneNumber = '+91$phoneDigits';

      AppLogger.logFunctionEntry('_sendOtp', {'phoneNumber': phoneNumber});

      // Call OTP provider
      final otpNotifier = ref.read(otpProvider.notifier);
      final success = await otpNotifier.sendOtp(phoneNumber);

      if (success && mounted) {
        AppLogger.logAuthEvent('OTP sent to $phoneNumber');
        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  OtpVerificationScreen(phoneNumber: phoneNumber),
            ),
          );
        }
      } else if (mounted) {
        final errorMessage = ref.read(otpErrorProvider);
        setState(() {
          _validationError = errorMessage ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      AppLogger.error('Send OTP failed: $e');
      setState(() {
        _validationError = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);
    final isLoading = otpState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 40),
                Text(
                  'ClearDeed',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Verified Real Estate & Investment',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 48),

                // Welcome Text
                Text(
                  'Enter Your Phone Number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ll send you a One Time Password (OTP) for verification',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Phone Input Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 13,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91 98765 43210',
                    counterText: '',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '🇮🇳',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
                      ),
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
                  ),
                  validator: (value) => Validators.validatePhoneNumber(value),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // Error Message Display
                if (_validationError != null)
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
                            _validationError!,
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
                if (_validationError != null) const SizedBox(height: 24),

                // Send OTP Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendOtp,
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
                                'Sending OTP...',
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
                            'Send OTP',
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
                const SizedBox(height: 24),

                // Info Box
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
                          'We\'ll never share your phone number without your permission.',
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
      ),
    );
  }
}
