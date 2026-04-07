import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import '../../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

/// Login screen - entry point for authentication flow
/// Handles phone number input and navigation to OTP verification
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
    AppLogger.logFunctionEntry('LoginScreen.initState');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Format phone number as user types
  void _formatPhoneNumber(String value) {
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      _phoneController.text = digitsOnly.substring(0, 10);
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: 10),
      );
      return;
    }

    // Format as (9876543210) for Indian numbers
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

  /// Send OTP to phone number
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _validationError = null;
    });

    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    AppLogger.logFunctionEntry('_sendOtp', {'phoneNumber': phoneNumber});

    // Send OTP
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.sendOtp(phoneNumber);

    // Check if send was successful
    if (!mounted) return;

    final error = ref.read(authErrorProvider);
    if (error != null) {
      setState(() {
        _validationError = error;
      });
      _showErrorSnackBar(error);
      authNotifier.clearError();
    } else {
      // Navigate to OTP screen
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
              const SizedBox(height: 40),
              // Header
              Text(
                'Welcome to ClearDeed',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'End-to-end verified real estate & investment execution',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Phone number form
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
                          LengthLimitingTextInputFormatter(13), // +91 + 10 digits
                        ],
                        onChanged: _formatPhoneNumber,
                        validator: (value) {
                          return Validators.validatePhoneNumber(value);
                        },
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
                            borderSide:
                                const BorderSide(color: AppTheme.textHint),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
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
                    const SizedBox(height: 24),

                    // Terms and conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'By proceeding, you agree to our Terms of Service and Privacy Policy',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Send OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOtp,
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

              // Help section
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
                        '❓ Need Help?',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll send a 6-digit OTP to verify your phone number. Make sure you have access to this number.',
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
