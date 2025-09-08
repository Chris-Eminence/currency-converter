// amount_text_field.dart
import 'package:currency_converter/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountTextField extends StatelessWidget {
  const AmountTextField({
    super.key,
    required this.amountController,
    this.onChanged,
    this.readOnly = false,
  });

  final TextEditingController amountController;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: amountController,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: kFillColor,
        hintText: '0.00',
        hintStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: kDropDownHintTextColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.w500,
        fontSize: 20,
        color: kDropDownHintTextColor,
      ),
      onChanged: onChanged,
    );
  }
}