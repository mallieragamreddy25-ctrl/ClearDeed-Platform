import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/app_logger.dart';
import '../../providers/user_provider.dart';

/// Profile setup screen - collects user information after OTP verification
class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const ProfileSetupScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _budgetController;
  late TextEditingController _netWorthController;
  late TextEditingController _referralController;

  String _selectedProfileType = 'Buyer';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _cityController = TextEditingController();
    _budgetController = TextEditingController();
    _netWorthController = TextEditingController();
    _referralController = TextEditingController();
    AppLogger.logFunctionEntry('ProfileSetupScreen.initState');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    _netWorthController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  /// Submit profile setup form
  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AppLogger.logFunctionEntry('_submitProfile');

    final success = await ref.read(userProvider.notifier).updateProfile(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          city: _cityController.text.trim(),
          profileType: _selectedProfileType,
          budget: _budgetController.text.trim(),
          netWorth: _netWorthController.text.trim(),
          referralNumber: _referralController.text.trim(),
        );

    if (success && mounted) {
      AppLogger.logAuthEvent('Profile setup completed');
      _showSuccessSnackBar('Profile created successfully!');

      // Navigate to home screen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      });
    } else if (mounted) {
      final error = ref.read(userErrorProvider) ?? 'Failed to update profile';
      _showErrorSnackBar(error);
      ref.read(userProvider.notifier).clearError();
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
    final isLoading = ref.watch(userLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Step 1 of 1',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Complete your profile',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Full Name
              TextFormField(
                controller: _nameController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: Validators.validateFullName,
              ),

              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'john@example.com',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: Validators.validateEmailOptional,
              ),

              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Mumbai',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: Validators.validateCity,
              ),

              const SizedBox(height: 16),

              // Profile Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedProfileType,
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedProfileType = value);
                        }
                      },
                decoration: const InputDecoration(
                  labelText: 'I am a',
                  prefixIcon: Icon(Icons.manage_accounts),
                ),
                items: AppConstants.profileTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                validator: Validators.validateProfileType,
              ),

              const SizedBox(height: 24),

              // Section divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.lightGrey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Optional Information',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.lightGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Budget (for Buyers)
              if (_selectedProfileType == 'Buyer') ...[
                TextFormField(
                  controller: _budgetController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Budget (in ₹)',
                    hintText: '50,00,000',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: Validators.validateAmount,
                ),
                const SizedBox(height: 16),
              ],

              // Net Worth (for Investors/Sellers)
              if (_selectedProfileType != 'Buyer') ...[
                TextFormField(
                  controller: _netWorthController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Net Worth (in ₹)',
                    hintText: '1,00,00,000',
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  validator: Validators.validateAmount,
                ),
                const SizedBox(height: 16),
              ],

              // Referral (optional)
              TextFormField(
                controller: _referralController,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Referral Mobile Number (optional)',
                  hintText: '98765 43210',
                  prefixIcon: Icon(Icons.people),
                  prefixText: '+91 ',
                ),
                validator: Validators.validateReferralNumber,
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitProfile,
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
                            'Create Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppTheme.infoBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your information helps us personalize your experience',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
