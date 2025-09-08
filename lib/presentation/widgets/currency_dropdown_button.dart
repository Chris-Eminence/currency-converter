import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency_converter/core/constants/colors.dart';

class CurrencyDropdownButton extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;

  const CurrencyDropdownButton({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: Colors.white,

        value: value,
        items: items.map((currency) {
          return DropdownMenuItem(value: currency, child: Text(currency));
        }).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_outlined),
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: kDropDownHintTextColor,
        ),
      ),
    );
  }
}
