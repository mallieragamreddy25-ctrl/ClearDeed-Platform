import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SellStepIndicator extends StatelessWidget {
  final int currentStep; // 0-5
  final int completedSteps;
  final List<String> stepTitles;
  final VoidCallback? onStepTapped;

  const SellStepIndicator({
    Key? key,
    required this.currentStep,
    required this.completedSteps,
    this.stepTitles = const [
      'Details',
      'Images',
      'Documents',
      'Referral',
      'Review',
      'Submit'
    ],
    this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / 6,
            minHeight: 4,
            backgroundColor: AppTheme.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Step indicators
        Row(
          children: List.generate(6, (index) {
            final isCompleted = index < completedSteps;
            final isCurrent = index == currentStep;
            final isAccessible = index <= currentStep || index < completedSteps;

            return Expanded(
              child: GestureDetector(
                onTap: isAccessible ? () => onStepTapped?.call() : null,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppTheme.successGreen
                            : isCurrent
                                ? AppTheme.primaryBlue
                                : AppTheme.lightGrey,
                        border: isCurrent
                            ? Border.all(
                                color: AppTheme.primaryBlue,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepTitles[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: isCurrent
                                ? AppTheme.primaryBlue
                                : AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class CustomFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool required;
  final int maxLines;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? helperText;

  const CustomFormField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.required = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.helperText,
  }) : super(key: key);

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          minLines: widget.maxLines == 1 ? 1 : null,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

class FormDropdownField<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T?)? onChanged;
  final bool required;
  final String? Function(T?)? validator;

  const FormDropdownField({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.required = false,
    this.validator,
  }) : super(key: key);

  @override
  State<FormDropdownField<T>> createState() => _FormDropdownFieldState<T>();
}

class _FormDropdownFieldState<T> extends State<FormDropdownField<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: _selectedValue,
          items: widget.items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(widget.itemLabel(item)),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() => _selectedValue = newValue);
            widget.onChanged?.call(newValue);
          },
          validator: widget.validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class StepActionButtons extends StatelessWidget {
  final bool showPrevious;
  final bool showNext;
  final bool nextEnabled;
  final bool isLoading;
  final String nextLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const StepActionButtons({
    Key? key,
    this.showPrevious = true,
    this.showNext = true,
    this.nextEnabled = true,
    this.isLoading = false,
    this.nextLabel = 'Next',
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showPrevious)
          Expanded(
            child: OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppTheme.primaryBlue),
              ),
              child: const Text('Previous'),
            ),
          ),
        if (showPrevious && showNext) const SizedBox(width: 12),
        if (showNext)
          Expanded(
            child: ElevatedButton(
              onPressed: nextEnabled && !isLoading ? onNext : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          nextEnabled ? Colors.white : AppTheme.textHint,
                        ),
                      ),
                    )
                  : Text(nextLabel),
            ),
          ),
      ],
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    Key? key,
    this.error,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        border: Border.all(color: AppTheme.errorRed),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error ?? 'An error occurred',
              style: const TextStyle(
                color: AppTheme.errorRed,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: AppTheme.errorRed, size: 20),
            ),
        ],
      ),
    );
  }
}
