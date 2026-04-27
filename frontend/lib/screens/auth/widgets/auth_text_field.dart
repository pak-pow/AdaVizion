import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── BRAND COLOUR ─────────────────────────────────────────────────────────────
const _maroon = Color(0xFF7A1D1D);

/// Returns the standard subtle-grey rounded border used on every auth input.
///
/// Extracted from `_AuthScreenState._border()` so both [AuthTextField]
/// and [AuthDropdownField] can use it without duplicating code.
OutlineInputBorder authInputBorder() => OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: Colors.grey.shade300),
);

// ============================================================================
// AUTH TEXT FIELD
// ============================================================================

/// Reusable text input for the authentication forms (login & signup).
///
/// Extracted from `_AuthScreenState._buildTextField()`.
/// Uses [LengthLimitingTextInputFormatter] instead of [TextField.maxLength]
/// so no visible character counter is rendered.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.border,
    this.icon,
    this.obscureText = false,
    this.maxLength = 50,
  });

  final TextEditingController controller;
  final String hint;
  final OutlineInputBorder border;
  final IconData? icon;
  final bool obscureText;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      // LengthLimitingTextInputFormatter silently caps input at maxLength.
      // We intentionally do NOT use TextField.maxLength because it renders a
      // visible character counter that breaks the UI design.
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: Colors.grey.shade400)
            : null,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _maroon, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ============================================================================
// AUTH DROPDOWN FIELD
// ============================================================================

/// Reusable dropdown input for the authentication forms (e.g. program, specialization).
///
/// Extracted from `_AuthScreenState._buildDropdownField()`.
class AuthDropdownField extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.border,
    required this.onChanged,
  });

  final String hint;
  final List<DropdownMenuItem<String>> items;
  final String? selectedValue;
  final OutlineInputBorder border;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      dropdownColor: Colors.white,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _maroon, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
