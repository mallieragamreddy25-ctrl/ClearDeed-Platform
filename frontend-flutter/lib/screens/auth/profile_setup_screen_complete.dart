import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// Production-Ready Profile Setup Screen
/// Multi-step form: Full Name, Email, City, Profile Type, Budget Range, Referral
/// Features: Form validation, error tracking, loading states, field persistence
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _referralMobileController;
  final _formKey = GlobalKey<FormState>();

  String? _selectedProfileType;
  String? _selectedBudgetRange;

  static const List<String> profileTypes = ['Buyer', 'Seller', 'Investor'];
  static const List<String> budgetRanges = [
    'Below 25 Lac',
    '25 Lac - 50 Lac',
    '50 Lac - 1 Cr',
    '1 Cr - 5 Cr',
    'Above 5 Cr',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _referralMobileController = TextEditingController();
    AppLogger.logFunctionEntry('ProfileSetupScreen.initState');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _referralMobileController.dispose();
    super.dispose();
  }

  /// Format referral mobile number as user types - Indian format
  void _formatReferralMobile(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 10) {
      _referralMobileController.text = digitsOnly.substring(0, 10);
      _referralMobileController.selection = TextSelection.fromPosition(
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
      _referralMobileController.text = formatted;
      _referralMobileController.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }
  }

  /// Submit profile setup - validate and call API
  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    AppLogger.logFunctionEntry('_submitProfile', {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'city': _cityController.text,
    });

    final profileNotifier = ref.read(profileSetupProvider.notifier);
    final success = await profileNotifier.submitProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      profileType: _selectedProfileType ?? '',
      budgetRange: _selectedBudgetRange ?? '',
      referralMobile: _referralMobileController.text.isNotEmpty
          ? _referralMobileController.text.replaceAll(RegExp(r'[^\d]'), '')
          : null,
    );

    if (!mounted) return;

    if (success) {
      AppLogger.logAuthEvent('Profile setup completed successfully');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      final error = ref.read(profileSetupErrorProvider);
      if (error != null) {
        _showErrorSnackBar(error);
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
    final isLoading = ref.watch(isProfileSetupLoadingProvider);
    final fieldErrors = ref.watch(profileSetupFieldErrorsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Help us personalize your ClearDeed experience',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFormField(
                      context,
                      label: 'Full Name',
                      controller: _fullNameController,
                      hint: 'John Doe',
                      validator: Validators.validateFullName,
                      errorText: fieldErrors['fullName'],
                    ),
                    const SizedBox(height: 24),

                    // Email
                    _buildFormField(
                      context,
                      label: 'Email Address',
                      controller: _emailController,
                      hint: 'john@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      errorText: fieldErrors['email'],
                    ),
                    const SizedBox(height: 24),

                    // City
                    _buildFormField(
                      context,
                      label: 'City',
                      controller: _cityController,
                      hint: 'Mumbai, Delhi, Bangalore...',
                      validator: Validators.validateCity,
                      errorText: fieldErrors['city'],
                    ),
                    const SizedBox(height: 24),

                    // Profile Type
                    _buildDropdownField(
                      context,
                      label: 'Profile Type',
                      value: _selectedProfileType,
                      hint: 'Select your profile type',
                      items: profileTypes,
                      onChanged: (value) {
                        setState(() => _selectedProfileType = value);
                      },
                      errorText: fieldErrors['profileType'],
                    ),
                    const SizedBox(height: 24),

                    // Budget Range
                    _buildDropdownField(
                      context,
                      label: 'Budget Range',
                      value: _selectedBudgetRange,
                      hint: 'Select your budget range',
                      items: budgetRanges,
                      onChanged: (value) {
                        setState(() => _selectedBudgetRange = value);
                      },
                      errorText: fieldErrors['budgetRange'],
                    ),
                    const SizedBox(height: 24),

                    // Referral Mobile (Optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referral Mobile (Optional)',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
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
                            controller: _referralMobileController,
                            keyboardType: TextInputType.phone,
                            onChanged: _formatReferralMobile,
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              final cleanedPhone =
                                  value.replaceAll(RegExp(r'[^\d]'), '');
                              if (cleanedPhone.length != 10) {
                                return 'Must be 10 digits';
                              }
                              if (!RegExp(r'^[6-9]\d{9}$')
                                  .hasMatch(cleanedPhone)) {
                                return 'Invalid Indian mobile';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '+91 9876543210',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  '🇮🇳',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
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
                                vertical: 12,
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitProfile,
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
                                'Complete Profile',
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
            ],
          ),
        ),
      ),
    );
  }

  /// Build a text form field widget
  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
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
                vertical: 12,
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.errorRed),
            ),
          ),
      ],
    );
  }

  /// Build a dropdown form field widget
  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(hint),
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
            decoration: InputDecoration(
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
                vertical: 12,
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.errorRed),
            ),
          ),
      ],
    );
  }
}
