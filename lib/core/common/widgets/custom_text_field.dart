import 'package:coded_gp/core/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final String? errorText;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final VoidCallback? onEditingComplete;
  final Function(String)? onFieldSubmitted;
  final Color? backgroundColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.backgroundColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.kWhiteColor : AppColors.kBlackColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onFieldSubmitted,
          obscureText: widget.isPassword ? _obscureText : false,
          style: TextStyle(
            color: isDark ? AppColors.kWhiteColor : AppColors.kTextDarkColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            errorStyle: const TextStyle(
              color: AppColors.kErrorColor,
            ),
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[400] : AppColors.kTextLightColor,
            ),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: isDark ? Colors.grey[400] : AppColors.kTextDarkColor,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color:
                          isDark ? Colors.grey[400] : AppColors.kTextLightColor,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.kbBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : AppColors.kbBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.kbBorderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.kErrorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.kErrorColor),
            ),
            filled: isDark || widget.backgroundColor != null,
            fillColor: widget.backgroundColor ?? Theme.of(context).cardColor,
          ),
        ),
      ],
    );
  }
}
