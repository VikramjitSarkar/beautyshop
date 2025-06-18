import 'package:beautician_app/utils/text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool? isObscure;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final TextInputType inputType;
  final int? maxLines;
  final double radius;
  final bool obscureText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Color fillColor;
  final bool isDense;

  const CustomTextField({
    super.key,
    this.isObscure,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
    this.radius = 12,
    this.onChanged,
    this.validator,
    this.fillColor = const Color(0xFFF8F8F8),
    this.isDense = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          isDense: isDense,
          hintText: hintText,
          hintStyle: kSubheadingStyle.copyWith(color: Colors.grey[600]),
          prefixIcon: prefixIcon != null ? prefixIcon : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
